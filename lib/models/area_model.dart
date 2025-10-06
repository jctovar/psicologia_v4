class AreaModel {
  AreaModel({
    required this.id,
    required this.departmentName,
    required this.title,
    required this.agent,
    required this.departmentEmail,
    required this.personalEmail,
    required this.detail,
  });

  final int id;
  final String departmentName;
  final String title;
  final String agent;
  final String departmentEmail;
  final String personalEmail;
  final String detail;

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
    id: int.parse(json["id"]),
    departmentName: json["department_name"],
    title: json["title"],
    agent: json["agent"],
    departmentEmail: json["department_email"],
    personalEmail: json["personal_email"],
    detail: json["detail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department_name": departmentName,
    "title": title,
    "agent": agent,
    "department_email": departmentEmail,
    "personal_email": personalEmail,
    "detail": detail,
  };
}