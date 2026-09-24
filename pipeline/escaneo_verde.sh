#!/bin/bash
echo "Iniciando escaneo de secretos (Corrida Verde)..."

# Ajustado: Le decimos a Gitleaks que solo escanee la carpeta /path/app
docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect --source="/path/app" --no-git -v > reportes/corrida_verde.txt 2>&1

if [ $? -ne 0 ]; then
    echo "PIPELINE BLOQUEADO"
    exit 1
else
    echo "PIPELINE PERMITIDO: Cero secretos detectados. Evidencia guardada en corrida_verde.txt."
    exit 0
fi
