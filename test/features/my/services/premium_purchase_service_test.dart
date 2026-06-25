import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/my/services/premium_purchase_service.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

void main() {
  tearDown(() {
    isPremiumNotifier.value = false;
  });

  test('loadPremiumProduct queries configured premium product id', () async {
    final store = _FakeStore(
      products: const [
        PremiumProduct(
          id: 'premium_monthly',
          title: 'Premium Monthly',
          description: 'Premium',
          price: '₩1,100',
        ),
      ],
    );
    final service = PremiumPurchaseService(store: store, api: _FakeApi());

    final product = await service.loadPremiumProduct();

    expect(store.queriedIds, {'premium_monthly'});
    expect(product?.id, 'premium_monthly');
  });

  test(
    'handlePurchaseUpdate verifies Google purchase and completes it',
    () async {
      isPremiumNotifier.value = false;
      final store = _FakeStore();
      final api = _FakeApi(
        verifyResponse: {
          'platform': 'GOOGLE',
          'productId': 'premium_monthly',
          'status': 'ACTIVE',
          'currentPeriodEnd': '2026-07-25T00:00:00',
          'autoRenew': true,
          'environment': 'SANDBOX',
        },
      );
      final service = PremiumPurchaseService(store: store, api: api);
      final purchase = const PremiumPurchaseDetails(
        productId: 'premium_monthly',
        purchaseToken: 'purchase-token',
        platform: PremiumPurchasePlatform.google,
        status: PremiumPurchaseStatus.purchased,
        pendingCompletePurchase: true,
      );

      await service.handlePurchaseUpdate(purchase);

      expect(api.postPath, '/subscriptions/verify');
      expect(api.postData, {
        'platform': 'GOOGLE',
        'purchaseToken': 'purchase-token',
        'productId': 'premium_monthly',
      });
      expect(store.completedPurchases, [purchase]);
      expect(isPremiumNotifier.value, true);
    },
  );

  test(
    'handlePurchaseUpdate ignores failed purchase without backend call',
    () async {
      final store = _FakeStore();
      final api = _FakeApi();
      final service = PremiumPurchaseService(store: store, api: api);

      await service.handlePurchaseUpdate(
        const PremiumPurchaseDetails(
          productId: 'premium_monthly',
          purchaseToken: 'purchase-token',
          platform: PremiumPurchasePlatform.google,
          status: PremiumPurchaseStatus.error,
        ),
      );

      expect(api.postPath, isNull);
      expect(store.completedPurchases, isEmpty);
    },
  );
}

class _FakeApi implements PremiumPurchaseApiClient {
  final dynamic verifyResponse;

  String? postPath;
  Object? postData;

  _FakeApi({this.verifyResponse});

  @override
  Future<dynamic> post(String path, {Object? data}) async {
    postPath = path;
    postData = data;
    return verifyResponse;
  }
}

class _FakeStore implements PremiumPurchaseStore {
  final List<PremiumProduct> products;
  final List<PremiumPurchaseDetails> completedPurchases = [];

  Set<String>? queriedIds;

  _FakeStore({this.products = const []});

  @override
  Stream<List<PremiumPurchaseDetails>> get purchaseStream =>
      const Stream.empty();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<PremiumProduct>> queryProducts(Set<String> productIds) async {
    queriedIds = productIds;
    return products;
  }

  @override
  Future<void> buy(PremiumProduct product) async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Future<void> completePurchase(PremiumPurchaseDetails purchase) async {
    completedPurchases.add(purchase);
  }
}
