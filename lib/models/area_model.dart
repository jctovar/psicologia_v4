class AreaModel {
  AreaModel({
    required this.id,
    required this.department_name,
    required this.agent,
    required this.department_email,
    required this.detail,
  });

  final int id;
  final String department_name;
  final String agent;
  final String department_email;
  final String detail;

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
    id: int.parse(json["id"]),
    department_name: json["department_name"],
    agent: json["agent"],
    department_email: json["department_email"],
    detail: json["detail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department_name": department_name,
    "agent": agent,
    "department_email": department_email,
    "detail": detail,
  };
}