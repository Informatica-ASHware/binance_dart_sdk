// import 'package:ash_binance_api_core/ash_binance_api_core.dart';
// import 'package:ash_binance_api_margin/ash_binance_api_margin.dart';

void main() async {
  // // 1. Initialize the HTTP client
  // final httpClient = BinanceHttpClient();
  //
  // // 2. Initialize the Margin client
  // final marginClient = BinanceMarginClient(httpClient);
  //
  // // 3. Get Cross Margin account information
  // print('Fetching Margin account information...');
  // final result = await marginClient.getAccount();
  //
  // result.match(
  //   (account) {
  //     print('Margin Level: ${account.marginLevel}');
  //     print('Total Assets (BTC): ${account.totalAssetOfBtc}');
  //     for (final asset in account.userAssets) {
  //       if (asset.netAsset > Decimal.zero) {
  //         print('Asset: ${asset.asset.value}, Net: ${asset.netAsset}');
  //       }
  //     }
  //   },
  //   (error) => print('Error: ${error.message}'),
  // );
  //
  // // 4. Close the client
  // httpClient.close();
}
