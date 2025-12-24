class RankingUserModel {
  final String uid;
  final String name;
  final String avatarUrl;
  final int points;

  RankingUserModel({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.points,
  });

  factory RankingUserModel.fromMap(String uid, Map<String, dynamic> map) {
    return RankingUserModel(
      uid: uid,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}

// Code cleanup

// Auto-generated tweak
