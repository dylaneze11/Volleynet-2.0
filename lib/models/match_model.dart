class MatchModel {
  final String id;
  final String day;
  final String time;
  final String opponent;
  final String location;
  final String score;

  const MatchModel({
    required this.id,
    this.day = '',
    this.time = '',
    this.opponent = '',
    this.location = '',
    this.score = '',
  });

  MatchModel copyWith({
    String? day,
    String? time,
    String? opponent,
    String? location,
    String? score,
  }) {
    return MatchModel(
      id: id,
      day: day ?? this.day,
      time: time ?? this.time,
      opponent: opponent ?? this.opponent,
      location: location ?? this.location,
      score: score ?? this.score,
    );
  }
}
