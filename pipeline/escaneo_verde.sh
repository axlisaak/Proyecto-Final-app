#!/bin/bash
echo "Iniciando pipeline de seguridad automatizado..."
mkdir -p reportes

echo "--> 1. Ejecutando escaneo de secretos globales (Gitleaks)..."
# Se cambió a /path para escanear todo el repositorio
docker run --rm -v $(pwd):/path zricethezav/gitleaks:latest detect --source="/path" --no-git -v > reportes/corrida_verde.txt 2>&1

if [ $? -ne 0 ]; then
    echo "PIPELINE BLOQUEADO: Gitleaks detectó secretos expuestos."
    cat reportes/corrida_verde.txt
    exit 1
else
    echo "[OK] Cero secretos detectados."
fi

echo "--> 2. Ejecutando escaneo de vulnerabilidades SAST (Bandit)..."
# Se cambió a '.' para escanear todo el repositorio y no solo 'app/'
bandit -r . >> reportes/corrida_verde.txt 2>&1

if [ $? -ne 0 ]; then
    echo "PIPELINE BLOQUEADO: Bandit detectó vulnerabilidades en el código."
    cat reportes/corrida_verde.txt
    exit 1
else
    echo "[OK] Cero vulnerabilidades detectadas por Bandit."
fi

echo "====================================================================="
echo "PIPELINE PERMITIDO: El código es seguro para pasar a Producción."
echo "Evidencia global guardada en reportes/corrida_verde.txt"
exit 0
