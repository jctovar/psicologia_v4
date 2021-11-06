import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'http_service.dart';

class SuayedServices {

  static Future<List> getWP() async {
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

}
