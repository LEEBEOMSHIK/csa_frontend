// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '우리들의 동화';

  @override
  String get navCharacter => '내 캐릭터';

  @override
  String get navFairytale => '동화';

  @override
  String get navHome => '홈';

  @override
  String get navFavorites => '찜목록';

  @override
  String get navMy => '마이';

  @override
  String get homeTitle => '모두의 동화제작소';

  @override
  String get homeTabStory => '이야기';

  @override
  String get homeTabPicture => '그림조각';

  @override
  String get homeSectionTheme => '주제별 모음';

  @override
  String get homeSectionNew => '신규 출시 목록';

  @override
  String get homeSectionReco => '추천 목록';

  @override
  String get homeMoreBtn => '더보기';

  @override
  String get detailReadBtn => '읽기';

  @override
  String get detailAuthorLabel => '작가';

  @override
  String get detailAgeLabel => '권장 연령';

  @override
  String get detailDurationLabel => '읽기 시간';

  @override
  String get detailMinUnit => '분';

  @override
  String get detailPageUnit => '페이지';

  @override
  String get detailOfflineSave => '오프라인 저장';

  @override
  String get detailDownloadModalTitle => '다운로드 형식 선택';

  @override
  String get detailDownloadSubtitle => '저장 형식을 선택해주세요';

  @override
  String get detailDownloadSlide => '슬라이드 형식';

  @override
  String get detailDownloadSlideDesc => '페이지를 넘기며 읽는 그림책 형태';

  @override
  String get detailDownloadVideo => '영상 형식';

  @override
  String get detailDownloadVideoDesc => '음성과 애니메이션이 포함된 영상';

  @override
  String get formatComingSoon => '준비 중';

  @override
  String get detailDownloadSaveBtn => '저장하기';

  @override
  String get detailDownloadCancel => '취소';

  @override
  String get detailDownloadProgress => '다운로드 중...';

  @override
  String get detailDownloadWaiting => '대기 중';

  @override
  String get detailFavoriteAdded => '찜 목록에 추가되었어요 💛';

  @override
  String get detailFavoriteRemoved => '찜 목록에서 제거되었어요';

  @override
  String get characterTitle => '내 캐릭터';

  @override
  String get characterMyCharacter => '나의 캐릭터';

  @override
  String characterOptionTitle(String part) {
    return '$part 옵션';
  }

  @override
  String get characterTabAll => '전체';

  @override
  String get characterTabHat => '모자';

  @override
  String get characterTabTop => '상의';

  @override
  String get characterTabBottom => '하의';

  @override
  String get characterTabGlasses => '안경';

  @override
  String get characterTabAccessory => '악세서리';

  @override
  String get characterTabFace => '얼굴형';

  @override
  String get characterTabEyes => '눈';

  @override
  String get characterTabNose => '코';

  @override
  String get characterTabMouth => '입';

  @override
  String get createTitle => '동화 만들기';

  @override
  String get createQuestion => '나만의 동화를 만들어봐요! 📖';

  @override
  String get createDesc => '배경, 장르, 성격을 골라주면 AI가 동화를 만들어요!';

  @override
  String createBtnWithCategory(String category) {
    return '$category 동화 만들기!';
  }

  @override
  String get createBtnNoCategory => '카테고리를 먼저 선택해주세요';

  @override
  String get createBtnReady => '동화 만들기!';

  @override
  String get createBtnNotReady => '항목을 모두 선택해주세요';

  @override
  String get createGenerating => 'AI가 동화를 만들고 있어요...';

  @override
  String get createGeneratingSubtitle => '잠시만 기다려주세요 ✨';

  @override
  String get createSuccess => '동화가 완성됐어요! 🎉';

  @override
  String get createError => '동화 생성에 실패했어요';

  @override
  String get createRetry => '다시 시도';

  @override
  String get createClose => '닫기';

  @override
  String get createSectionSetting => '구성 배경';

  @override
  String get createSectionSettingMax => '최대 3개';

  @override
  String get createSectionGenre => '장르';

  @override
  String get createSectionTheme => '이야기 성격';

  @override
  String get createSectionChapter => '챕터 수';

  @override
  String get createSectionFormat => '형식';

  @override
  String get createSectionCharacter => '내 캐릭터';

  @override
  String get createCharacterUse => '사용';

  @override
  String get createCharacterUseDesc => '내 캐릭터가 주인공이 돼요';

  @override
  String get createCharacterSkip => '사용 안함';

  @override
  String get createCharacterSkipDesc => 'AI가 캐릭터를 만들어요';

  @override
  String get createSectionVoice => '읽어줄 목소리';

  @override
  String get createFormatTitle => '어떤 형식으로 만들까요?';

  @override
  String get categoryAdventure => '모험';

  @override
  String get categoryFamily => '가족';

  @override
  String get categoryFantasy => '판타지';

  @override
  String get categoryFriendship => '우정';

  @override
  String get categoryAnimal => '동물';

  @override
  String get categorySea => '바다';

  @override
  String get categorySpace => '우주';

  @override
  String get categoryMagic => '마법';

  @override
  String get categoryForest => '숲·자연';

  @override
  String get categoryKingdom => '왕국·성';

  @override
  String get categorySchool => '학교';

  @override
  String get categoryCity => '도시·마을';

  @override
  String get genreClassic => '클래식';

  @override
  String get genreFolklore => '전래동화';

  @override
  String get genreComedy => '코미디';

  @override
  String get genreMystery => '미스터리';

  @override
  String get genreScifi => 'SF·미래';

  @override
  String get genreMusical => '뮤지컬';

  @override
  String get genreQuiz => '수수께끼';

  @override
  String get genreDaily => '일상';

  @override
  String get genreDream => '꿈·상상';

  @override
  String get genreHorror => '으스스';

  @override
  String get themeMoral => '교훈·도덕';

  @override
  String get themeFriendship => '우정';

  @override
  String get themeFamilyLove => '가족사랑';

  @override
  String get themeCourage => '용기·도전';

  @override
  String get themeGrowth => '성장';

  @override
  String get themeSharing => '나눔·배려';

  @override
  String get themeSelfExpression => '자기표현';

  @override
  String get themeEnvironment => '환경사랑';

  @override
  String get themeGratitude => '감사';

  @override
  String get themeProblemSolving => '문제해결';

  @override
  String get themeCuriosity => '호기심';

  @override
  String get themeForgiveness => '용서·화해';

  @override
  String get chapter3 => '3챕터';

  @override
  String get chapter3Desc => '짧은 이야기';

  @override
  String get chapter5 => '5챕터';

  @override
  String get chapter5Desc => '보통 이야기';

  @override
  String get chapter7 => '7챕터';

  @override
  String get chapter7Desc => '긴 이야기';

  @override
  String get formatText => '텍스트형';

  @override
  String get formatTextDesc => '글로 읽는 동화';

  @override
  String get formatImage => '그림형';

  @override
  String get formatImageDesc => '그림으로 보는 동화';

  @override
  String get favoritesTitle => '찜목록';

  @override
  String favoritesCountBadge(int count) {
    return '$count권';
  }

  @override
  String get favoritesEmpty => '아직 찜한 동화가 없어요';

  @override
  String get favoritesEmptyDesc => '마음에 드는 동화에\n하트를 눌러보세요!';

  @override
  String get favoritesGoBtn => '동화 보러 가기';

  @override
  String get fairytaleListTitle => '기본 동화';

  @override
  String get fairytaleTabClassic => '📚 유명 동화';

  @override
  String get fairytaleTabAi => '🤖 AI 동화';

  @override
  String get fairytaleTabShared => '🌟 공유 동화';

  @override
  String get sharedFairytaleEmpty => '아직 공유된 동화가 없어요';

  @override
  String get sharedFairytaleError => '공유 동화를 불러오지 못했어요';

  @override
  String get sharedFairytaleRetry => '다시 시도';

  @override
  String get fairytaleListError => '동화를 불러오지 못했어요';

  @override
  String get fairytaleListEmpty => '아직 동화가 없어요';

  @override
  String get fairytaleListRetry => '다시 시도';

  @override
  String get fairytaleFilterAll => '전체';

  @override
  String get fairytaleSortLabel => '정렬';

  @override
  String get fairytaleSortLatest => '최신순';

  @override
  String get fairytaleSortRating => '평점순';

  @override
  String get fairytaleSortTitle => '제목순';

  @override
  String voiceBadge(String name) {
    return '$name 목소리';
  }

  @override
  String get voiceDad => '아빠';

  @override
  String get voiceMom => '엄마';

  @override
  String get voiceGrandma => '할머니';

  @override
  String get voiceGrandpa => '할아버지';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsVersion => '현재 버전';

  @override
  String get settingsProfile => '프로필 및 계정';

  @override
  String get settingsSectionActivity => '활동 내역';

  @override
  String get settingsPurchaseHistory => '구매 내역';

  @override
  String get settingsFavoriteHistory => '찜 목록 내역';

  @override
  String get settingsFairytaleConfig => '동화 설정';

  @override
  String get settingsSectionNoti => '혜택 및 이벤트 알림';

  @override
  String get settingsTextNoti => '문자 알림';

  @override
  String get settingsPushNoti => '푸시 알림';

  @override
  String get settingsSectionApp => '앱 설정';

  @override
  String get settingsLanguage => '언어 설정';

  @override
  String get settingsLanguageTitle => '언어 선택';

  @override
  String get settingsSectionDevice => '기기 설정';

  @override
  String get settingsCameraAccess => '카메라 접근';

  @override
  String get settingsSectionPolicy => '약관 및 정책';

  @override
  String get settingsTerms => '서비스 이용약관';

  @override
  String get settingsFinanceTerms => '전자금융거래 이용약관';

  @override
  String get settingsPrivacy => '개인정보처리방침';

  @override
  String get settingsSaveError => '설정을 저장하지 못했어요';

  @override
  String get settingsTermAgreeTitle => '약관 동의';

  @override
  String settingsTermAgreeMessage(String title) {
    return '$title에 동의하시겠어요?';
  }

  @override
  String get settingsTermAgreeConfirm => '동의';

  @override
  String get settingsTermAgreeCancel => '취소';

  @override
  String get settingsTermAgreed => '동의 완료';

  @override
  String get settingsTermAgreeError => '동의 처리에 실패했어요';

  @override
  String get premiumTitle => '프리미엄';

  @override
  String get premiumActiveTitle => 'PREMIUM 이용 중';

  @override
  String get premiumActiveSubtitle => '오프라인 저장 기능을 사용할 수 있어요.';

  @override
  String get premiumFreeTitle => 'FREE 이용 중';

  @override
  String get premiumFreeSubtitle => '프리미엄 구독으로 오프라인 저장을 열 수 있어요.';

  @override
  String get premiumPlanTitle => '월간 구독';

  @override
  String get premiumProductName => '프리미엄 월간 구독';

  @override
  String get premiumLoading => '상품 정보를 불러오는 중...';

  @override
  String get premiumUnavailable => '결제 사용 불가';

  @override
  String get premiumStartButton => '프리미엄 시작';

  @override
  String get premiumRestoreButton => '구매 복원';

  @override
  String get premiumPurchaseStarted => '결제 창을 열었어요';

  @override
  String get premiumRestoreStarted => '구매 복원을 요청했어요';

  @override
  String get premiumPurchaseFailed => '결제를 완료하지 못했어요';

  @override
  String get premiumProductNotFound => '프리미엄 상품을 찾을 수 없어요';

  @override
  String get loginAppTitle => '이야기 숲';

  @override
  String get loginAppSubtitle => 'Children Story Adventure';

  @override
  String get loginWithGoogle => 'Google로 시작';

  @override
  String get loginWithKakao => '카카오톡으로 시작';

  @override
  String get loginWithApple => 'Apple로 시작';

  @override
  String get loginWithYahoo => 'Yahoo! JAPANで始める';

  @override
  String get loginTestSkip => '테스트 (홈으로 이동)';

  @override
  String get loginFooter => '시작과 동시에 이야기 숲의 서비스 약관, 개인정보 취급 방침에 동의하게 됩니다.';

  @override
  String get settingsMyFairytales => '내가 만든 동화';

  @override
  String get myFairytaleTitle => '내가 만든 동화';

  @override
  String get myFairytaleEmpty => '아직 만든 동화가 없어요';

  @override
  String get myFairytaleError => '목록을 불러오지 못했어요';

  @override
  String get myFairytaleRetry => '다시 시도';

  @override
  String get myFairytaleShared => '공유됨';

  @override
  String get myFairytalePrivate => '비공개';

  @override
  String get myFairytaleShare => '공유하기';

  @override
  String get myFairytaleUnshare => '공유 해제';

  @override
  String get myFairytaleDelete => '삭제';

  @override
  String get myFairytaleDeleteTitle => '동화 삭제';

  @override
  String get myFairytaleDeleteMessage => '이 동화를 삭제할까요? 되돌릴 수 없어요.';

  @override
  String get myFairytaleCancel => '취소';

  @override
  String get myFairytaleStatusGenerating => '생성 중';

  @override
  String get myFairytaleStatusFailed => '생성 실패';

  @override
  String myFairytalePageCount(int count) {
    return '$count페이지';
  }

  @override
  String get offlineSaveAction => '오프라인 저장';

  @override
  String get offlineSavedLabel => '저장됨';

  @override
  String get offlineDownloading => '저장 중...';

  @override
  String get offlineCancelAction => '다운로드 취소';

  @override
  String get offlineCancelSuccess => '다운로드를 취소했어요';

  @override
  String get offlineCancelFailed => '다운로드를 취소하지 못했어요';

  @override
  String get offlineDeleteAction => '오프라인 삭제';

  @override
  String get offlineSaveSuccess => '오프라인에 저장했어요';

  @override
  String get offlineSaveFailed => '오프라인 저장에 실패했어요';

  @override
  String get offlineDeleteSuccess => '오프라인 저장을 삭제했어요';

  @override
  String get offlineBanner => '오프라인 상태예요. 저장한 동화만 볼 수 있어요';

  @override
  String get offlineUnavailable => '오프라인에서는 저장한 동화만 볼 수 있어요';

  @override
  String get offlineListEmpty => '오프라인에 저장한 동화가 없어요';

  @override
  String get offlineStorageTitle => '오프라인 저장 동화';

  @override
  String offlineStorageSummary(int count, String size) {
    return '$count개 · $size';
  }

  @override
  String get offlineStorageManageTitle => '저장된 동화';

  @override
  String get offlineStorageEmpty => '저장한 동화가 없어요';

  @override
  String offlineStorageSavedAt(String date) {
    return '$date 저장';
  }

  @override
  String get offlineStorageDeleteAll => '전체 삭제';

  @override
  String get offlineStorageDeleteOne => '삭제';

  @override
  String get offlineStorageDeleteOneTitle => '동화 삭제';

  @override
  String get offlineStorageDeleteOneMessage => '저장한 동화를 삭제할까요?';

  @override
  String get offlineStorageDeleteAllTitle => '전체 삭제';

  @override
  String get offlineStorageDeleteAllMessage => '저장한 동화를 모두 삭제할까요?';

  @override
  String get offlineStorageDeleteAllDone => '모두 삭제했어요';

  @override
  String get offlineStorageCancel => '취소';

  @override
  String get offlinePremiumRequired => '오프라인 저장은 프리미엄 전용 기능이에요';

  @override
  String get offlineLockedAction => '프리미엄 전용';

  @override
  String get characterSaveTitle => '캐릭터 저장';

  @override
  String get characterNameHint => '캐릭터 이름';

  @override
  String get characterSaveAction => '저장';

  @override
  String get characterCancel => '취소';

  @override
  String get characterSaved => '캐릭터를 저장했어요';

  @override
  String get characterSaveError => '저장에 실패했어요';

  @override
  String get characterNone => '없음';

  @override
  String get characterSelectHint => '왼쪽에서 꾸밀 부위를 선택해 보세요';

  @override
  String get ttsSelectVoice => '읽어줄 목소리를 선택하세요';

  @override
  String get ttsNoContent => '읽어줄 내용이 없어요';
}
