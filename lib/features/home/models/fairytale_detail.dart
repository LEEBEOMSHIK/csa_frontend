class FairytaleDetailData {
  final String authorKo;
  final String authorJa;
  final String ageRange;
  final int durationMin;
  final int pageCount;
  final String? fullContentKo;
  final String? fullContentJa;

  const FairytaleDetailData({
    required this.authorKo,
    required this.authorJa,
    required this.ageRange,
    required this.durationMin,
    required this.pageCount,
    this.fullContentKo,
    this.fullContentJa,
  });

  String authorFor(String lang) => lang == 'ja' ? authorJa : authorKo;
  String? fullContentFor(String lang) => lang == 'ja' ? fullContentJa : fullContentKo;

  factory FairytaleDetailData.fromJson(Map<String, dynamic> json) {
    return FairytaleDetailData(
      authorKo: json['authorKo'] as String,
      authorJa: json['authorJa'] as String? ?? '',
      ageRange: json['ageRange'] as String,
      durationMin: json['durationMin'] as int,
      pageCount: json['pageCount'] as int,
      fullContentKo: json['fullContentKo'] as String?,
      fullContentJa: json['fullContentJa'] as String?,
    );
  }
}
