import 'package:dio/dio.dart';

var options = BaseOptions(
  baseUrl: 'https://suayed.iztacala.unam.mx/feed/json',
  connectTimeout: 5000,
  receiveTimeout: 3000,
  receiveDataWhenStatusError: true,
);

Dio dio = Dio(options);

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("onRequest");
    return super.onRequest(options, handler);
  }

  @override
  Future? onResponse(Response response, ResponseInterceptorHandler handler) {
    print("onResponse");
    return null;
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    print("onError: ${err.response!.statusCode}");
    return handler.next(err);  // <--- THE TIP IS HERE
  }
}