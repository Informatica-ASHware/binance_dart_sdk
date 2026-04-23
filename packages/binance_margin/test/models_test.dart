import 'package:binance_core/binance_core.dart';
import 'package:binance_margin/binance_margin.dart';
import 'package:test/test.dart';

void main() {
  group('Margin Models', () {
    test('MarginAccount.fromJson', () {
      final json = {
        "borrowEnabled": true,
        "marginLevel": "11.64405625",
        "totalAssetOfBtc": "6.82728461",
        "totalLiabilityOfBtc": "0.58633215",
        "totalNetAssetOfBtc": "6.24095246",
        "tradeEnabled": true,
        "transferEnabled": true,
        "userAssets": [
          {
            "asset": "BTC",
            "borrowed": "0.00000000",
            "free": "0.00499500",
            "interest": "0.00000000",
            "locked": "0.00000000",
            "netAsset": "0.00499500"
          }
        ]
      };

      final account = MarginAccount.fromJson(json);
      expect(account.borrowEnabled, isTrue);
      expect(account.marginLevel, Decimal.parse("11.64405625"));
      expect(account.userAssets.first.asset, Asset("BTC"));
    });

    test('IsolatedMarginAccount.fromJson', () {
      final json = {
        "assets": [
          {
            "baseAsset": {
              "asset": "BTC",
              "borrowEnabled": true,
              "borrowed": "0.00000000",
              "free": "0.00000000",
              "interest": "0.00000000",
              "locked": "0.00000000",
              "netAsset": "0.00000000",
              "netAssetOfBtc": "0.00000000",
              "repayEnabled": true,
              "totalAsset": "0.00000000"
            },
            "quoteAsset": {
              "asset": "USDT",
              "borrowEnabled": true,
              "borrowed": "0.00000000",
              "free": "0.00000000",
              "interest": "0.00000000",
              "locked": "0.00000000",
              "netAsset": "0.00000000",
              "netAssetOfBtc": "0.00000000",
              "repayEnabled": true,
              "totalAsset": "0.00000000"
            },
            "symbol": "BTCUSDT",
            "isolatedCreated": true,
            "enabled": true,
            "marginLevel": "0.00000000",
            "marginLevelStatus": "EXCESSIVE",
            "marginRatio": "0.00000000",
            "indexPrice": "10000.00000000",
            "liquidatePrice": "0.00000000",
            "liquidateRate": "0.00000000",
            "tradeEnabled": true
          }
        ],
        "totalAssetOfBtc": "0.00000000",
        "totalLiabilityOfBtc": "0.00000000",
        "totalNetAssetOfBtc": "0.00000000"
      };

      final account = IsolatedMarginAccount.fromJson(json);
      expect(account.assets.first.symbol, Symbol("BTCUSDT"));
      expect(account.assets.first.baseAsset.asset, Asset("BTC"));
    });

    test('MarginLoan.fromJson', () {
      final json = {
        "asset": "BTC",
        "principal": "0.10000000",
        "status": "COMPLETED",
        "timestamp": 1555056425000,
        "txId": 12345678
      };

      final loan = MarginLoan.fromJson(json);
      expect(loan.asset, Asset("BTC"));
      expect(loan.status, MarginLoanStatus.completed);
    });

    test('MarginRepayment.fromJson', () {
      final json = {
        "amount": "0.10001000",
        "asset": "BTC",
        "interest": "0.00001000",
        "principal": "0.10000000",
        "status": "COMPLETED",
        "timestamp": 1555056425000,
        "txId": 12345678
      };

      final repayment = MarginRepayment.fromJson(json);
      expect(repayment.asset, Asset("BTC"));
      expect(repayment.amount, Decimal.parse("0.10001000"));
    });

    test('LiabilityInterest.fromJson', () {
      final json = {
        "asset": "BTC",
        "interest": "0.00001000",
        "interestRate": "0.00010000",
        "principal": "0.10000000",
        "type": "ON_BORROW",
        "timestamp": 1555056425000
      };

      final interest = LiabilityInterest.fromJson(json);
      expect(interest.asset, Asset("BTC"));
      expect(interest.interest, Decimal.parse("0.00001000"));
    });

    test('CapitalFlow.fromJson', () {
      final json = {
        "id": 1,
        "asset": "BTC",
        "amount": "0.10000000",
        "type": "TRANSFER_IN",
        "timestamp": 1555056425000,
        "tranId": 12345
      };

      final flow = CapitalFlow.fromJson(json);
      expect(flow.id, 1);
      expect(flow.asset, Asset("BTC"));
    });

    test('DustLog.fromJson', () {
      final json = {
        "total": 1,
        "userAssetDribblets": [
          {
            "operateTime": 1615929013000,
            "totalTransferedAmount": "0.001",
            "totalServiceChargeAmount": "0.00002",
            "transId": 12345,
            "userAssetDribbletDetails": [
              {
                "transId": 12345,
                "serviceChargeAmount": "0.00002",
                "amount": "0.001",
                "operateTime": 1615929013000,
                "transferedAmount": "0.00098",
                "fromAsset": "USDT"
              }
            ]
          }
        ]
      };

      final log = DustLog.fromJson(json);
      expect(log.totalCount, 1);
      expect(log.userAssetDribblets.first.transId, 12345);
      expect(log.userAssetDribblets.first.userAssetDribbletDetails.first.fromAsset, Asset("USDT"));
    });
  });
}
