#!/bin/bash
echo "Iniciando escaneo de secretos con Gitleaks..."

# Ejecutar Gitleaks en contenedor y guardar la salida en el reporte
docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect --source="/path" --no-git -v > reportes/corrida_roja.txt 2>&1

# Umbral explícito: Bloquea si el código de salida de Gitleaks indica hallazgos
if [ $? -ne 0 ]; then
    echo "PIPELINE BLOQUEADO: Se detectaron secretos expuestos. Revisa reportes/corrida_roja.txt"
    exit 1
else
    echo "PIPELINE PERMITIDO: Cero secretos detectados."
    exit 0
fi
