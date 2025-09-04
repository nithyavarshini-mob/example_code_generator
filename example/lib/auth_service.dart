import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../core/api_repository/api_repository.dart';
import '../core/utils/utils.dart';
import '../models/app_user.dart';
import '../models/cpl_dashboard/price_record_entity.dart';
import '../models/customer.dart';
import '../models/display_product.dart';
import '../models/ope_approval/ope_approval_entity.dart';
import '../models/product_categories.dart';
import '../models/token.dart';

class AuthService extends ApiRepository {
//************************************ log-in *********************************//
  Future<Map<String, dynamic>?> loginWithPassword(
      {Map<String, dynamic>? objToApi}) async {
    final Response<dynamic> res = await ApiRepository.apiClient
        .post('/user_management/employee/login', data: objToApi);
    return <String, dynamic>{
      'customer': AppUser.fromJson((res.data
          as Map<String, dynamic>)['employee'] as Map<String, dynamic>),
      'token': Token.fromJson(
          (res.data as Map<String, dynamic>)['token'] as Map<String, dynamic>)
    };
  }

//************************************ get-email *********************************//
  Future<String?> getEmail(
      {String? accessToken, Map<String, dynamic>? headersToApi}) async {
    final BaseOptions options = BaseOptions(headers: headersToApi);
    final Dio dio = Dio(options)
      ..interceptors
          .add(PrettyDioLogger(requestHeader: true, requestBody: true));
    final Response<dynamic> res =
        await dio.get('https://graph.microsoft.com/v1.0/me');
    return (res.data as Map<String, dynamic>)['mail'] as String?;
  }

//************************************ log-in-to-pfx *********************************//
  Future<AppUser?> loginToPfx(
      {Map<String, dynamic>? objToApi,
      Map<String, String>? queryToApi,
      Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.apiClient.post(
        'IsValidPfxUser/',
        queryParameters: queryToApi,
        data: objToApi,
        options: Options(headers: headers));
    return AppUser.fromJson(
        (res.data as Map<String, dynamic>)['response'] as Map<String, dynamic>);
  }

//************************************ get-meta-customers *********************************//
  Future<List<Customer>?> getMetaCustomers(
      {Map<String, dynamic>? objToApi,
      required Map<String, dynamic> headers,
      required Map<String, String> queryParams}) async {
    final Response<dynamic> res =
        await ApiRepository.apiClient.post('GetEntitledCustomersByUser',
            data: objToApi,
            queryParameters: queryParams,
            options: Options(
              headers: headers,
            ));
    final List<dynamic> response =
        (res.data as Map<String, dynamic>)['customers'] as List<dynamic>;
    return response
        .map((dynamic data) => Customer.fromJson(data as Map<String, dynamic>))
        .toList();
  }

//************************************ log-out *********************************//
  Future<Response<dynamic>> logOut({Map<String, String>? headersToApi}) async {
    final Response<dynamic> res = await ApiRepository.apiClient.delete(
        '/user_management/employee/logout',
        options: Options(headers: headersToApi));
    return res;
  }

  //************************************ get-DisplayProductForCustomer *********************************//
  Future<DisplayProducts?> getDisplayProductForCustomer(
      {Map<String, dynamic>? objToApi, Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.masterClient.post(
        'GetDisplayProductForCustomer',
        options: Options(headers: headers),
        data: objToApi);

    return DisplayProducts.fromJson(res.data as Map<String, dynamic>);
  }

//************************************ get-ProductCategoriesByDivison *********************************//
  Future<ProductCategories?> getProductCategoriesByDivison(
      {Map<String, dynamic>? objToApi, Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.masterClient.post(
        'GetProductCategoriesByDivision',
        options: Options(headers: headers),
        data: objToApi);

    return ProductCategories.fromJson(res.data as Map<String, dynamic>);
  }

  //************************************ log-in-to-pfx *********************************//
  Future<Map<String, dynamic>?> impersonateUser(
      {Map<String, dynamic>? objToApi, Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.apiClient.post(
        'IsValidPfxUser/?output=rawjson',
        data: objToApi,
        options: Options(headers: headers));

    return Utils.handleResponseParsing(
      res,
      () => <String, dynamic>{
        'AppUser': AppUser.fromJson((res.data
            as Map<String, dynamic>)['response'] as Map<String, dynamic>)
      },
    );
  }

  //************************************ get-ope-record *********************************//
  Future<Map<String, dynamic>?> getOPERecord(
      {Map<String, dynamic>? objToApi, Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.apiClient.post(
        'GetPendingOPEListV2/?output=rawjson',
        data: objToApi,
        options: Options(headers: headers));

    return Utils.handleResponseParsing(
      res,
      () {
        final List<dynamic> records =
            (((res.data as Map<String, dynamic>)['response']
                as Map<String, dynamic>)['priceRecords']) as List<dynamic>;
        if (records.isNotEmpty) {
          final Map<String, dynamic> record =
              records.first as Map<String, dynamic>;
          return <String, dynamic>{
            'OPERecord': OpeApprovalRecord.fromJson(record)
          };
        } else {
          return <String, dynamic>{
            'errorMessage': 'OPE Record is not available'
          };
        }
      },
    );
  }

  //************************************ get-cpl-record *********************************//
  Future<Map<String, dynamic>?> getCPLRecord(
      {Map<String, dynamic>? objToApi, Map<String, dynamic>? headers}) async {
    final Response<dynamic> res = await ApiRepository.apiClient.post(
        'GetPendingLTPListV2/?output=rawjson',
        data: objToApi,
        options: Options(headers: headers));

    return Utils.handleResponseParsing(
      res,
      () {
        final List<dynamic> records =
            ((res.data as Map<String, dynamic>)['response']
                as Map<String, dynamic>)['priceRecords'] as List<dynamic>;
        if (records.isNotEmpty) {
          final Map<String, dynamic> record =
              records.first as Map<String, dynamic>;
          return <String, dynamic>{
            'CPLRecord': PriceRecordEntity.fromJson(record)
          };
        } else {
          return <String, dynamic>{
            'errorMessage': 'CPL Record is not available'
          };
        }
      },
    );
  }
}
