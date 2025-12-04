class User {
  final String name;
  final DateTime joinDate;
  final int spokenSentences;
  final int studyTime;
  final String vocabularyLevel;

  const User({
    required this.name,
    required this.joinDate,
    required this.spokenSentences,
    required this.studyTime,
    required this.vocabularyLevel,
  });
}
