#!/bin/bash
# =============================================================================
# binance_dart_sdk — Backlog Automation Script (AI Agent Ready)
# =============================================================================
# Repo: Informatica-ASHware/binance_dart_sdk
# Requisito: gh (GitHub CLI) autenticado
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURACIÓN
# ---------------------------------------------------------------------------
OWNER="Informatica-ASHware"
REPO="binance_dart_sdk"
FULL_REPO="${OWNER}/${REPO}"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SUCCESS_COUNT=0
FAIL_COUNT=0

# ---------------------------------------------------------------------------
# FUNCIONES
# ---------------------------------------------------------------------------

create_labels() {
    echo -e "${BLUE}[SETUP] Creando etiquetas de arquitectura...${NC}"
    # Formato: "Nombre|Color|Descripción"
    LABELS=(
        "epic:core|0052cc|Fundamentos y tipos base"
        "epic:auth|af52bf|Seguridad y Firmas (Ed25519/HMAC)"
        "epic:transport|006b75|Capa de red HTTP/WS"
        "epic:spot|e99695|Binance Spot API"
        "epic:margin|f9d0c4|Binance Margin API"
        "epic:futures|1d76db|Binance USD-M Futures API"
        "epic:testing|fbca04|Infraestructura de Mocks y Tests"
        "epic:dx-docs|c2e0c6|Documentación y Experiencia de Usuario"
        "jules|ff8c00|Para ser procesado por Jules (AI Agent)"
        "priority:high|d73a4a|Alta prioridad"
        "priority:medium|eabc40|Prioridad media"
        "priority:low|cfd3d7|Baja prioridad"
    )

    for item in "${LABELS[@]}"; do
        IFS='|' read -r label color desc <<< "$item"
        # No falla si ya existe
        gh label create "$label" --color "$color" --description "$desc" --repo "$FULL_REPO" 2>/dev/null || \
        echo -e "  ${YELLOW}!${NC} La etiqueta '$label' ya existe o no se pudo crear."
    done
}

create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    # Inyectar requisitos globales de DoD en cada Issue para el Agente IA
    local full_body="${body}

---
### 🛡️ Definition of Done (DoD) para el Agente IA
- [ ] **Dart Puro:** 0% dependencias de Flutter. Compilable en Dart Native.
- [ ] **Tests:** Cobertura > 90% en lógica nueva.
- [ ] **Documentación:** Comentarios Dartdoc (\`///\`) en todo el API público.
- [ ] **Changelog:** Actualizar \`CHANGELOG.md\` del paquete afectado.
- [ ] **Análisis:** Sin warnings en \`dart analyze\`.
- [ ] **Melos:** Asegurar que los comandos se ejecuten vía Melos si afectan a múltiples paquetes."

    echo -e "Enviando: ${title}..."

    # Capturamos el error para mostrarlo
    if result=$(gh issue create \
        --repo "$FULL_REPO" \
        --title "$title" \
        --body "$full_body" \
        --label "$labels" 2>&1); then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo -e "${GREEN}[OK]${NC} Issue creado: ${result}"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo -e "${RED}[ERROR]${NC} No se pudo crear: ${title}"
        echo -e "      Motivo: ${RED}${result}${NC}"
    fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

create_labels

echo -e "\n${BLUE}[INFO] Subiendo Historias de Usuario (US)...${NC}\n"

# Historia de Usuario 1
create_issue \
    "[US-01] Monorepo Setup y Primitivas Core" \
    "### Objetivo
Configurar Melos y crear el paquete \`binance_core\` con tipos inmutables base (\`Symbol\`, \`Price\`, \`Quantity\`, \`Result<T,E>\`).
- Configurar \`melos.yaml\`.
- Crear estructura \`packages/\`.
- Configurar GitHub Actions base." \
    "epic:core,jules,priority:high"

# Historia de Usuario 2
create_issue \
    "[US-02] Autenticación y Firma (Ed25519 focus)" \
    "### Objetivo
Implementar la capa de seguridad en \`binance_core\`.
- Soporte Ed25519, RSA y HMAC.
- Percent-encoding estricto (Regla 2026).
- Sincronizador de tiempo del servidor." \
    "epic:auth,jules,priority:high"

# Historia de Usuario 3
create_issue \
    "[US-03] Transporte HTTP con Rate Limiting" \
    "### Objetivo
Crear el cliente HTTP resiliente.
- Tracking de \`X-MBX-USED-WEIGHT\`.
- Circuit Breaker ante 418/429.
- Retry policy con exponential backoff." \
    "epic:transport,jules,priority:high"

# Historia de Usuario 4
create_issue \
    "[US-04] WebSockets (Streams + API)" \
    "### Objetivo
Implementar infraestructura WS.
- Combined Streams (multiplexado).
- WS API con \`session.logon\`.
- Heartbeat watchdog." \
    "epic:transport,jules,priority:medium"

# Historia de Usuario 5
create_issue \
    "[US-05] Abstracción UserDataFeed Unificada" \
    "### Objetivo
Interface única para recibir eventos de cuenta (Spot WS API vs Futures ListenKey).
- Manejo automático de renovación de ListenKey.
- Eventos tipados inmutables." \
    "epic:core,jules,priority:medium"

# Historia de Usuario 6
create_issue \
    "[US-06] Cobertura Binance Spot" \
    "### Objetivo
Paquete \`binance_spot\`.
- REST Market Data & Trading.
- WS Market Streams.
- Soporte para SOR (Smart Order Routing)." \
    "epic:spot,jules,priority:medium"

# Historia de Usuario 7
create_issue \
    "[US-07] Cobertura Binance Margin" \
    "### Objetivo
Paquete \`binance_margin\`.
- Cross & Isolated Margin.
- Préstamos, repagos y transferencias universales." \
    "epic:margin,jules,priority:low"

# Historia de Usuario 8
create_issue \
    "[US-08] Cobertura Binance USD-M Futures" \
    "### Objetivo
Paquete \`binance_futures\`.
- Leverage, Position Mode (Hedge/One-way).
- Mark Price, Funding Rates y Liquidaciones." \
    "epic:futures,jules,priority:medium"

# Historia de Usuario 9
create_issue \
    "[US-09] Taxonomía de Errores y DX" \
    "### Objetivo
Mejorar la experiencia del desarrollador.
- Jerarquía de \`BinanceError\` con códigos oficiales.
- Validadores client-side (LOT_SIZE, etc.).
- Builders fluidos para órdenes." \
    "epic:core,jules,priority:low"

# Historia de Usuario 10
create_issue \
    "[US-10] Infraestructura de Pruebas (Mock Server)" \
    "### Objetivo
Independencia de la red para tests.
- Servidor Shelf local emulando Binance.
- Golden fixtures de respuestas reales.
- Fuzzing de parsers JSON." \
    "epic:testing,jules,priority:medium"

# Historia de Usuario 11
create_issue \
    "[US-11] Ejemplos, Documentación y Release" \
    "### Objetivo
Preparación para pub.dev.
- Ejemplos CLI ejecutables.
- Dartdoc al 100%.
- Pipeline de publicación Melos." \
    "epic:dx-docs,jules,priority:high"

echo -e "\n${GREEN}✔ Proceso finalizado.${NC}"
echo "Issues exitosos: $SUCCESS_COUNT"
echo "Issues fallidos: $FAIL_COUNT"