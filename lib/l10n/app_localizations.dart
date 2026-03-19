import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'우리들의 동화'**
  String get appTitle;

  /// No description provided for @navCharacter.
  ///
  /// In ko, this message translates to:
  /// **'내 캐릭터'**
  String get navCharacter;

  /// No description provided for @navFairytale.
  ///
  /// In ko, this message translates to:
  /// **'동화'**
  String get navFairytale;

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In ko, this message translates to:
  /// **'찜목록'**
  String get navFavorites;

  /// No description provided for @navMy.
  ///
  /// In ko, this message translates to:
  /// **'마이'**
  String get navMy;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'모두의 동화제작소'**
  String get homeTitle;

  /// No description provided for @homeTabStory.
  ///
  /// In ko, this message translates to:
  /// **'이야기'**
  String get homeTabStory;

  /// No description provided for @homeTabPicture.
  ///
  /// In ko, this message translates to:
  /// **'그림조각'**
  String get homeTabPicture;

  /// No description provided for @homeSectionTheme.
  ///
  /// In ko, this message translates to:
  /// **'주제별 모음'**
  String get homeSectionTheme;

  /// No description provided for @homeSectionNew.
  ///
  /// In ko, this message translates to:
  /// **'신규 출시 목록'**
  String get homeSectionNew;

  /// No description provided for @homeSectionReco.
  ///
  /// In ko, this message translates to:
  /// **'추천 목록'**
  String get homeSectionReco;

  /// No description provided for @homeMoreBtn.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get homeMoreBtn;

  /// No description provided for @characterTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 캐릭터'**
  String get characterTitle;

  /// No description provided for @characterMyCharacter.
  ///
  /// In ko, this message translates to:
  /// **'나의 캐릭터'**
  String get characterMyCharacter;

  /// No description provided for @characterOptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'{part} 옵션'**
  String characterOptionTitle(String part);

  /// No description provided for @characterTabBasic.
  ///
  /// In ko, this message translates to:
  /// **'기본형'**
  String get characterTabBasic;

  /// No description provided for @characterTabHair.
  ///
  /// In ko, this message translates to:
  /// **'머리'**
  String get characterTabHair;

  /// No description provided for @characterTabEyes.
  ///
  /// In ko, this message translates to:
  /// **'눈'**
  String get characterTabEyes;

  /// No description provided for @characterTabNose.
  ///
  /// In ko, this message translates to:
  /// **'코'**
  String get characterTabNose;

  /// No description provided for @characterTabMouth.
  ///
  /// In ko, this message translates to:
  /// **'입'**
  String get characterTabMouth;

  /// No description provided for @faceRound.
  ///
  /// In ko, this message translates to:
  /// **'둥근형'**
  String get faceRound;

  /// No description provided for @faceSquare.
  ///
  /// In ko, this message translates to:
  /// **'각진형'**
  String get faceSquare;

  /// No description provided for @faceInvTriangle.
  ///
  /// In ko, this message translates to:
  /// **'역삼각형'**
  String get faceInvTriangle;

  /// No description provided for @faceHeart.
  ///
  /// In ko, this message translates to:
  /// **'하트형'**
  String get faceHeart;

  /// No description provided for @faceEgg.
  ///
  /// In ko, this message translates to:
  /// **'계란형'**
  String get faceEgg;

  /// No description provided for @faceHex.
  ///
  /// In ko, this message translates to:
  /// **'육각형'**
  String get faceHex;

  /// No description provided for @hairBob.
  ///
  /// In ko, this message translates to:
  /// **'단발'**
  String get hairBob;

  /// No description provided for @hairLong.
  ///
  /// In ko, this message translates to:
  /// **'긴머리'**
  String get hairLong;

  /// No description provided for @hairCurly.
  ///
  /// In ko, this message translates to:
  /// **'곱슬'**
  String get hairCurly;

  /// No description provided for @hairBuzz.
  ///
  /// In ko, this message translates to:
  /// **'빡빡이'**
  String get hairBuzz;

  /// No description provided for @hairPony.
  ///
  /// In ko, this message translates to:
  /// **'포니테일'**
  String get hairPony;

  /// No description provided for @hairMohawk.
  ///
  /// In ko, this message translates to:
  /// **'모히칸'**
  String get hairMohawk;

  /// No description provided for @eyeDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본눈'**
  String get eyeDefault;

  /// No description provided for @eyeBig.
  ///
  /// In ko, this message translates to:
  /// **'큰눈'**
  String get eyeBig;

  /// No description provided for @eyeSleepy.
  ///
  /// In ko, this message translates to:
  /// **'졸린눈'**
  String get eyeSleepy;

  /// No description provided for @eyeCrescent.
  ///
  /// In ko, this message translates to:
  /// **'반달눈'**
  String get eyeCrescent;

  /// No description provided for @eyeStar.
  ///
  /// In ko, this message translates to:
  /// **'별눈'**
  String get eyeStar;

  /// No description provided for @eyeRound.
  ///
  /// In ko, this message translates to:
  /// **'동그란눈'**
  String get eyeRound;

  /// No description provided for @noseSmall.
  ///
  /// In ko, this message translates to:
  /// **'작은코'**
  String get noseSmall;

  /// No description provided for @noseNormal.
  ///
  /// In ko, this message translates to:
  /// **'보통코'**
  String get noseNormal;

  /// No description provided for @noseHigh.
  ///
  /// In ko, this message translates to:
  /// **'오뚝코'**
  String get noseHigh;

  /// No description provided for @noseCute.
  ///
  /// In ko, this message translates to:
  /// **'귀여운코'**
  String get noseCute;

  /// No description provided for @mouthSmile.
  ///
  /// In ko, this message translates to:
  /// **'웃음'**
  String get mouthSmile;

  /// No description provided for @mouthGrin.
  ///
  /// In ko, this message translates to:
  /// **'미소'**
  String get mouthGrin;

  /// No description provided for @mouthOpen.
  ///
  /// In ko, this message translates to:
  /// **'벌린입'**
  String get mouthOpen;

  /// No description provided for @mouthPout.
  ///
  /// In ko, this message translates to:
  /// **'삐침'**
  String get mouthPout;

  /// No description provided for @createTitle.
  ///
  /// In ko, this message translates to:
  /// **'동화 만들기'**
  String get createTitle;

  /// No description provided for @createQuestion.
  ///
  /// In ko, this message translates to:
  /// **'나만의 동화를 만들어봐요! 📖'**
  String get createQuestion;

  /// No description provided for @createDesc.
  ///
  /// In ko, this message translates to:
  /// **'배경, 장르, 성격을 골라주면 AI가 동화를 만들어요!'**
  String get createDesc;

  /// No description provided for @createBtnWithCategory.
  ///
  /// In ko, this message translates to:
  /// **'{category} 동화 만들기!'**
  String createBtnWithCategory(String category);

  /// No description provided for @createBtnNoCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 먼저 선택해주세요'**
  String get createBtnNoCategory;

  /// No description provided for @createBtnReady.
  ///
  /// In ko, this message translates to:
  /// **'동화 만들기!'**
  String get createBtnReady;

  /// No description provided for @createBtnNotReady.
  ///
  /// In ko, this message translates to:
  /// **'항목을 모두 선택해주세요'**
  String get createBtnNotReady;

  /// No description provided for @createSectionSetting.
  ///
  /// In ko, this message translates to:
  /// **'구성 배경'**
  String get createSectionSetting;

  /// No description provided for @createSectionSettingMax.
  ///
  /// In ko, this message translates to:
  /// **'최대 3개'**
  String get createSectionSettingMax;

  /// No description provided for @createSectionGenre.
  ///
  /// In ko, this message translates to:
  /// **'장르'**
  String get createSectionGenre;

  /// No description provided for @createSectionTheme.
  ///
  /// In ko, this message translates to:
  /// **'이야기 성격'**
  String get createSectionTheme;

  /// No description provided for @createSectionChapter.
  ///
  /// In ko, this message translates to:
  /// **'챕터 수'**
  String get createSectionChapter;

  /// No description provided for @createSectionFormat.
  ///
  /// In ko, this message translates to:
  /// **'형식'**
  String get createSectionFormat;

  /// No description provided for @createSectionCharacter.
  ///
  /// In ko, this message translates to:
  /// **'내 캐릭터'**
  String get createSectionCharacter;

  /// No description provided for @createCharacterUse.
  ///
  /// In ko, this message translates to:
  /// **'사용'**
  String get createCharacterUse;

  /// No description provided for @createCharacterUseDesc.
  ///
  /// In ko, this message translates to:
  /// **'내 캐릭터가 주인공이 돼요'**
  String get createCharacterUseDesc;

  /// No description provided for @createCharacterSkip.
  ///
  /// In ko, this message translates to:
  /// **'사용 안함'**
  String get createCharacterSkip;

  /// No description provided for @createCharacterSkipDesc.
  ///
  /// In ko, this message translates to:
  /// **'AI가 캐릭터를 만들어요'**
  String get createCharacterSkipDesc;

  /// No description provided for @createSectionVoice.
  ///
  /// In ko, this message translates to:
  /// **'읽어줄 목소리'**
  String get createSectionVoice;

  /// No description provided for @categoryAdventure.
  ///
  /// In ko, this message translates to:
  /// **'모험'**
  String get categoryAdventure;

  /// No description provided for @categoryFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족'**
  String get categoryFamily;

  /// No description provided for @categoryFantasy.
  ///
  /// In ko, this message translates to:
  /// **'판타지'**
  String get categoryFantasy;

  /// No description provided for @categoryFriendship.
  ///
  /// In ko, this message translates to:
  /// **'우정'**
  String get categoryFriendship;

  /// No description provided for @categoryAnimal.
  ///
  /// In ko, this message translates to:
  /// **'동물'**
  String get categoryAnimal;

  /// No description provided for @categorySea.
  ///
  /// In ko, this message translates to:
  /// **'바다'**
  String get categorySea;

  /// No description provided for @categorySpace.
  ///
  /// In ko, this message translates to:
  /// **'우주'**
  String get categorySpace;

  /// No description provided for @categoryMagic.
  ///
  /// In ko, this message translates to:
  /// **'마법'**
  String get categoryMagic;

  /// No description provided for @categoryForest.
  ///
  /// In ko, this message translates to:
  /// **'숲·자연'**
  String get categoryForest;

  /// No description provided for @categoryKingdom.
  ///
  /// In ko, this message translates to:
  /// **'왕국·성'**
  String get categoryKingdom;

  /// No description provided for @categorySchool.
  ///
  /// In ko, this message translates to:
  /// **'학교'**
  String get categorySchool;

  /// No description provided for @categoryCity.
  ///
  /// In ko, this message translates to:
  /// **'도시·마을'**
  String get categoryCity;

  /// No description provided for @genreClassic.
  ///
  /// In ko, this message translates to:
  /// **'클래식'**
  String get genreClassic;

  /// No description provided for @genreFolklore.
  ///
  /// In ko, this message translates to:
  /// **'전래동화'**
  String get genreFolklore;

  /// No description provided for @genreComedy.
  ///
  /// In ko, this message translates to:
  /// **'코미디'**
  String get genreComedy;

  /// No description provided for @genreMystery.
  ///
  /// In ko, this message translates to:
  /// **'미스터리'**
  String get genreMystery;

  /// No description provided for @genreScifi.
  ///
  /// In ko, this message translates to:
  /// **'SF·미래'**
  String get genreScifi;

  /// No description provided for @genreMusical.
  ///
  /// In ko, this message translates to:
  /// **'뮤지컬'**
  String get genreMusical;

  /// No description provided for @genreQuiz.
  ///
  /// In ko, this message translates to:
  /// **'수수께끼'**
  String get genreQuiz;

  /// No description provided for @genreDaily.
  ///
  /// In ko, this message translates to:
  /// **'일상'**
  String get genreDaily;

  /// No description provided for @genreDream.
  ///
  /// In ko, this message translates to:
  /// **'꿈·상상'**
  String get genreDream;

  /// No description provided for @genreHorror.
  ///
  /// In ko, this message translates to:
  /// **'으스스'**
  String get genreHorror;

  /// No description provided for @themeMoral.
  ///
  /// In ko, this message translates to:
  /// **'교훈·도덕'**
  String get themeMoral;

  /// No description provided for @themeFriendship.
  ///
  /// In ko, this message translates to:
  /// **'우정'**
  String get themeFriendship;

  /// No description provided for @themeFamilyLove.
  ///
  /// In ko, this message translates to:
  /// **'가족사랑'**
  String get themeFamilyLove;

  /// No description provided for @themeCourage.
  ///
  /// In ko, this message translates to:
  /// **'용기·도전'**
  String get themeCourage;

  /// No description provided for @themeGrowth.
  ///
  /// In ko, this message translates to:
  /// **'성장'**
  String get themeGrowth;

  /// No description provided for @themeSharing.
  ///
  /// In ko, this message translates to:
  /// **'나눔·배려'**
  String get themeSharing;

  /// No description provided for @themeSelfExpression.
  ///
  /// In ko, this message translates to:
  /// **'자기표현'**
  String get themeSelfExpression;

  /// No description provided for @themeEnvironment.
  ///
  /// In ko, this message translates to:
  /// **'환경사랑'**
  String get themeEnvironment;

  /// No description provided for @themeGratitude.
  ///
  /// In ko, this message translates to:
  /// **'감사'**
  String get themeGratitude;

  /// No description provided for @themeProblemSolving.
  ///
  /// In ko, this message translates to:
  /// **'문제해결'**
  String get themeProblemSolving;

  /// No description provided for @themeCuriosity.
  ///
  /// In ko, this message translates to:
  /// **'호기심'**
  String get themeCuriosity;

  /// No description provided for @themeForgiveness.
  ///
  /// In ko, this message translates to:
  /// **'용서·화해'**
  String get themeForgiveness;

  /// No description provided for @chapter3.
  ///
  /// In ko, this message translates to:
  /// **'3챕터'**
  String get chapter3;

  /// No description provided for @chapter3Desc.
  ///
  /// In ko, this message translates to:
  /// **'짧은 이야기'**
  String get chapter3Desc;

  /// No description provided for @chapter5.
  ///
  /// In ko, this message translates to:
  /// **'5챕터'**
  String get chapter5;

  /// No description provided for @chapter5Desc.
  ///
  /// In ko, this message translates to:
  /// **'보통 이야기'**
  String get chapter5Desc;

  /// No description provided for @chapter7.
  ///
  /// In ko, this message translates to:
  /// **'7챕터'**
  String get chapter7;

  /// No description provided for @chapter7Desc.
  ///
  /// In ko, this message translates to:
  /// **'긴 이야기'**
  String get chapter7Desc;

  /// No description provided for @formatText.
  ///
  /// In ko, this message translates to:
  /// **'텍스트형'**
  String get formatText;

  /// No description provided for @formatTextDesc.
  ///
  /// In ko, this message translates to:
  /// **'글로 읽는 동화'**
  String get formatTextDesc;

  /// No description provided for @formatImage.
  ///
  /// In ko, this message translates to:
  /// **'그림형'**
  String get formatImage;

  /// No description provided for @formatImageDesc.
  ///
  /// In ko, this message translates to:
  /// **'그림으로 보는 동화'**
  String get formatImageDesc;

  /// No description provided for @favoritesTitle.
  ///
  /// In ko, this message translates to:
  /// **'찜목록'**
  String get favoritesTitle;

  /// No description provided for @favoritesCountBadge.
  ///
  /// In ko, this message translates to:
  /// **'{count}권'**
  String favoritesCountBadge(int count);

  /// No description provided for @favoritesEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 찜한 동화가 없어요'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyDesc.
  ///
  /// In ko, this message translates to:
  /// **'마음에 드는 동화에\n하트를 눌러보세요!'**
  String get favoritesEmptyDesc;

  /// No description provided for @favoritesGoBtn.
  ///
  /// In ko, this message translates to:
  /// **'동화 보러 가기'**
  String get favoritesGoBtn;

  /// No description provided for @fairytaleListTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 동화'**
  String get fairytaleListTitle;

  /// No description provided for @fairytaleTabClassic.
  ///
  /// In ko, this message translates to:
  /// **'📚 유명 동화'**
  String get fairytaleTabClassic;

  /// No description provided for @fairytaleTabAi.
  ///
  /// In ko, this message translates to:
  /// **'🤖 AI 동화'**
  String get fairytaleTabAi;

  /// No description provided for @fairytaleTabShared.
  ///
  /// In ko, this message translates to:
  /// **'🌟 공유 동화'**
  String get fairytaleTabShared;

  /// No description provided for @voiceBadge.
  ///
  /// In ko, this message translates to:
  /// **'{name} 목소리'**
  String voiceBadge(String name);

  /// No description provided for @voiceDad.
  ///
  /// In ko, this message translates to:
  /// **'아빠'**
  String get voiceDad;

  /// No description provided for @voiceMom.
  ///
  /// In ko, this message translates to:
  /// **'엄마'**
  String get voiceMom;

  /// No description provided for @voiceGrandma.
  ///
  /// In ko, this message translates to:
  /// **'할머니'**
  String get voiceGrandma;

  /// No description provided for @voiceGrandpa.
  ///
  /// In ko, this message translates to:
  /// **'할아버지'**
  String get voiceGrandpa;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In ko, this message translates to:
  /// **'현재 버전'**
  String get settingsVersion;

  /// No description provided for @settingsProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 및 계정'**
  String get settingsProfile;

  /// No description provided for @settingsSectionActivity.
  ///
  /// In ko, this message translates to:
  /// **'활동 내역'**
  String get settingsSectionActivity;

  /// No description provided for @settingsPurchaseHistory.
  ///
  /// In ko, this message translates to:
  /// **'구매 내역'**
  String get settingsPurchaseHistory;

  /// No description provided for @settingsFavoriteHistory.
  ///
  /// In ko, this message translates to:
  /// **'찜 목록 내역'**
  String get settingsFavoriteHistory;

  /// No description provided for @settingsFairytaleConfig.
  ///
  /// In ko, this message translates to:
  /// **'동화 설정'**
  String get settingsFairytaleConfig;

  /// No description provided for @settingsSectionNoti.
  ///
  /// In ko, this message translates to:
  /// **'혜택 및 이벤트 알림'**
  String get settingsSectionNoti;

  /// No description provided for @settingsTextNoti.
  ///
  /// In ko, this message translates to:
  /// **'문자 알림'**
  String get settingsTextNoti;

  /// No description provided for @settingsPushNoti.
  ///
  /// In ko, this message translates to:
  /// **'푸시 알림'**
  String get settingsPushNoti;

  /// No description provided for @settingsSectionApp.
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get settingsSectionApp;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsSectionDevice.
  ///
  /// In ko, this message translates to:
  /// **'기기 설정'**
  String get settingsSectionDevice;

  /// No description provided for @settingsCameraAccess.
  ///
  /// In ko, this message translates to:
  /// **'카메라 접근'**
  String get settingsCameraAccess;

  /// No description provided for @settingsSectionPolicy.
  ///
  /// In ko, this message translates to:
  /// **'약관 및 정책'**
  String get settingsSectionPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용약관'**
  String get settingsTerms;

  /// No description provided for @settingsFinanceTerms.
  ///
  /// In ko, this message translates to:
  /// **'전자금융거래 이용약관'**
  String get settingsFinanceTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get settingsPrivacy;

  /// No description provided for @loginAppTitle.
  ///
  /// In ko, this message translates to:
  /// **'이야기 숲'**
  String get loginAppTitle;

  /// No description provided for @loginAppSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Children Story Adventure'**
  String get loginAppSubtitle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 시작'**
  String get loginWithGoogle;

  /// No description provided for @loginWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오톡으로 시작'**
  String get loginWithKakao;

  /// No description provided for @loginWithApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 시작'**
  String get loginWithApple;

  /// No description provided for @loginWithYahoo.
  ///
  /// In ko, this message translates to:
  /// **'Yahoo! JAPANで始める'**
  String get loginWithYahoo;

  /// No description provided for @loginTestSkip.
  ///
  /// In ko, this message translates to:
  /// **'테스트 (홈으로 이동)'**
  String get loginTestSkip;

  /// No description provided for @loginFooter.
  ///
  /// In ko, this message translates to:
  /// **'시작과 동시에 이야기 숲의 서비스 약관, 개인정보 취급 방침에 동의하게 됩니다.'**
  String get loginFooter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
