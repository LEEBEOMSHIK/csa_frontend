class UserSettings {
  final String locale; // "ko" | "ja"
  final bool textNotiEnabled;
  final bool pushNotiEnabled;

  const UserSettings({
    required this.locale,
    required this.textNotiEnabled,
    required this.pushNotiEnabled,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      locale: json['locale'] as String? ?? 'ko',
      textNotiEnabled: json['textNotiEnabled'] as bool? ?? true,
      pushNotiEnabled: json['pushNotiEnabled'] as bool? ?? true,
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
  }) {
    return UserSettings(
      locale: locale ?? this.locale,
      textNotiEnabled: textNotiEnabled ?? this.textNotiEnabled,
      pushNotiEnabled: pushNotiEnabled ?? this.pushNotiEnabled,
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
