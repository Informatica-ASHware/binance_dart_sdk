# AGENTS.md - Reglas del Repositorio para Agentes IA

## 🎯 Propósito y Contexto del Proyecto
Este archivo proporciona el contexto crítico y las restricciones obligatorias para cualquier Agente IA (Jules, Antigravity, Cursor, Claude, etc.) que trabaje en este monorepo.

Este repositorio (`binance_dart_sdk`) es un SDK de nivel Enterprise para conectar con el API de Binance (Spot, Margin, Futures). Se gestiona como un monorepo utilizando `melos`.

> [!IMPORTANT]
> **Contexto del Ecosistema:** Este repositorio es un componente crítico del ecosistema **CryptBot System** (junto con *Iron Widgets, KChart2 y CryptBot*). Las reglas de integridad existen porque compartimos dependencias núcleo y patrones de CI; cualquier desalineación aquí puede propagar inestabilidad a todo el sistema Dart/Flutter.

---

## 🤖 REGLAS DE ARQUITECTURA Y CÓDIGO (OBLIGATORIO)

Antes de proponer un plan o hacer un Pull Request, DEBES verificar estrictamente que cumples con las siguientes invariantes arquitectónicas. La violación de estas reglas resultará en el rechazo del PR.

### 1. Regla Zero-Flutter (Dart Puro)
- **Lenguaje:** SDK `>=3.0.0 <4.0.0`.
- **PROHIBIDO:** Usar o importar `package:flutter` o cualquier dependencia exclusiva de UI. El código debe poder compilarse de forma nativa (AOT) para servidores, lambdas o scripts CLI.

### 2. Inmutabilidad Estricta
- Usa tipos inmutables para todos los modelos de Request y Response.
- Usa `sealed classes` para los estados y errores (e.g., `Result<T, BinanceError>`).
- Usa Records de Dart 3 cuando sea útil.
- Cero setters mutables públicos en tipos de dominio.

### 3. Prácticas de Red y Arquitectura
- **Logs:** Nunca uses `print()`. Usa la interfaz interna inyectable `BinanceLogger` (agnóstica).
- **Concurrencia:** Todo WebSocket de alta frecuencia debe implementar Isolates para evitar bloquear el Event Loop.
- **Criptografía:** Todas las firmas criptográficas de requests (Ed25519, RSA, HMAC) deben aplicar "percent-encoding estricto" (RFC 3986) en el payload canónico.

---

## 🛠 REGLAS DE GESTIÓN DE DEPENDENCIAS

### 1. The "SDK Pinning" Rule (CRÍTICO)
- **Problema:** El Flutter SDK a menudo fija (pins) versiones específicas de paquetes core (como `meta`, `path`, `analyzer`).
- **Restricción:** NUNCA fuerces una versión de dependencia que exceda lo que el Flutter SDK actual soporta en su `flutter_test` o componentes core.
- **Ejemplo:** Si `flutter_test` depende de `meta 1.15.0`, NO establezcas `meta: ^1.16.0` aunque esté disponible. Esto causará un fallo de version solving.
- **Acción:** Verifica siempre los constraints actuales del Flutter SDK antes de actualizar dependencias transitivas core.

### 2. The "Stale Package" Rule
- **Restricción:** Evita agregar o mantener dependencias que no hayan sido actualizadas por más de **1 año**.
- **Razonamiento:** Dart y Flutter evolucionan rápidamente. Los paquetes abandonados (stale) conducen a `breaking changes` e incompatibilidades con SDKs más nuevos.
- **Acción:** Si un paquete es stale, busca una alternativa moderna o notifica al usuario para considerar hacer un fork o reemplazarlo.

### 3. Version Hard-Locking
- Usa `^` para actualizaciones flexibles pero seguras (semver).
- **PROHIBIDO** usar `any` a menos que esté explícitamente permitido en las `directivas/` para paquetes internos del monorepo.

---

## 🚀 FLUJO DE TRABAJO, TOOLING Y DoD

### 1. Definition of Done (DoD) Universal para cada Pull Request
- **Testing:** Cobertura > 90%. Todo PR debe incluir tests unitarios (o mock tests).
- **Documentación:** Obligatorio usar Dartdoc (`///`) para TODA clase, método y propiedad pública.
- **Changelog:** Actualiza el archivo `CHANGELOG.md` del paquete afectado siguiendo las normas de *Conventional Commits*.
- **Linter:** El código no debe tener ningún warning bajo `dart analyze`. Aplica siempre `dart format`.
- **Pub.dev:** El código debe mantener el estándar para publicar en pub.dev (130/140 puntos mínimos validados en simulación).

### 2. Flujo de Trabajo del Monorepo (`melos`)
- Ejecuta todas las operaciones de tooling desde la raíz usando Melos (e.g., `melos run test`, `melos run analyze`).
- Mantén la separación estricta de dominios: `binance_core`, `binance_spot`, `binance_margin`, `binance_futures`.

### 3. Integrity Guardian y Sincronización
- **Integridad:** DEBES ejecutar `python3 scripts/check_integrity.py` antes de sugerir un commit que modifique `pubspec.yaml` o `.github/workflows/`. Si se requieren cambios, DEBES crear un archivo `PR_JUSTIFICATION.md` con una explicación técnica detallada.
- **Sincronización:** Después de cualquier cambio de dependencias, ejecuta `python3 scripts/sincronizar_dependencias_dart.py` para asegurar que todo el monorepo sigue sincronizado y pasa el análisis.

---

## 🧠 SISTEMA DE MEMORIA Y DIRECTIVAS

Este repositorio utiliza un **sistema de 3 componentes**:
1. `directivas/`: Standard Operating Procedures (SOPs).
2. `scripts/`: Scripts de ejecución determinista.
3. `AGENTS.md`: Este archivo de contexto.

**REGLA DE ORO:** SIEMPRE consulta la carpeta `directivas/` antes de implementar nueva lógica.

---

### 📝 RESUMEN RÁPIDO PARA EL AGENTE (TL;DR)
- **Zero-Flutter:** Prohibido `package:flutter`. Solo Dart puro.
- **Inmutabilidad:** Usar `sealed classes`, Records (Dart 3) y tipos inmutables.
- **DoD:** Tests > 90%, Dartdoc completo, código formateado y sin warnings.
- **Tools:** Usar `melos` para el monorepo y validación de scripts Python.
- **Logs:** Usar `BinanceLogger`, NUNCA `print()`.
- **Dependencias:** Respetar los límites del Flutter SDK actual. No forzar versiones y evitar dependencias de más de 1 año sin actualizar.