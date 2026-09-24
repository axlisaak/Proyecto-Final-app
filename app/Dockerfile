# Versión fija de la imagen base
FROM python:3.11-slim-bookworm

# Instalar curl para el HEALTHCHECK
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Crear usuario sin privilegios root
RUN useradd -m appuser
WORKDIR /home/appuser/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Corrección: Asignar propiedad de los archivos al usuario appuser
COPY --chown=appuser:appuser . .

# Cambiar al usuario sin privilegios
USER appuser

# Healthcheck para validar que la app está viva
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/salud || exit 1

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
