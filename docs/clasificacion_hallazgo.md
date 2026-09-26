**Tipo:** 
Inyección SQL (CWE-89).

**Severidad:**
Crítica. Aunque la herramienta lo marca como severidad media, el impacto real es crítico. La aplicación concatena directamente el parámetro usuario enviado por el cliente en la consulta SQL. Esto es sumamente fácil de explotar; un atacante sin autenticación podría enviar una cadena maliciosa (ej. ' OR '1'='1) para leer toda la base de datos, extraer información de otros usuarios o incluso lanzar comandos de borrado.

**¿Falso positivo?:**
No es un falso positivo. Se verifica en el código fuente (app/buscar_publicaciones.py:12) que la variable usuario se integra a la cadena SQL sin ningún tipo de sanitización, filtro o parametrización, lo que permite la manipulación directa de la consulta.
