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
  String get characterTitle => '내 캐릭터';

  @override
  String get characterMyCharacter => '나의 캐릭터';

  @override
  String characterOptionTitle(String part) {
    return '$part 옵션';
  }

  @override
  String get characterTabBasic => '기본형';

  @override
  String get characterTabHair => '머리';

  @override
  String get characterTabEyes => '눈';

  @override
  String get characterTabNose => '코';

  @override
  String get characterTabMouth => '입';

  @override
  String get faceRound => '둥근형';

  @override
  String get faceSquare => '각진형';

  @override
  String get faceInvTriangle => '역삼각형';

  @override
  String get faceHeart => '하트형';

  @override
  String get faceEgg => '계란형';

  @override
  String get faceHex => '육각형';

  @override
  String get hairBob => '단발';

  @override
  String get hairLong => '긴머리';

  @override
  String get hairCurly => '곱슬';

  @override
  String get hairBuzz => '빡빡이';

  @override
  String get hairPony => '포니테일';

  @override
  String get hairMohawk => '모히칸';

  @override
  String get eyeDefault => '기본눈';

  @override
  String get eyeBig => '큰눈';

  @override
  String get eyeSleepy => '졸린눈';

  @override
  String get eyeCrescent => '반달눈';

  @override
  String get eyeStar => '별눈';

  @override
  String get eyeRound => '동그란눈';

  @override
  String get noseSmall => '작은코';

  @override
  String get noseNormal => '보통코';

  @override
  String get noseHigh => '오뚝코';

  @override
  String get noseCute => '귀여운코';

  @override
  String get mouthSmile => '웃음';

  @override
  String get mouthGrin => '미소';

  @override
  String get mouthOpen => '벌린입';

  @override
  String get mouthPout => '삐침';

  @override
  String get createTitle => '동화 만들기';

  @override
  String get createQuestion => '어떤 동화를 만들까요? 📖';

  @override
  String get createDesc => '카테고리를 선택하면 AI가 특별한 동화를 만들어줘요!';

  @override
  String createBtnWithCategory(String category) {
    return '$category 동화 만들기!';
  }

  @override
  String get createBtnNoCategory => '카테고리를 먼저 선택해주세요';

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
  String voiceBadge(String name) {
    return '$name 목소리';
  }

  @override
  String get voiceDad => '아빠';

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
}
