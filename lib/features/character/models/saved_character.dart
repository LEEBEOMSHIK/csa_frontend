/// 서버에 저장된 캐릭터 (백엔드 CharacterDto 매핑)
class SavedCharacter {
  final int id;
  final String name;
  final List<int> variants;
  final DateTime? createdAt;

  const SavedCharacter({
    required this.id,
    required this.name,
    required this.variants,
    this.createdAt,
  });

  factory SavedCharacter.fromJson(Map<String, dynamic> json) {
    return SavedCharacter(
      id: json['id'] as int,
      name: json['name'] as String,
      variants: (json['variants'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
