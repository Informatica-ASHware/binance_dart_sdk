import 'dart:io';

/// Mixin to handle integration test logic.
mixin TestnetIntegration {
  /// Whether to run integration tests against the real Testnet.
  /// Set the BINANCE_INTEGRATION_TESTS environment variable to 'true' to
  /// enable.
  bool get shouldRunIntegrationTests =>
      Platform.environment['BINANCE_INTEGRATION_TESTS'] == 'true';

  /// Skip message for integration tests.
  String? get integrationSkipReason => shouldRunIntegrationTests
      ? null
      : 'Integration tests disabled. '
          'Set BINANCE_INTEGRATION_TESTS=true to enable.';

  /// Gets the Testnet API Key from environment.
  String get testnetApiKey =>
      Platform.environment['BINANCE_TESTNET_API_KEY'] ?? '';

  /// Gets the Testnet API Secret from environment.
  String get testnetApiSecret =>
      Platform.environment['BINANCE_TESTNET_API_SECRET'] ?? '';
}
