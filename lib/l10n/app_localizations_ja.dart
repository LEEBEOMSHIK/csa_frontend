// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'わたしたちのどうわ';

  @override
  String get navCharacter => 'マイキャラ';

  @override
  String get navFairytale => 'どうわ';

  @override
  String get navHome => 'ホーム';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navMy => 'マイページ';

  @override
  String get homeTitle => 'みんなのどうわ工房';

  @override
  String get homeTabStory => 'ストーリー';

  @override
  String get homeTabPicture => 'えピース';

  @override
  String get homeSectionTheme => 'テーマ別';

  @override
  String get homeSectionNew => '新着リスト';

  @override
  String get homeSectionReco => 'おすすめ';

  @override
  String get homeMoreBtn => 'もっと見る';

  @override
  String get characterTitle => 'マイキャラ';

  @override
  String get characterMyCharacter => 'わたしのキャラ';

  @override
  String characterOptionTitle(String part) {
    return '$partのオプション';
  }

  @override
  String get characterTabBasic => 'ベース';

  @override
  String get characterTabHair => 'かみ';

  @override
  String get characterTabEyes => 'め';

  @override
  String get characterTabNose => 'はな';

  @override
  String get characterTabMouth => 'くち';

  @override
  String get faceRound => 'まるがお';

  @override
  String get faceSquare => 'かくがお';

  @override
  String get faceInvTriangle => 'さかさんかく';

  @override
  String get faceHeart => 'ハートがお';

  @override
  String get faceEgg => 'たまごがお';

  @override
  String get faceHex => 'ろっかくがお';

  @override
  String get hairBob => 'ショートボブ';

  @override
  String get hairLong => 'ロングヘア';

  @override
  String get hairCurly => 'カーリー';

  @override
  String get hairBuzz => 'バリカン';

  @override
  String get hairPony => 'ポニーテール';

  @override
  String get hairMohawk => 'モヒカン';

  @override
  String get eyeDefault => 'ふつうのめ';

  @override
  String get eyeBig => 'おおきいめ';

  @override
  String get eyeSleepy => 'ねむいめ';

  @override
  String get eyeCrescent => 'はんげつめ';

  @override
  String get eyeStar => 'ほしめ';

  @override
  String get eyeRound => 'まるいめ';

  @override
  String get noseSmall => 'ちいさいはな';

  @override
  String get noseNormal => 'ふつうはな';

  @override
  String get noseHigh => 'たかいはな';

  @override
  String get noseCute => 'かわいいはな';

  @override
  String get mouthSmile => 'わらい';

  @override
  String get mouthGrin => 'えがお';

  @override
  String get mouthOpen => 'あけたくち';

  @override
  String get mouthPout => 'ふくれっつら';

  @override
  String get createTitle => 'どうわをつくる';

  @override
  String get createQuestion => 'どんなどうわをつくりますか？📖';

  @override
  String get createDesc => 'カテゴリーを選ぶとAIが特別などうわを作ってくれるよ！';

  @override
  String createBtnWithCategory(String category) {
    return '$categoryのどうわをつくる！';
  }

  @override
  String get createBtnNoCategory => 'カテゴリーを先に選んでください';

  @override
  String get categoryAdventure => 'ぼうけん';

  @override
  String get categoryFamily => 'かぞく';

  @override
  String get categoryFantasy => 'ファンタジー';

  @override
  String get categoryFriendship => 'ゆうじょう';

  @override
  String get categoryAnimal => 'どうぶつ';

  @override
  String get categorySea => 'うみ';

  @override
  String get categorySpace => 'うちゅう';

  @override
  String get categoryMagic => 'まほう';

  @override
  String get favoritesTitle => 'お気に入り';

  @override
  String favoritesCountBadge(int count) {
    return '$count冊';
  }

  @override
  String get favoritesEmpty => 'まだお気に入りのどうわはありません';

  @override
  String get favoritesEmptyDesc => '好きなどうわに\nハートを押してみてね！';

  @override
  String get favoritesGoBtn => 'どうわを見に行く';

  @override
  String get fairytaleListTitle => 'きほんどうわ';

  @override
  String get fairytaleTabClassic => '📚 めいさくどうわ';

  @override
  String get fairytaleTabAi => '🤖 AIどうわ';

  @override
  String get fairytaleTabShared => '🌟 みんなのどうわ';

  @override
  String voiceBadge(String name) {
    return '$nameのこえ';
  }

  @override
  String get voiceDad => 'パパ';

  @override
  String get settingsTitle => 'せってい';

  @override
  String get settingsVersion => '現在のバージョン';

  @override
  String get settingsProfile => 'プロフィールとアカウント';

  @override
  String get settingsSectionActivity => '活動履歴';

  @override
  String get settingsPurchaseHistory => '購入履歴';

  @override
  String get settingsFavoriteHistory => 'お気に入り履歴';

  @override
  String get settingsFairytaleConfig => 'どうわ設定';

  @override
  String get settingsSectionNoti => '特典とイベント通知';

  @override
  String get settingsTextNoti => 'テキスト通知';

  @override
  String get settingsPushNoti => 'プッシュ通知';

  @override
  String get settingsSectionApp => 'アプリ設定';

  @override
  String get settingsLanguage => '言語設定';

  @override
  String get settingsLanguageTitle => '言語を選択';

  @override
  String get settingsSectionDevice => 'デバイス設定';

  @override
  String get settingsCameraAccess => 'カメラアクセス';

  @override
  String get settingsSectionPolicy => '利用規約とポリシー';

  @override
  String get settingsTerms => 'サービス利用規約';

  @override
  String get settingsFinanceTerms => '電子金融取引利用規約';

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get loginAppTitle => '物語の森';

  @override
  String get loginAppSubtitle => 'Children Story Adventure';

  @override
  String get loginWithGoogle => 'Googleで始める';

  @override
  String get loginWithKakao => 'カカオトークで始める';

  @override
  String get loginWithApple => 'Appleで始める';

  @override
  String get loginWithYahoo => 'Yahoo! JAPANで始める';

  @override
  String get loginTestSkip => 'テスト（ホームへ）';

  @override
  String get loginFooter => '利用を開始することで、物語の森のサービス利用規約・プライバシーポリシーに同意したものとみなします。';
}
