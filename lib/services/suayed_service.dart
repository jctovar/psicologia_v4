import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:suayed/models/post_model.dart';
import 'http_service.dart';

class SuayedServices {

  // Old function, only for documentation for jsonDecode
  static Future<List> getWP() async {
    // response['title']['rendered']

    final requestUri = Uri.https(
        'suayed.iztacala.unam.mx', '/wp-json/wp/v2/posts', { '_embed' : '' }
    );

    try {
      final response = await http.get(requestUri, headers: {'Accept': 'application/json'});

      var convert = jsonDecode(response.body);
      return convert;

    } on DioError catch (e) {
      if(e.type == DioErrorType.receiveTimeout){
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }

  static Future<List<PostModel>> getPosts() async {
    try {
      Response response = await dio.request('?per_page=15');

      return (response.data as List).map((x) => PostModel.fromJson(x)).toList();
    } on DioError catch (e) {
      if(e.type == DioErrorType.receiveTimeout){
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }
}
