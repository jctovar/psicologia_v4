import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:suayed/models/teacher_model.dart';

class Services {

  static Future<List<TeacherModel>> readJson() async {
    final String response = await rootBundle.loadString('assets/teachers.json');
    final data = await json.decode(response);

    return (data["RECORDS"] as List).map((x) => TeacherModel.fromJson(x)).toList();
  }
}