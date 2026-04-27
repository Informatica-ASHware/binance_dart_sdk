# Justificación de Cambio en Dependencias / CI

## Motivo del Cambio
Renombramiento quirúrgico de todos los paquetes del SDK para cumplir con los requisitos de disponibilidad de nombres en `pub.dev`. Se ha adoptado el esquema `ash_binance_api_<modulo>` para garantizar consistencia y evitar colisiones con paquetes de terceros.

## Impacto
Actualización del archivo `.github/workflows/ci.yml`. No afecta el código fuente ya que es un SDK de Dart puro, pero asegura consistencia en el pipeline.

## Pruebas Realizadas
- `python3 scripts/actualizar_version_flutter.py`
