class AreaModel {
  AreaModel({
    required this.id,
    required this.department_name,
    required this.title,
    required this.agent,
    required this.department_email,
    required this.personal_email,
    required this.detail,
  });

  final int id;
  final String department_name;
  final String title;
  final String agent;
  final String department_email;
  final String personal_email;
  final String detail;

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
    id: int.parse(json["id"]),
    department_name: json["department_name"],
    title: json["title"],
    agent: json["agent"],
    department_email: json["department_email"],
    personal_email: json["personal_email"],
    detail: json["detail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department_name": department_name,
    "title": title,
    "agent": agent,
    "department_email": department_email,
    "personal_email": personal_email,
    "detail": detail,
  };
}