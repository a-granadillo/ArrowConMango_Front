/// Wire shape of a row returned by `GET /leaderboard/global`.
class PlayerStandingDto {
  const PlayerStandingDto({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.mangos,
    required this.levelsCompleted,
    required this.isMe,
  });

  factory PlayerStandingDto.fromJson(Map<String, dynamic> json) {
    return PlayerStandingDto(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      mangos: json['mangos'] as int,
      levelsCompleted: json['levelsCompleted'] as int,
      isMe: json['isMe'] as bool,
    );
  }

  final int rank;
  final String userId;
  final String displayName;
  final int mangos;
  final int levelsCompleted;
  final bool isMe;
}
