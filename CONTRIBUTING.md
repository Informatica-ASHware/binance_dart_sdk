# Guía de Contribución

## 🛑 Reglas de Integridad (Obligatorio)
Este repositorio tiene controles estrictos para garantizar la estabilidad a largo plazo.

### 1. No Cambiar Versiones sin Justificación
No se permite modificar las versiones de `pubspec.yaml` ni los flujos de `.github/workflows/*.yml` a menos que sea estrictamente necesario.

### 2. Protocolo de Cambio
Si necesitas realizar un cambio protegido:
1. Crea un archivo `PR_JUSTIFICATION.md` en la raíz.
2. Explica el motivo técnico, el impacto y las pruebas realizadas.
3. El script de CI `scripts/check_integrity.py` validará este archivo.

## 🤖 Guía para Agentes de IA
Consulta el archivo `AGENTS.md` para entender las restricciones de SDK Pinning y obsolescencia antes de proponer cambios en las dependencias.
