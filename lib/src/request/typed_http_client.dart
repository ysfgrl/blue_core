

part of 'blue_request.dart';

class TypedHttpClient extends HttpClient{
  const TypedHttpClient({
    required super.dio,
    super.baseUrl,
    super.connectTimeout,
    super.interceptors
  });
  Future<RType?> typedReq<RType extends BaseModel>(String path, String method,{
    Map<String, dynamic>? bodyData,
    Map<String, dynamic>? queryParameters,
    FormData? formData,
    OnUploadProgressCallback? uploadProgress,
    required ErrorHandler<RType> errorHandler
  }) async {
    return super.request(path, method,
        queryParameters: queryParameters,
        bodyData: bodyData,
        formData: formData).then((value) {
      return ModelFactory.modelFromString(value.data);
    }, onError:(err, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      return errorHandler(err);
    });
  }
}
