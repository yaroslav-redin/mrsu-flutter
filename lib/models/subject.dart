class SubjectItem {
  final int id;
  final String name;

  SubjectItem({required this.id, required this.name});

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: json['Id'] ?? 0,
      name: json['Title'] ?? '',
    );
  }
}

class SubjectDetail {
  final String title;
  final List<Section> sections;
  final double? zeroSessionMark;

  SubjectDetail({
    required this.title,
    required this.sections,
    this.zeroSessionMark,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['Sections'] as List? ?? [];
    List<Section> sections = sectionsList.map((i) => Section.fromJson(i)).toList();

    double? zeroSession;
    if (json['MarkZeroSession'] != null) {
      zeroSession = (json['MarkZeroSession']['Ball'] as num?)?.toDouble();
    }

    return SubjectDetail(
      title: json['Title'] ?? '',
      sections: sections,
      zeroSessionMark: zeroSession,
    );
  }

  double get totalScore {
    double total = 0;
    for (var section in sections) {
      for (var dot in section.controlDots) {
        total += dot.mark;
      }
    }
    return total;
  }
}

class Section {
  final String title;
  final List<ControlDot> controlDots;

  Section({required this.title, required this.controlDots});

  factory Section.fromJson(Map<String, dynamic> json) {
    var dotsList = json['ControlDots'] as List? ?? [];
    List<ControlDot> dots = dotsList.map((i) => ControlDot.fromJson(i)).toList();

    return Section(
      title: json['Title'] ?? '',
      controlDots: dots,
    );
  }
}

class ControlDot {
  final String title;
  final double mark;

  ControlDot({required this.title, required this.mark});

  factory ControlDot.fromJson(Map<String, dynamic> json) {
    return ControlDot(
      title: json['Title'] ?? '',
      mark: (json['Mark']?['Ball'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
