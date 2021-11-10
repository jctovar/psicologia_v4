import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:suayed/models/teacher_model.dart';
import 'package:suayed/models/area_model.dart';


class Services {

  static Future<List<TeacherModel>> readJsonTeachers() async {
    final String response = await rootBundle.loadString('assets/teachers.json');
    final data = await json.decode(response);

    return (data["RECORDS"] as List).map((x) => TeacherModel.fromJson(x)).toList();
  }

  static Future<List<AreaModel>> readJsonAreas() async {
    final String response = await rootBundle.loadString('assets/areas.json');
    final data = await json.decode(response);

    return (data["RECORDS"] as List).map((x) => AreaModel.fromJson(x)).toList();
  }
}