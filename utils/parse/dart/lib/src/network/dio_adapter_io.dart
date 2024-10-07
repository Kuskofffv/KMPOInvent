import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:universal_io/io.dart';

HttpClientAdapter createHttpClientAdapter(SecurityContext? securityContext) {
  final IOHttpClientAdapter defaultHttpClientAdapter = IOHttpClientAdapter();

  if (securityContext != null) {
    defaultHttpClientAdapter.createHttpClient = () {
      return HttpClient(context: securityContext);
    };
  }
  return defaultHttpClientAdapter;
}
