import 'package:flutter/material.dart';
import 'package:csa_frontend/features/home/models/fairytale.dart';

final localeNotifier = ValueNotifier<Locale>(const Locale('ko'));
final mainTabNotifier = ValueNotifier<int>(1);
final favoritesNotifier = ValueNotifier<List<FairytaleItem>>([]);
final textNotiNotifier = ValueNotifier<bool>(true);
final pushNotiNotifier = ValueNotifier<bool>(true);

/// 결제(PREMIUM) 여부 전역 상태. 신규 오프라인 다운로드 게이트 판단에 사용한다.
/// 앱 시작 시 GET /users/settings 응답으로 채워지며, 기본값은 비결제(false)다.
final isPremiumNotifier = ValueNotifier<bool>(false);

/// 관리자(ADMIN role) 여부 전역 상태. 마이페이지 관리자 진입점 노출 판단에 사용한다.
/// 앱 시작 시 GET /users/settings 응답(role)으로 채워지며, 기본값은 비관리자(false)다.
final isAdminNotifier = ValueNotifier<bool>(false);
