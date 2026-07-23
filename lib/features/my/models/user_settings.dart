class UserSettings {
  final String locale; // "ko" | "ja"
  final bool textNotiEnabled;
  final bool pushNotiEnabled;

  /// 구독 등급 ("FREE" | "PREMIUM"). 읽기 전용 — 서버가 내려준다.
  /// 누락/구버전 응답은 안전하게 'FREE'로 처리한다.
  final String subscriptionTier;

  /// 권한 등급 ("USER" | "ADMIN"). 읽기 전용 — 서버가 내려준다.
  /// 누락/구버전 응답은 안전하게 'USER'로 처리한다.
  final String role;

  const UserSettings({
    required this.locale,
    required this.textNotiEnabled,
    required this.pushNotiEnabled,
    this.subscriptionTier = 'FREE',
    this.role = 'USER',
  });

  bool get isPremium => subscriptionTier == 'PREMIUM';
  bool get isAdmin => role == 'ADMIN';

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      locale: json['locale'] as String? ?? 'ko',
      textNotiEnabled: json['textNotiEnabled'] as bool? ?? true,
      pushNotiEnabled: json['pushNotiEnabled'] as bool? ?? true,
      subscriptionTier: json['subscriptionTier'] as String? ?? 'FREE',
      role: json['role'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'textNotiEnabled': textNotiEnabled,
      'pushNotiEnabled': pushNotiEnabled,
    };
  }

  UserSettings copyWith({
    String? locale,
    bool? textNotiEnabled,
    bool? pushNotiEnabled,
    String? subscriptionTier,
    String? role,
  }) {
    return UserSettings(
      locale: locale ?? this.locale,
      textNotiEnabled: textNotiEnabled ?? this.textNotiEnabled,
      pushNotiEnabled: pushNotiEnabled ?? this.pushNotiEnabled,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      role: role ?? this.role,
    );
  }
}

enum TermType { service, finance, privacy }

extension TermTypeX on TermType {
  /// 요청 path에 사용하는 소문자 식별자 (service | finance | privacy)
  String get pathName => name;

  /// 서버 응답의 termType 값 (대문자 SERVICE | FINANCE | PRIVACY)
  String get serverValue => name.toUpperCase();

  static TermType? fromServerValue(String value) {
    switch (value.toUpperCase()) {
      case 'SERVICE':
        return TermType.service;
      case 'FINANCE':
        return TermType.finance;
      case 'PRIVACY':
        return TermType.privacy;
      default:
        return null;
    }
  }
}

class TermAgreement {
  final TermType termType;
  final String termVersion;
  final DateTime? agreedAt;

  const TermAgreement({
    required this.termType,
    required this.termVersion,
    this.agreedAt,
  });

  factory TermAgreement.fromJson(Map<String, dynamic> json) {
    return TermAgreement(
      termType: TermTypeX.fromServerValue(json['termType'] as String? ?? '') ??
          TermType.service,
      termVersion: json['termVersion'] as String? ?? '',
      agreedAt: json['agreedAt'] != null
          ? DateTime.tryParse(json['agreedAt'] as String)
          : null,
    );
  }
}
