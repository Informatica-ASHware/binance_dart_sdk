# Contexto del Proyecto
Este repositorio (`binance_dart_sdk`) es un SDK de nivel Enterprise para conectar con el API de Binance (Spot, Margin, Futures). Se gestiona como un monorepo utilizando `melos`.

# 🤖 REGLAS DE EJECUCIÓN GENERALES PARA EL AGENTE JULES (OBLIGATORIO)

Jules, antes de proponer un plan o hacer un Pull Request, DEBES verificar estrictamente que cumples con las siguientes invariantes arquitectónicas. Si violas alguna de estas reglas, el PR será rechazado.

## 1. Regla Zero-Flutter (Dart Puro)
- Lenguaje: SDK `>=3.0.0 <4.0.0`.
- **PROHIBIDO:** Usar o importar `package:flutter` o cualquier dependencia exclusiva de UI. El código debe poder compilarse de forma nativa (AOT) para servidores, lambdas o scripts CLI.

## 2. Inmutabilidad Estricta
- Usa tipos inmutables para todos los modelos de Request y Response.
- Usa `sealed classes` para los estados y errores (e.g., `Result<T, BinanceError>`).
- Usa Records de Dart 3 cuando sea útil.
- Cero setters mutables públicos en tipos de dominio.

## 3. Definition of Done (DoD) Universal para cada Pull Request
- **Testing:** Cobertura > 90%. Todo PR debe incluir tests unitarios (o mock tests).
- **Documentación:** Obligatorio usar Dartdoc (`///`) para TODA clase, método y propiedad pública.
- **Changelog:** Actualiza el archivo `CHANGELOG.md` del paquete afectado siguiendo las normas de *Conventional Commits*.
- **Linter:** El código no debe tener ningún warning bajo `dart analyze`. Aplica siempre `dart format`.
- **Pub.dev:** El código debe mantener el estándar para publicar en pub.dev (130/140 puntos mínimos validados en simulación).

## 4. Flujo de Trabajo del Monorepo
- Ejecuta todas las operaciones de tooling desde la raíz usando Melos (e.g., `melos run test`, `melos run analyze`).
- Mantén la separación estricta de dominios: `binance_core`, `binance_spot`, `binance_margin`, `binance_futures`.

## 5. Prácticas de Red y Arquitectura
- Nunca uses `print()`. Usa la interfaz interna inyectable `BinanceLogger` (agnóstica).
- Todo WebSocket de alta frecuencia debe implementar Isolates para evitar bloquear el Event Loop.
- Todas las firmas criptográficas de requests (Ed25519, RSA, HMAC) deben aplicar "percent-encoding estricto" (RFC 3986) en el payload canónico.

Resumen:

# Contexto del Proyecto: binance_dart_sdk
SDK de Dart puro (Zero-Flutter) para el API de Binance.

# 🤖 REGLAS PARA EL AGENTE IA (OBLIGATORIO)
- **Zero-Flutter:** Prohibido usar package:flutter.
- **Inmutabilidad:** Usar sealed classes y records de Dart 3.
- **DoD:** Cobertura de tests > 90%, documentación Dartdoc completa.
- **Tools:** Usar melos para gestionar dependencias.
- **Logs:** No usar print(). Usar BinanceLogger inyectable.
