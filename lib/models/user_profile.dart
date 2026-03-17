class UserProfile {
  final String email;
  final bool emailConfirmed;
  final String englishFIO;
  final String teacherCod;
  final String studentCod;
  final String birthDate;
  final String academicDegree;
  final String academicRank;
  final List<Role> roles;
  final String id;
  final String userName;
  final String fio;
  final UserPhoto photo;

  UserProfile({
    required this.email,
    required this.emailConfirmed,
    required this.englishFIO,
    required this.teacherCod,
    required this.studentCod,
    required this.birthDate,
    required this.academicDegree,
    required this.academicRank,
    required this.roles,
    required this.id,
    required this.userName,
    required this.fio,
    required this.photo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['Email'] ?? '',
      emailConfirmed: json['EmailConfirmed'] ?? false,
      englishFIO: json['EnglishFIO'] ?? '',
      teacherCod: json['TeacherCod'] ?? '',
      studentCod: json['StudentCod'] ?? '',
      birthDate: json['BirthDate'] ?? '',
      academicDegree: json['AcademicDegree'] ?? '',
      academicRank: json['AcademicRank'] ?? '',
      roles: (json['Roles'] as List? ?? [])
          .map((i) => Role.fromJson(i))
          .toList(),
      id: json['Id'] ?? '',
      userName: json['UserName'] ?? '',
      fio: json['FIO'] ?? '',
      photo: UserPhoto.fromJson(json['Photo'] ?? {}),
    );
  }
}

class Role {
  final String name;
  final String description;

  Role({required this.name, required this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}

class UserPhoto {
  final String urlSmall;
  final String urlMedium;
  final String urlSource;

  UserPhoto({
    required this.urlSmall,
    required this.urlMedium,
    required this.urlSource,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      urlSmall: json['UrlSmall'] ?? '',
      urlMedium: json['UrlMedium'] ?? '',
      urlSource: json['UrlSource'] ?? '',
    );
  }
}
