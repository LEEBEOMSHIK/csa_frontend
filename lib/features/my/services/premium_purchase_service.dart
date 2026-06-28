import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:csa_frontend/shared/services/api_client.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

const String premiumProductId = 'premium_monthly';

enum PremiumPurchasePlatform { google, apple }

extension PremiumPurchasePlatformX on PremiumPurchasePlatform {
  String get serverValue {
    switch (this) {
      case PremiumPurchasePlatform.google:
        return 'GOOGLE';
      case PremiumPurchasePlatform.apple:
        return 'APPLE';
    }
  }
}

enum PremiumPurchaseStatus { pending, purchased, restored, canceled, error }

class PremiumProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final Object? rawDetails;

  const PremiumProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.rawDetails,
  });
}

class PremiumPurchaseDetails {
  final String productId;
  final String purchaseToken;
  final PremiumPurchasePlatform platform;
  final PremiumPurchaseStatus status;
  final bool pendingCompletePurchase;
  final Object? rawDetails;

  const PremiumPurchaseDetails({
    required this.productId,
    required this.purchaseToken,
    required this.platform,
    required this.status,
    this.pendingCompletePurchase = false,
    this.rawDetails,
  });
}

abstract class PremiumPurchaseApiClient {
  Future<dynamic> post(String path, {Object? data});
}

class _DefaultPremiumPurchaseApiClient implements PremiumPurchaseApiClient {
  @override
  Future<dynamic> post(String path, {Object? data}) =>
      ApiClient.instance.post(path, data: data);
}

abstract class PremiumPurchaseStore {
  Stream<List<PremiumPurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<List<PremiumProduct>> queryProducts(Set<String> productIds);
  Future<void> buy(PremiumProduct product);
  Future<void> restorePurchases();
  Future<void> completePurchase(PremiumPurchaseDetails purchase);
}

class PremiumPurchaseException implements Exception {
  final String code;

  const PremiumPurchaseException(this.code);

  @override
  String toString() => 'PremiumPurchaseException($code)';
}

class PremiumPurchaseService {
  final PremiumPurchaseStore _store;
  final PremiumPurchaseApiClient _api;
  final String _productId;
  StreamSubscription<List<PremiumPurchaseDetails>>? _purchaseSubscription;

  PremiumPurchaseService({
    PremiumPurchaseStore? store,
    PremiumPurchaseApiClient? api,
    String productId = premiumProductId,
  }) : _store = store ?? InAppPurchasePremiumStore(),
       _api = api ?? _DefaultPremiumPurchaseApiClient(),
       _productId = productId;

  static final PremiumPurchaseService instance = PremiumPurchaseService();

  void ensureListening() {
    _purchaseSubscription ??= _store.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        unawaited(handlePurchaseUpdate(purchase).catchError((_) {}));
      }
    });
  }

  Future<PremiumProduct?> loadPremiumProduct() async {
    if (!await _store.isAvailable()) {
      return null;
    }
    final products = await _store.queryProducts({_productId});
    return products.where((product) => product.id == _productId).firstOrNull;
  }

  Future<void> buyPremium(PremiumProduct product) async {
    if (product.id != _productId) {
      throw const PremiumPurchaseException('invalid_product');
    }
    await _store.buy(product);
  }

  Future<void> restorePurchases() => _store.restorePurchases();

  Future<void> handlePurchaseUpdate(PremiumPurchaseDetails purchase) async {
    if (purchase.productId != _productId) {
      return;
    }
    switch (purchase.status) {
      case PremiumPurchaseStatus.pending:
      case PremiumPurchaseStatus.canceled:
      case PremiumPurchaseStatus.error:
        return;
      case PremiumPurchaseStatus.purchased:
      case PremiumPurchaseStatus.restored:
        await _verifyPurchase(purchase);
        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
    }
  }

  Future<void> _verifyPurchase(PremiumPurchaseDetails purchase) async {
    final data = await _api.post(
      '/subscriptions/verify',
      data: {
        'platform': purchase.platform.serverValue,
        'purchaseToken': purchase.purchaseToken,
        'productId': purchase.productId,
      },
    );
    isPremiumNotifier.value = _isActiveSubscription(data);
  }

  bool _isActiveSubscription(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return false;
    }
    final status = data['status'] as String? ?? '';
    if (status == 'ACTIVE' || status == 'GRACE') {
      return true;
    }
    final periodEnd = DateTime.tryParse(
      data['currentPeriodEnd'] as String? ?? '',
    );
    return status == 'CANCELED' &&
        periodEnd != null &&
        periodEnd.isAfter(DateTime.now());
  }
}

class InAppPurchasePremiumStore implements PremiumPurchaseStore {
  final InAppPurchase _iap;

  InAppPurchasePremiumStore({InAppPurchase? iap})
    : _iap = iap ?? InAppPurchase.instance;

  @override
  Stream<List<PremiumPurchaseDetails>> get purchaseStream => _iap.purchaseStream
      .map((purchases) => purchases.map(_mapPurchase).toList());

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<List<PremiumProduct>> queryProducts(Set<String> productIds) async {
    final response = await _iap.queryProductDetails(productIds);
    return response.productDetails
        .map(
          (product) => PremiumProduct(
            id: product.id,
            title: product.title,
            description: product.description,
            price: product.price,
            rawDetails: product,
          ),
        )
        .toList();
  }

  @override
  Future<void> buy(PremiumProduct product) async {
    final rawDetails = product.rawDetails;
    if (rawDetails is! ProductDetails) {
      throw const PremiumPurchaseException('invalid_product_details');
    }
    final purchaseParam = PurchaseParam(productDetails: rawDetails);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() => _iap.restorePurchases();

  @override
  Future<void> completePurchase(PremiumPurchaseDetails purchase) async {
    final rawDetails = purchase.rawDetails;
    if (rawDetails is PurchaseDetails) {
      await _iap.completePurchase(rawDetails);
    }
  }

  PremiumPurchaseDetails _mapPurchase(PurchaseDetails purchase) {
    // iOS에서 StoreKit 2가 활성화되면 serverVerificationData는 JWS
    // (header.payload.signature)로 전달되며, 그대로 purchaseToken으로 백엔드에
    // 전송되어 Apple JWS 검증기가 처리한다. Android(Google)는 영향받지 않는다.
    return PremiumPurchaseDetails(
      productId: purchase.productID,
      purchaseToken: purchase.verificationData.serverVerificationData,
      platform: _currentPlatform(),
      status: _mapStatus(purchase.status),
      pendingCompletePurchase: purchase.pendingCompletePurchase,
      rawDetails: purchase,
    );
  }

  PremiumPurchasePlatform _currentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PremiumPurchasePlatform.google;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return PremiumPurchasePlatform.apple;
    }
    throw const PremiumPurchaseException('unsupported_platform');
  }

  PremiumPurchaseStatus _mapStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return PremiumPurchaseStatus.pending;
      case PurchaseStatus.purchased:
        return PremiumPurchaseStatus.purchased;
      case PurchaseStatus.restored:
        return PremiumPurchaseStatus.restored;
      case PurchaseStatus.canceled:
        return PremiumPurchaseStatus.canceled;
      case PurchaseStatus.error:
        return PremiumPurchaseStatus.error;
    }
  }
}
