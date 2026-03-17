class Lesson {
  final int number;
  final List<Discipline> disciplines;

  Lesson({required this.number, required this.disciplines});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var disciplinesList = json['Disciplines'] as List;
    List<Discipline> disciplines = disciplinesList.map((i) => Discipline.fromJson(i)).toList();

    return Lesson(
      number: json['Number'],
      disciplines: disciplines,
    );
  }
}

class Discipline {
  final String title;
  final String group;
  final String teacher;
  final String auditorium;

  Discipline({
    required this.title,
    required this.group,
    required this.teacher,
    required this.auditorium,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      title: json['Title'] ?? '',
      group: json['Group'] ?? '',
      teacher: json['Teacher']?['FIO'] ?? '',
      auditorium: json['Auditorium']?['Number'] ?? '',
    );
  }
}
