# Justificación de Cambio en Dependencias / CI

## Motivo del Cambio
Actualización global de la versión de Flutter en los flujos de CI a `3.41.7` para mantener la paridad con el resto de los proyectos del monorepo y asegurar que el análisis estático y pruebas se ejecuten sobre el mismo entorno.

## Impacto
Actualización del archivo `.github/workflows/ci.yml`. No afecta el código fuente ya que es un SDK de Dart puro, pero asegura consistencia en el pipeline.

## Pruebas Realizadas
- `python3 scripts/actualizar_version_flutter.py`
