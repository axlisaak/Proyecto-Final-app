from fastapi import APIRouter
import sqlalchemy

buscar_router = APIRouter()

def obtener_conexion():
    from main import engine 
    return engine.connect()

@buscar_router.get("/publicaciones/buscar")
def buscar_por_usuario(usuario: str = ""):
    # PREVENCIÓN: Uso de parámetros vinculados (bind parameters) para evitar Inyección SQL
    consulta = sqlalchemy.text("SELECT id, content FROM posts WHERE username = :usuario ORDER BY id DESC LIMIT 20")
    conexion = obtener_conexion()
    
    # Pasamos el valor del usuario de forma segura como un diccionario
    resultado = conexion.execute(consulta, {"usuario": usuario})
    
    publicaciones = [{"id": fila[0], "contenido": fila[1]} for fila in resultado.fetchall()]
    return {"usuario": usuario, "publicaciones": publicaciones}
