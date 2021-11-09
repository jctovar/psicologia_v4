class TeacherModel {
  TeacherModel({
    required this.id,
    required this.grade,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.picture,
    required this.mainfield,
    required this.fields,
    required this.cv,
  });

  final int id;
  final String grade;
  final String firstname;
  final String lastname;
  final String email;
  final String picture;
  final String mainfield;
  final String fields;
  final String cv;

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    id: int.parse(json["id"]),
    grade: json["grade"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    email: json["email"],
    picture: json["picture"],
    mainfield: json["mainfield"],
    fields: json["fields"],
    cv: json["cv"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "grade": grade,
    "firstname": firstname,
    "lastname": lastname,
    "email": email,
    "picture": picture,
    "mainfield": mainfield,
    "fields": fields,
    "cv": cv,
  };
}