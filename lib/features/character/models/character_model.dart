/// 캐릭터 코스튬 데이터 모델
/// 인덱스 0 = 없음(none), 1+ = 각 아이템 변형
class CharacterModel {
  final int hatVariant;         // 0~4
  final int topVariant;         // 0~4
  final int bottomVariant;      // 0~3
  final int glassesVariant;     // 0~3
  final int accessoryVariant;   // 0~3

  const CharacterModel({
    this.hatVariant = 0,
    this.topVariant = 0,
    this.bottomVariant = 0,
    this.glassesVariant = 0,
    this.accessoryVariant = 0,
  });

  CharacterModel copyWith({
    int? hatVariant,
    int? topVariant,
    int? bottomVariant,
    int? glassesVariant,
    int? accessoryVariant,
  }) {
    return CharacterModel(
      hatVariant: hatVariant ?? this.hatVariant,
      topVariant: topVariant ?? this.topVariant,
      bottomVariant: bottomVariant ?? this.bottomVariant,
      glassesVariant: glassesVariant ?? this.glassesVariant,
      accessoryVariant: accessoryVariant ?? this.accessoryVariant,
    );
  }

  // Phase 2: 실제 에셋 경로로 전환
  String get hatAsset       => 'assets/character_parts/hat/hat_$hatVariant.png';
  String get topAsset       => 'assets/character_parts/top/top_$topVariant.png';
  String get bottomAsset    => 'assets/character_parts/bottom/bottom_$bottomVariant.png';
  String get glassesAsset   => 'assets/character_parts/glasses/glasses_$glassesVariant.png';
  String get accessoryAsset => 'assets/character_parts/accessory/accessory_$accessoryVariant.png';

  List<int> toVariantList() =>
      [hatVariant, topVariant, bottomVariant, glassesVariant, accessoryVariant];

  factory CharacterModel.fromVariantList(List<int> v) => CharacterModel(
        hatVariant: v[0],
        topVariant: v[1],
        bottomVariant: v[2],
        glassesVariant: v[3],
        accessoryVariant: v[4],
      );
}
