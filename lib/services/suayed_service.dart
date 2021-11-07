import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:suayed/models/post_model.dart';
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

  static Future<List<PostModel> > getPosts() async {
    const String url = 'suayed.iztacala.unam.mx';
    const String path = '/wp-json/wp/v2/posts';

    final response = await http.get(Uri.https(url, path, { '_embed' : '' }));
    try {
      if (response.statusCode == 200) {
        List<PostModel> list = parseJson(response.body);

        return list;
      } else {
        throw Exception('Failed to load post');
      }
    }  catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<PostModel> parseJson(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

}
