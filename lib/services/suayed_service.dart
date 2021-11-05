import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';
import 'package:suayed/models/suayed_model.dart';
import 'http_service.dart';

class SuayedServices {

  static Future<Psicologia> getFeed() async {
    try {
      Response response = await dio.request('/');
      //log(response.data.toString());
      return (response.data).map((x) => Psicologia.fromJson(x)).toList();
    } on DioError catch (e) {
      if(e.type == DioErrorType.receiveTimeout){
        throw Exception("Connection Timeout Exception");
      }
      throw Exception(e.message);
    }
  }

  static Future<RssFeed> loadFeed() async {
    final requestUri = Uri.https(
        'suayed.iztacala.unam.mx',
        '/feed/rss'
    );

    try {
      var response = await http.get(requestUri);
      if (response.statusCode == 200) {
        return RssFeed.parse(response.body);
      } else {
        throw Exception('Unable to query remote server');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

}
