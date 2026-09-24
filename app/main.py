from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.orm import declarative_base, sessionmaker, Session
import redis
import os
import json

# CORRECCIÓN: Guardar SQLite en /tmp/ para evitar el bloqueo de permisos
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:////tmp/red_social.db")
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)

class Post(Base):
    __tablename__ = "posts"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String)
    content = Column(Text)

Base.metadata.create_all(bind=engine)

redis_host = os.getenv("REDIS_HOST", "localhost")
cache = redis.Redis(host=redis_host, port=6379, db=0, decode_responses=True)

app = FastAPI(title="Red Social Breve")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/salud")
def health_check():
    try:
        cache.ping()
        return {"status": "ok", "redis": "conectado"}
    except redis.ConnectionError:
        return {"status": "ok", "redis": "desconectado"}

@app.post("/registro")
def registrar_usuario(username: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if user:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    nuevo_usuario = User(username=username)
    db.add(nuevo_usuario)
    db.commit()
    return {"mensaje": f"Usuario {username} registrado"}

@app.post("/publicar")
def crear_publicacion(username: str, content: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    nueva_pub = Post(username=username, content=content)
    db.add(nueva_pub)
    db.commit()
    
    cache.delete("global_feed")
    return {"mensaje": "Publicación creada con éxito"}

@app.get("/feed")
def obtener_feed(db: Session = Depends(get_db)):
    cached_feed = cache.get("global_feed")
    if cached_feed:
        return {"origen": "redis_cache", "feed": json.loads(cached_feed)}
    
    posts = db.query(Post).order_by(Post.id.desc()).limit(10).all()
    feed_data = [{"id": p.id, "usuario": p.username, "contenido": p.content} for p in posts]
    
    cache.setex("global_feed", 60, json.dumps(feed_data))
    return {"origen": "base_de_datos", "feed": feed_data}
