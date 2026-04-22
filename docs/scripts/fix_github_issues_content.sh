
#!/bin/bash
# =============================================================================
# binance_dart_sdk — FIX: Restauración de Contenido Original de Issues
# =============================================================================
set -euo pipefail

OWNER="Informatica-ASHware"
REPO="binance_dart_sdk"
FULL_REPO="${OWNER}/${REPO}"

# Requisito de DoD para el Agente IA (Fijo para todos los Issues)
DOD_BLOCK=$(cat <<'EOF'

---
### 🛡️ Definition of Done (DoD) para el Agente IA
- [ ] **Dart Puro:** 0% dependencias de Flutter.
- [ ] **Tests:** Cobertura > 90% en lógica nueva.
- [ ] **Documentación:** Comentarios Dartdoc (`///`) públicos.
- [ ] **Changelog:** Actualizar `CHANGELOG.md`.
- [ ] **Análisis:** Cero warnings en `dart analyze`.
EOF
)

update_issue() {
    local num=$1
    local body=$2
    echo "Actualizando Issue #$num..."
    gh issue edit "$num" --repo "$FULL_REPO" --body "$body$DOD_BLOCK"
}

# --- TEXTOS ORIGINALES ---

# US-01 -> Issue #1
BODY_1=$(cat <<'EOF'
### US 1 — Workspace Monorepo y Núcleo de Primitivas (`binance_core`)

**Objetivo principal y alcance.**
Crear el monorepo gestionado con Melos y construir el paquete `binance_core` con los tipos primitivos inmutables que cualquier consumidor del SDK tocará: `Symbol`, `Asset`, `Price`, `Quantity`, `Percentage`, `Money`, `OrderId`, `ClientOrderId`, `Timestamp`, `Interval` (enums de timeframe alineados con Binance: 1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M). Sealed `Result<T, BinanceError>` (patrón Either, sin agregar `either_dart` como dependencia — se implementa en casa para controlar la superficie). Convenciones de nomenclatura, lints estrictos (`package:very_good_analysis` o equivalente custom), formatter, CI inicial (build + test + analyze + pub score check), y plantillas de `pubspec.yaml` por paquete. Definición del `BinanceEnvironment` enum (`mainnet`, `spotTestnet`, `futuresTestnet`) con sus URLs base correspondientes.

**NO incluye.** Clientes HTTP o WS (épicas 3 y 4), autenticación (US 2), endpoints específicos, ni el paquete adaptador Riverpod hipotético.

**Argumentación técnica y de negocio.**
Sin primitivas tipadas, cada paquete posterior inventaría sus propios `String symbol`, `double price` — reproduciendo el antipatrón del SDK legacy donde todo era `String` o `double` plano. Tipos fuertes atrapan en compile-time errores como "pasé quantity donde iba price" o "mezclé USDT con BUSD en una suma". El monorepo con Melos permite publicar los cuatro paquetes con versionado coordinado o independiente según convenga, mantener un único `CHANGELOG` consolidado y un único CI que corra las pruebas cruzadas. Esta US es la inversión base: todo lo demás se apoya en ella.

**Dependencias.** Ninguna. Primera US del plan.
EOF
)

# US-02 -> Issue #2
BODY_2=$(cat <<'EOF'
### US 2 — Autenticación Multi-Esquema y Firma de Requests

**Objetivo principal y alcance.**
Implementar en `binance_core` la capa de credenciales y firma soportando los **tres esquemas** que Binance admite hoy, con Ed25519 como ciudadano de primera clase:

- **Ed25519** (recomendado oficial, requerido para `session.logon` y WS API User Data Stream de Spot/Margin post-Feb-2026). Uso de `package:cryptography` o `package:pointycastle` para la verificación/firma; evaluación de cuál tiene mejor soporte AOT y menor dependencia transitiva.
- **RSA 2048/4096** (alternativa asimétrica).
- **HMAC-SHA256** (legacy, Binance lo marca deprecated pero sigue funcionando).

Abstracción `BinanceCredentials` sellada con `Ed25519Credentials`, `RsaCredentials`, `HmacCredentials`. Interfaz `RequestSigner` con método `sign(String canonicalPayload) → Signature`. Construcción del payload canónico con **percent-encoding estricto aplicado antes de la firma** (cambio obligatorio Binance 2026-01-15 — el no cumplirlo devuelve `-1022 INVALID_SIGNATURE`). Gestión de `timestamp` y `recvWindow`. `ServerTimeSynchronizer` que consulta `GET /api/v3/time` o `/fapi/v1/time` periódicamente, mantiene un `offset` y un `EWMA` de jitter de red, y expone `adjustedNow()` para uso en signers. Política defensiva: si el `offset` detectado supera un umbral (ej. `recvWindow/2`), emitir advertencia estructurada vía hooks de observabilidad (US 9).

Almacenamiento en memoria con zeroización al disponer (`SecureByteBuffer` que sobreescribe el buffer al `.dispose()`). Cero persistencia en el núcleo — el consumidor decide dónde guarda el secreto.

**NO incluye.** Persistencia segura en disco (responsabilidad del consumidor, típicamente con `flutter_secure_storage` en Flutter o keystore OS en backend). UI para ingreso de credenciales. Rotación automática de keys. Session management de WS API `session.logon` (eso vive en US 4, que lo consume desde esta US).

**Argumentación técnica y de negocio.**
La firma es el gate entre "el SDK funciona" y "el SDK parece funcionar pero todos los requests trading vuelven rechazados". El cambio 2026-01-15 del percent-encoding es el tipo de regresión silenciosa que rompe una librería de un día para otro si no se testea exhaustivamente — las pruebas golden con los ejemplos oficiales de Binance (documentación de SIGNED request) son obligatorias aquí. Ed25519 first es una decisión estratégica: las rutas nuevas de Binance (WS API `session.logon`, WS API User Data Stream Spot/Margin) *solo* aceptan Ed25519. Nacer con HMAC como default condenaría al SDK a retrabajo en 12 meses.

**Dependencias.** US 1.
EOF
)

# US-03 -> Issue #3
BODY_3=$(cat <<'EOF'
### US 3 — Capa de Transporte HTTP con Conciencia de Rate Limits

**Objetivo principal y alcance.**
Implementar en `binance_core` un cliente HTTP resiliente abstracto `BinanceHttpClient` sobre `package:http` (o `package:dio` — decidir en RFC inicial considerando el tradeoff de superficie expuesta vs features). Responsabilidades:

- **Construcción tipada de requests** con builder: método, path, query params, body, autenticación requerida (`public | signed | userStream`), peso estimado.
- **Rate-limit tracker client-side** que parsea `X-MBX-USED-WEIGHT-*` y `X-MBX-ORDER-COUNT-*` de **cada** response y mantiene un estado por ventana (`1m`, `1h`, `1d`, etc.). Backoff preventivo cuando el uso supera un umbral configurable (por defecto 80%).
- **Honrado del header `Retry-After`** ante `429 Too Many Requests` y `418 IP Banned`. En `418` el error es severo — se debe propagar al consumidor y pausar todos los requests firmados por el tiempo indicado.
- **Retry policy con exponential backoff + jitter** solo sobre errores transitorios (timeout, 5xx, error de red, `-1003 TOO_MANY_REQUESTS` explícito). Nunca retry sobre errores de validación (`-1xxx`) ni de trade (`-2xxx`).
- **Circuit breaker** por endpoint: tras N fallos consecutivos, abre el circuito durante T segundos y falla rápido sin pegar al exchange.
- **Cadena de interceptores** pluggable: autenticación, logging, métricas, request ID, custom headers. El consumidor puede añadir interceptores sin modificar el SDK.
- **Soporte explícito de endpoints TRADE, USER_DATA, USER_STREAM, MARKET_DATA** como tipos de seguridad sellados que determinan qué credenciales se aplican.

Expone el cliente como `interface` para que consumers puedan inyectar mocks o decoradores. Base URLs se resuelven desde `BinanceEnvironment` (US 1).

**NO incluye.** Endpoints concretos (épicas 6-8). WebSocket (US 4). Caché de respuestas (deliberadamente fuera — las respuestas trading no son cacheables y la caché de market data la decide el consumidor). Soporte proxy SOCKS5 (puede añadirse en US futura si se demanda).

**Argumentación técnica y de negocio.**
El Legacy auditado en el CryptBot **no tenía tracking de weight client-side**: llamaba REST libremente y confiaba en no recibir ban. Binance puede banear la IP por 2 minutos a 3 días según el patrón de abuso. Un SDK que no conoce su peso consumido es un SDK imposible de operar en alta frecuencia — el consumidor no tiene forma de saber cuánto margen le queda antes del ban. El circuit breaker + backoff preventivo convierten "error cascada que tumba la app" en "degradación controlada". Retry solo sobre transitorios es crítico: retriar un `-2010 NEW_ORDER_REJECTED` genera órdenes duplicadas — bug de seis dígitos.

**Dependencias.** US 1 y 2.
EOF
)

# US-04 -> Issue #4
BODY_4=$(cat <<'EOF'
### US 4 — Capa de Transporte WebSocket (Streams + API)

**Objetivo principal y alcance.**
Implementar en `binance_core` la infraestructura WebSocket, reconociendo que Binance distingue **dos protocolos WS fundamentalmente distintos**:

- **WebSocket Streams** (suscripción unidireccional a feeds). Endpoints `wss://stream.binance.com:9443/ws/<streamName>` (single) o `wss://stream.binance.com:9443/stream?streams=<a>/<b>/<c>` (combined). Sin autenticación para market data; autenticación vía listenKey legacy para user data de Futures.
- **WebSocket API** (request/response bidireccional equivalente al REST, más `session.logon` para autenticación persistente). Endpoints `wss://ws-api.binance.com/ws-api/v3` (Spot) y `wss://ws-fapi.binance.com/ws-fapi/v1` (Futures). Estructura JSON-RPC-like con `id`, `method`, `params`.

Responsabilidades de esta US:

- `WebSocketStreamClient` con **multiplexación de combined streams**: N suscripciones del consumidor se fanea sobre 1 (o pocas) conexiones WS subyacentes, respetando el límite de 1024 streams/conexión de Binance.
- `WebSocketApiClient` con framework request/response (correlación por `id`), soporte de `session.logon` via Ed25519, y `session.status` / `session.logout`. Post-`session.logon`, las requests subsecuentes en el mismo socket omiten `apiKey` y `signature`.
- **Reconexión automática** con exponential backoff + jitter. Estrategia "resume": al reconectar, re-subscribir automáticamente a todos los streams activos y re-ejecutar `session.logon` si estaba activa.
- **Heartbeat watchdog**: si no llega ningún frame en `ping interval × 3`, se considera la conexión muerta y se fuerza reconexión. Pong automático en respuesta a Ping de Binance.
- **Backpressure handling**: si el consumidor no drena el stream, el buffer interno se limita y se emite un evento `StreamLagWarning` estructurado (visible vía hooks de observabilidad, US 9).
- **Stream lifecycle contracts** explícitos: `.listen()` devuelve `StreamSubscription` estándar, `.pause()` pausa el fanout pero no el socket, `.cancel()` libera recursos y cierra conexiones si fueron las últimas.

**NO incluye.** User Data Stream como feature unificada (eso es US 5 — es una abstracción sobre esta base). Streams y métodos específicos por venue (épicas 6-8).

**Argumentación técnica y de negocio.**
El Legacy auditado abría una conexión WS por cada par-intervalo suscrito. Con 10 pares a 5 intervalos = 50 conexiones simultáneas, cada una con su propio overhead de handshake + mantenimiento. Binance permite combined streams precisamente para evitar esto. La reconexión con "resume" es lo que separa un SDK usable en producción de uno que pierde eventos cada vez que el WiFi pestañea. `session.logon` reduce overhead de firma en operaciones de alta frecuencia (un bot haciendo 100 cancels+news por minuto evita 100 firmas). El backpressure handling previene la fuga silenciosa de memoria que ocurre cuando el consumidor es más lento que el productor.

**Dependencias.** US 1, 2, 3 (HTTP se usa para crear listenKey en Futures, y para `session.logon` Futures todavía admite HMAC).
EOF
)

# US-05 -> Issue #5
BODY_5=$(cat <<'EOF'
### US 5 — Abstracción Unificada de User Data Stream

**Objetivo principal y alcance.**
Exponer en `binance_core` una API **única** `UserDataFeed` que oculta la diferencia entre los dos mecanismos que Binance tiene vigentes en 2026:

- **Spot y Margin (post 2026-02-20):** mecanismo WS API con `POST /api/v3/userDataStream.subscribe.signature` + suscripción `userDataStream.subscribe` sobre conexión WS API, vía `session.logon` (Ed25519). Los listenKey REST (`POST /api/v3/userDataStream`, `/sapi/v1/userDataStream`, `/sapi/v1/userDataStream/isolated`) fueron **retirados** y ya no funcionan.
- **USD-M Futures (vigente):** mecanismo clásico `POST /fapi/v1/listenKey` + conexión WS a `wss://fstream.binance.com/ws/<listenKey>` + `PUT /fapi/v1/listenKey` cada 30 min para keep-alive + `DELETE` al cerrar.

La abstracción:

```dart
abstract class UserDataFeed {
  Stream<UserDataEvent> get events;      // flujo unificado tipado
  Future<void> start();                   // elige el mecanismo correcto por venue
  Future<void> stop();                    // libera recursos (deleteListenKey o logout)
  Stream<UserDataFeedStatus> get status;  // connected, reconnecting, authFailed, expired
}
```

Eventos tipados como sealed class jerárquica: `AccountUpdate`, `BalanceUpdate`, `OrderTradeUpdate`, `ListenKeyExpired`, `MarginCall` (Futures), `AccountConfigUpdate`, `LeverageUpdate`, `IsolatedPositionUpdate`. El evento `ListenKeyExpired` dispara el re-issuing automático transparente para el consumidor (con reconciliación de estado — ver §observación abajo).

Gestión automática de:
- Auto-renewal de listenKey para Futures cada 30 minutos (el cache de 60 min es arriesgado; 30 es el pragma de la industria).
- Re-login `session.logon` tras reconexión WS para Spot/Margin.
- Propagación del evento `eventStreamTerminated` como razón explícita en el cierre del stream.

**Observación crítica sobre reconciliación.** Cuando el feed se recupera tras una desconexión larga, **puede haberse perdido eventos**. El consumidor debe saberlo. El SDK expone `UserDataFeedStatus.reconnectedAfterGap(Duration gap)` que señala al consumidor que debe hacer *snapshot reconciliation* con `GET /api/v3/account` / `GET /fapi/v2/account` y `GET /fapi/v2/positionRisk`. El SDK no reconcilia automáticamente — esa política es del consumidor.

**NO incluye.** Reconciliación automática de balances/posiciones (el SDK solo señala la necesidad). Persistencia del último event ID para resume fino (Binance no soporta "resume from sequence" en user data streams). Interpretación de los eventos para trading decisions.

**Argumentación técnica y de negocio.**
El Legacy mezclaba listenKey de Spot Margin con constantes de Futures (ver `isolatedMarginListenKey` usado para Futures en `futures_binance_controller_extension_user.dart`) — herencia de una migración incompleta. Post 2026-02-20, un SDK que siga llamando `POST /sapi/v1/userDataStream` recibe `-21015 ENDPOINT_GONE`. Unificar la abstracción en el SDK protege al consumidor del caos Binance: la biblioteca "hace lo correcto" según venue. La señalización explícita de gaps tras reconexión es lo que separa un SDK que "parece funcionar" de uno que el usuario puede confiar para operar capital.

**Dependencias.** US 1, 2, 3, 4.
EOF
)

# US-06 -> Issue #6
BODY_6=$(cat <<'EOF'
### US 6 — Cobertura Binance Spot (`binance_spot`)

**Objetivo principal y alcance.**
Crear el paquete `binance_spot` que cubre la superficie pública de Binance Spot API:

- **REST Market Data:** `ping`, `time`, `exchangeInfo`, `depth`, `trades`, `historicalTrades`, `aggTrades`, `klines`, `uiKlines`, `avgPrice`, `ticker/24hr`, `ticker/price`, `ticker/bookTicker`, `ticker` (variaciones rolling window).
- **REST Account / Trade:** `order` (POST/DELETE/GET), `order/test`, `order/cancelReplace`, `openOrders`, `allOrders`, `orderList` (OCO post 2025 deprecations), `orderList/oto`, `orderList/otoco` (OPO), `account`, `myTrades`, `rateLimit/order`, `preventedMatches`, `myAllocations`, `account/commission`.
- **REST SOR (Smart Order Routing):** `sor/order`, `sor/order/test`.
- **WS Market Streams:** `aggTrade`, `trade`, `kline_<interval>`, `miniTicker`, `ticker`, `rollingWindowTicker`, `bookTicker`, `avgPrice`, `depth` (diff y partial), `!ticker@arr`, `!miniTicker@arr`. Precaución sobre `!ticker@arr` que se retira 2026-03-26.
- **WS API:** equivalentes de todos los endpoints REST + `session.logon`, `session.status`, `session.logout`, `userDataStream.subscribe`, `userDataStream.unsubscribe`, y las variantes con `signature`.

Cada endpoint expone:
- Modelo de request tipado con validación (símbolos válidos por exchangeInfo, límites de `limit`, enums de `OrderType`, `TimeInForce`, `Side`, `NewOrderRespType`, `SelfTradePreventionMode` incluido el reciente `TRANSFER`).
- Modelo de response tipado inmutable.
- Documentación inline con el peso oficial del endpoint (para consumidores que quieran presupuestar).
- Soporte de `omitZeroBalances` y demás flags recientes.

Soporte de los **schemas 2:0** (permissions en `permissionSets`) y posteriores para `exchangeInfo`.

**NO incluye.** Margin-specific endpoints (`/sapi/v1/margin/*`, US 7). Futures (US 8). Herramientas de portfolio management. Staking, Savings, Pool endpoints del `/sapi/*` que no sean margin.

**Argumentación técnica y de negocio.**
Spot es la superficie base: Margin se apoya en sus primitivas de símbolos y orderbook, y cualquier consumidor del SDK probablemente empiece por Spot (es el caso de uso más simple: price discovery, klines históricos, trading básico). Cubrirlo completo y con tipado estricto antes de pasar a Margin o Futures garantiza que los consumidores pueden adoptar el SDK incluso si solo necesitan Spot, y maximiza el reuso de modelos cuando las otras épicas amplíen.

**Dependencias.** US 1, 2, 3, 4, 5.
EOF
)

# US-07 -> Issue #7
BODY_7=$(cat <<'EOF'
### US 7 — Cobertura Binance Margin Trading (`binance_margin`)

**Objetivo principal y alcance.**
Crear el paquete `binance_margin` que cubre el trading apalancado de Binance en sus dos modos:

- **Cross Margin:** cuenta unificada, colateral compartido entre símbolos.
- **Isolated Margin:** aislado por par (e.g., BTCUSDT tiene su propia cuenta de margin, independiente de ETHUSDT).

Endpoints REST cubiertos bajo `/sapi/v1/margin/*`:

- **Loans:** `borrow-repay` (POST/GET), `borrow-repay/history`, `maxBorrowable`, `maxTransferable`, `interestHistory`, `interestRateHistory`, `forceLiquidationRec`.
- **Transfers:** `transfer` (margin main transfer is deprecated; use Universal Transfer), `isolated/transfer`, `isolated/account` (info + enable/disable).
- **Trading:** `order` (POST/DELETE/GET), `openOrders`, `allOrders`, `order/cancelReplace`, `orderList` (OCO), `allOrderList`, `openOrderList`, `myTrades`.
- **Account:** `account`, `isolated/account`, `allPairs`, `isolated/allPairs`, `tradeCoeff` (risk levels), `asset`, `dustLog`, `exchange-small-liability`, `capital-flow`.
- **Events User Data:** integrados en el `UserDataFeed` unificado de la US 5. Los eventos específicos de Margin (`outboundAccountPosition` con flags de margin, `balanceUpdate`, `executionReport` con `isMargin=true`) se distinguen por tipos sellados en `binance_margin`.

Modelos específicos: `MarginAccount`, `IsolatedMarginAccount`, `IsolatedMarginPair`, `MarginLoan`, `MarginRepayment`, `LiabilityInterest`, `MarginRiskLevel`, `MarginSideEffect` (enum: `NO_SIDE_EFFECT`, `MARGIN_BUY`, `AUTO_REPAY`, `AUTO_BORROW_REPAY`).

**NO incluye.** Portfolio Margin (`/sapi/v1/portfolio/*`). Leveraged Tokens. Liquid Swap. COIN-M Futures. Cross-collateral features fuera de Binance Margin estándar.

**Argumentación técnica y de negocio.**
Margin es el cuarto modo de ejecución que el SDK debe exponer con dignidad. El Legacy auditado arrastraba términos de Margin (`marginSideEffectType`, `MarginOcoOrder`) dentro del controller de Futures — herencia de una migración Spot→Futures incompleta. Separar `binance_margin` como paquete propio evita contaminación simétrica: un consumidor que solo hace Futures no tiene que arrastrar el modelo de Cross Margin, y viceversa. Margin es también donde los errores de tipado tienen más costo (una orden con `marginSideEffect=MARGIN_BUY` mal puesta puede abrir un loan no deseado); el tipado estricto del SDK es valor puro.

**Dependencias.** US 1, 2, 3, 4, 5, 6 (Margin reutiliza modelos de Symbol y Order de Spot cuando aplica).
EOF
)

# US-08 -> Issue #8
BODY_8=$(cat <<'EOF'
### US 8 — Cobertura Binance USD-M Futures (`binance_futures`)

**Objetivo principal y alcance.**
Crear el paquete `binance_futures` cubriendo Binance USD-M Futures (Derivatives Trading), que opera en un servidor distinto (`fapi.binance.com`, `fstream.binance.com`, `ws-fapi.binance.com`) con su propio conjunto de endpoints y sus propias idiosincrasias:

- **REST Market Data:** `ping`, `time`, `exchangeInfo`, `depth`, `trades`, `historicalTrades`, `aggTrades`, `klines`, `continuousKlines`, `indexPriceKlines`, `markPriceKlines`, `premiumIndex`, `fundingRate`, `ticker/24hr`, `ticker/price`, `ticker/bookTicker`, `openInterest`, `openInterestHist`, `topLongShortAccountRatio`, `topLongShortPositionRatio`, `globalLongShortAccountRatio`, `takerlongshortRatio`, `basis`, `indexInfo`, `constituents`.
- **REST Trade:** `order` (POST/DELETE/GET), `batchOrders`, `order/test`, `openOrders`, `allOrders`, `userTrades`, `income`, `forceOrders`, `rateLimit/order`.
- **REST Account:** `account`, `balance`, `positionRisk`, `positionMargin`, `positionMargin/history`, `leverage` (POST), `marginType` (POST), `multiAssetsMargin` (POST), `commissionRate`, `pmAccountInfo` (Portfolio Margin info).
- **REST User Data Stream (legacy listenKey todavía vigente):** `POST/PUT/DELETE /fapi/v1/listenKey`. Gestionado internamente por el `UserDataFeed` de US 5.
- **WS Market Streams:** `aggTrade`, `markPrice`, `markPrice@arr` (all symbols, configurable 1s/3s), `kline_<interval>`, `continuousKline`, `miniTicker`, `ticker`, `bookTicker`, `forceOrder` (liquidations), `liquidationOrder`, `depth` (diff y partial con 100ms/500ms options), `contractInfo`, `indexPrice`, `assetIndex`.
- **WS API:** `session.logon`, trading endpoints como WS API, user data stream via WS API (pendiente de rollout completo en Futures).
- **Eventos User Data específicos:** `ACCOUNT_UPDATE` con balance y posición, `ORDER_TRADE_UPDATE`, `MARGIN_CALL`, `ACCOUNT_CONFIG_UPDATE` (leverage + multi-asset margin status), `listenKeyExpired`, `TRADE_LITE`, `GRID_UPDATE` (si aplica), `CONDITIONAL_ORDER_TRIGGER_REJECT` (deprecado 2025-12-15).

Modelos específicos: `FuturesPosition` (con `isolated`, `marginType`, `entryPrice`, `markPrice`, `unRealizedProfit`, `liquidationPrice`, `leverage`, `maxNotionalValue`, `isolatedMargin`, `positionSide` para modo hedge), `FundingRate`, `MarkPrice`, `PremiumIndex`, `AdlQuantile`, `Leverage`, `MarginType` (`ISOLATED`, `CROSS`), `PositionSide` (`BOTH`, `LONG`, `SHORT` en modo hedge).

**NO incluye.** COIN-M Futures (`dapi.binance.com`). Options (`eapi.binance.com`). Portfolio Margin Pro (fuera de alcance declarado). BFUSD (migrado a Binance Earn el 2025-08-13 — endpoints deprecados).

**Argumentación técnica y de negocio.**
Futuros es el modo de ejecución más complejo: tiene leverage, dos modos de margin, dos modos de posición (one-way vs hedge), liquidación automática, funding rate, ADL, mark price vs last price. Cada uno de estos conceptos debe tener su tipo sellado — nada de `String marginType = "ISOLATED"`. Separar `binance_futures` del paquete Spot refleja que el servidor es literalmente distinto (distinto host, distinto rate limit, distinto calendario de deprecaciones) — acoplarlos forzaría versionado conjunto que cada vez que Binance rompa un endpoint de un lado, el otro también hace release. Adicionalmente, el listenKey de Futures **sigue vigente** mientras el de Spot/Margin fue retirado; esa divergencia obliga a paquetes separados.

**Dependencias.** US 1, 2, 3, 4, 5. No depende de `binance_spot` ni `binance_margin` (modelos específicos de Futures se definen propios).
EOF
)

# US-09 -> Issue #9
BODY_9=$(cat <<'EOF'
### US 9 — Taxonomía de Errores, Validación de Entradas y Experiencia de Desarrollo (DX)

**Objetivo principal y alcance.**
Capa transversal de ergonomía y corrección, consolidada principalmente en `binance_core` con extensiones en cada paquete de venue.

- **Jerarquía de errores sellada** (`sealed class BinanceError`):
    - `BinanceNetworkError` (timeout, conexión rechazada, socket cerrado).
    - `BinanceHttpError(statusCode)` con mapeo explícito de `400, 401, 403, 429, 418, 5xx`.
    - `BinanceApiError(code, message)` con sub-jerarquía para el catálogo de error codes de Binance: `BinanceSignatureError(-1022)`, `BinanceTimestampError(-1021)`, `BinanceRateLimitError(-1003)`, `BinanceInvalidSymbol(-1121)`, `BinanceOrderRejected(-2010)`, `BinanceCancelRejected(-2011)`, `BinanceOrderNotFound(-2013)`, `BinanceInvalidApiKey(-2014, -2015)`, `BinanceEndpointGone(-21015)`, `BinanceAccountInactive(-4109)`, etc. Catálogo completo mantenido en un único archivo de referencia con enlace al spec oficial.
    - `BinanceValidationError` emitido por los validadores client-side **antes** de hacer llamadas innecesarias al exchange.
    - `BinanceAuthError` (credenciales inválidas detectadas localmente, firma imposible).
- **Validadores client-side** que, dados el `ExchangeInfo` cacheado, validan:
    - Precisión de `price` y `quantity` contra los filtros `PRICE_FILTER`, `LOT_SIZE`, `MIN_NOTIONAL`, `MARKET_LOT_SIZE`.
    - `timeInForce` compatible con `orderType`.
    - `quoteOrderQty` solo para MARKET.
    - `stopPrice` requerido para STOP_LOSS/TAKE_PROFIT variants.
    - Percentajes de desviación de precio contra `PERCENT_PRICE_BY_SIDE` si aplica.
- **Builders fluidos** para construir órdenes complejas (OCO, OTOCO/OPO) con validación encadenada:
  ```dart
  final order = SpotOrderBuilder.limit()
    .symbol('BTCUSDT')
    .side(OrderSide.buy)
    .quantity(Quantity.parse('0.001'))
    .price(Price.parse('65000'))
    .timeInForce(TimeInForce.gtc)
    .clientOrderId('my-order-1')
    .build();  // returns Result<SpotOrder, BinanceValidationError>
  ```
- **`toString()` y extensions de debug** en todos los errores con información suficiente para diagnóstico sin exponer credenciales.
- **Hooks de observabilidad** (no framework-specific): `BinanceHttpClient` y clientes WS aceptan una `BinanceTelemetrySink` opcional que recibe eventos tipados (`RequestSent`, `ResponseReceived`, `RetryAttempt`, `RateLimitHit`, `WebSocketReconnecting`, `SignatureComputed`). El consumidor enchufa su propio sink (consola, OpenTelemetry, etc.). **Sin imponer Riverpod ni ningún logger específico.**

**NO incluye.** Exportadores concretos de telemetría (OTLP, Prometheus — son paquetes adaptadores aparte). Internacionalización de mensajes de error (los mensajes quedan en inglés, alineados con Binance).

**Argumentación técnica y de negocio.**
Esta US es el multiplicador de adopción. Un SDK que devuelve `String msg = "error"` obliga al consumidor a hacer parsing de strings — antipatrón que el Legacy sufría. Errores tipados permiten `switch` exhaustivo y manejo diferencial (`BinanceRateLimitError` → backoff; `BinanceOrderRejected` → log y no retry; `BinanceSignatureError` → bug crítico, fail fast). Validación client-side elimina una clase entera de roundtrips fallidos: si el `price` tiene más decimales que `PRICE_FILTER.tickSize` permite, el SDK lo rechaza antes de quemar weight. Los builders fluidos reducen el ruido en código cliente (el Legacy construía `Order` con 18 argumentos posicionales, ilegible). Los hooks de observabilidad permiten producirizar sin tocar el core.

**Dependencias.** US 1, 2, 3 (tipos base). Se alimenta y se amplía con cada US de venue (6, 7, 8) a medida que descubren errores específicos.
EOF
)

# US-10 -> Issue #10
BODY_10=$(cat <<'EOF'
### US 10 — Infraestructura de Pruebas y Suite de Cumplimiento

**Objetivo principal y alcance.**
Construir el arsenal de testing que garantiza que el SDK se comporta según lo especificado, de forma reproducible, sin depender de la red para CI. Tres capas:

- **Mock server local (`tools/mock_server`)**: servidor HTTP+WS escrito en Dart (Shelf + Shelf Web Socket) que emula el API de Binance. Carga fixtures JSON organizados por endpoint. Permite inyectar latencia, errores deliberados, rate-limit simulado con los headers `X-MBX-USED-WEIGHT-*` / `Retry-After` correctos. Los tests unitarios apuntan a este mock, no a Binance real.
- **Golden fixtures**: capturas reales de respuestas de Binance (public endpoints) y testnet (signed endpoints) guardadas bajo `test/fixtures/` para tests de deserialización. Regeneración semi-automática cuando Binance publica cambios de schema.
- **Suite de conformidad con firma**: vectores de prueba oficiales de Binance para HMAC, Ed25519 y RSA (documentados en el spec). El SDK debe producir exactamente las mismas firmas que los ejemplos del spec, incluyendo los ejemplos con símbolos no-ASCII (`１２３４５６` — caso de percent-encoding que Binance explícitamente documenta).
- **Tests de integración contra Spot Testnet, Futures Testnet** (ejecutados solo en CI nocturno, no en PR checks, porque testnet tiene cuotas y downtime periódico). Matriz de endpoints críticos: crear orden, consultar, cancelar, recibir execution report vía user data stream, reconectar tras drop simulado.
- **Property-based tests** (con `package:glados` o similar) sobre:
    - Construcción y parsing de payloads canónicos (roundtrip propiedad: `sign(sign.buildPayload(params)) → signature` y `verify(signature, params) → ok`).
    - Codificación/decodificación JSON de modelos (`model.toJson().fromJson() == model`).
    - Builders de órdenes (validación rechaza todo input inválido, acepta todo input válido).
- **Fuzzing** dirigido a los parsers de response: malformed JSON, campos faltantes, tipos incorrectos. El SDK nunca debe crashear por respuesta inesperada — debe devolver `BinanceApiError` o `BinanceDeserializationError`.

**NO incluye.** Benchmarks de rendimiento (opcional en US futura). Tests end-to-end con trading real (responsabilidad del consumidor, con sus credenciales reales).

**Argumentación técnica y de negocio.**
Un SDK de trading sin tests de firma automáticos es un accidente esperando a ocurrir — el cambio de percent-encoding de 2026-01-15 es exactamente el tipo de regresión que rompe librerías silenciosamente. Si el SDK no verifica sus firmas contra los vectores oficiales del spec en cada CI run, no puede detectar que Binance cambió una coma. El mock server local es lo que hace posible CI rápido (< 30s) sin depender de testnet; y el nightly integration test contra testnet real es lo que detecta drift del spec. Los property-based tests cubren corner cases que el tester humano no imagina (símbolos con Unicode, fracciones decimales extremas, timestamps en microsegundos).

**Dependencias.** Todas las US anteriores (la suite crece con cada endpoint cubierto). La US se "cierra" cuando la suite tiene ≥85% de cobertura de líneas y 100% de cobertura de signatures golden.
EOF
)

# US-11 -> Issue #11
BODY_11=$(cat <<'EOF'
### US 11 — Documentación, Ejemplos Ejecutables y Pipeline de Publicación

**Objetivo principal y alcance.**
Convertir el código del monorepo en un producto publicable y adoptable. Cuatro ejes:

- **Documentación Dartdoc al 100%** en API pública. Cada clase pública, cada método público, cada campo de modelo tiene docstring con: qué hace, parámetros, valores retornados, errores posibles, peso del endpoint (para cliente REST), ejemplo mínimo inline. `dartdoc` se corre en CI; PR que baje cobertura de docs por debajo del umbral se rechaza.
- **README por paquete** (cuatro READMEs, más el del root) con: qué hace, quick-start de 10 líneas, ejemplo de autenticación Ed25519, matriz de endpoints cubiertos con link al spec oficial, sección de "Known differences vs official spec" (si las hubiere), changelog resumido.
- **Ejemplos ejecutables en `examples/`** (Dart CLI apps, no tests):
    - `spot_market_watch/`: se conecta al combined stream de bookTicker de 5 pares configurables por CLI args, imprime el mejor bid/ask en consola con código ANSI de color, reconecta automáticamente.
    - `margin_cross_trade/`: workflow completo — login Ed25519, consulta de `marginAccount`, abre un LIMIT BUY sobre BTCUSDT con `MARGIN_BUY` sideEffect, monitorea vía user data stream hasta fill, repay automático al cierre.
    - `futures_position_monitor/`: suscribe al mark price stream + user data stream, imprime cada segundo: unrealized PnL, liquidation price, margin ratio. Alerta en stderr si margin ratio > 80%.
    - Opcionalmente: `notebook/` con ejemplos en `.dart` importables desde DartPad cuando sea posible.
- **Pipeline de publicación a pub.dev**:
    - Versionado semántico estricto por paquete (cada paquete tiene su propia versión; los paquetes de venue dependen de `binance_core ^x.y.z` con constraint de rango).
    - Melos script `bump` que propaga cambios de versión coordinadamente cuando `binance_core` sube major.
    - Changelog automático desde Conventional Commits (con `package:conventional_commit` o equivalente custom en Dart).
    - CI que bloquea publicación si: tests fallan, dartdoc coverage < umbral, `dart pub publish --dry-run` da warnings, pub score proyectado < 130/140.
    - Firma del tag Git con GPG. Protección de rama `main`.
    - Binary lockstep entre `CHANGELOG.md` versionado y las notas del release Git.
- **Matriz de soporte declarada**: qué versiones de Dart SDK, qué SOs, qué plataformas (VM, AOT, Native; Web no aplica por limitaciones de WebSocket desde navegador con headers custom).
- **Documento `SECURITY.md`** con política de disclosure de vulnerabilidades y `CONTRIBUTING.md` con guía de pull requests.

**NO incluye.** Traducción a otros idiomas. Sitio web de documentación con tema custom (el dartdoc default es suficiente; si se quiere rebrand, US futura). Tutoriales extensos tipo "construye tu primer bot" — esos son contenido de blog/curso, no documentación del SDK.

**Argumentación técnica y de negocio.**
Un SDK sin docs es un SDK abandonado. Ejemplos ejecutables son la forma más rápida en que un desarrollador evalúa si un paquete le sirve — si en 5 minutos no tiene BTC price streameando en su terminal, se va al siguiente paquete. La política de versionado semántico estricto protege al consumidor: el bot de un cliente no debe romperse porque `binance_spot` pasó de `1.4.x` a `1.5.0` por un change interno. La automatización del pipeline publica todo o nada de forma reproducible — no hay releases "parcheados a mano" desde la laptop del mantenedor. Esta US cierra el ciclo: de "código que funciona" a "producto que alguien adopta".

**Dependencias.** Todas las US anteriores. Se ejecuta en paralelo desde el día 1 en forma incremental (cada US contribuye sus docs y ejemplos), pero la consolidación y el pipeline de release son la guardia final.
EOF
)

# Ejecutar actualizaciones
#update_issue 1 "$BODY_1"
update_issue 2 "$BODY_2"
update_issue 3 "$BODY_3"
update_issue 4 "$BODY_4"
update_issue 5 "$BODY_5"
update_issue 6 "$BODY_6"
update_issue 7 "$BODY_7"
update_issue 8 "$BODY_8"
update_issue 9 "$BODY_9"
update_issue 10 "$BODY_10"
update_issue 11 "$BODY_11"

echo "✅ Restauración completada. Jules ahora tiene el contrato técnico completo."
