import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'mock_api_request.dart';
import 'mock_api_headers.dart';
import 'mock_api_response.dart';

/// Auto-generated adapters
class MockApi {
MockApi({required this.mockDio});
  Dio mockDio;

  static DioAdapter mockUser_management_employee_login(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        '/user_management/employee/login',
        data: MockApiRequest.userManagementEmployeeLogin,
        headers: MockApiHeaders.userManagementEmployeeLogin,
        (server) => server.reply(
          200,
          MockApiResponse.userManagementEmployeeLoginSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockHttps__graphmicrosoftcom_v10_me(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onGet(
        'https://graph.microsoft.com/v1.0/me',
        data: MockApiRequest.httpsGraphmicrosoftcomV10Me,
        headers: MockApiHeaders.httpsGraphmicrosoftcomV10Me,
        (server) => server.reply(
          200,
          MockApiResponse.httpsGraphmicrosoftcomV10MeSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockIsvalidpfxuser(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'IsValidPfxUser/',
        data: MockApiRequest.isvalidpfxuser,
        headers: MockApiHeaders.isvalidpfxuser,
        (server) => server.reply(
          200,
          MockApiResponse.isvalidpfxuserSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockGetentitledcustomersbyuser(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'GetEntitledCustomersByUser',
        data: MockApiRequest.getentitledcustomersbyuser,
        headers: MockApiHeaders.getentitledcustomersbyuser,
        (server) => server.reply(
          200,
          MockApiResponse.getentitledcustomersbyuserSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockUser_management_employee_logout(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onDelete(
        '/user_management/employee/logout',
        data: MockApiRequest.userManagementEmployeeLogout,
        headers: MockApiHeaders.userManagementEmployeeLogout,
        (server) => server.reply(
          200,
          MockApiResponse.userManagementEmployeeLogoutSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockGetdisplayproductforcustomer(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'GetDisplayProductForCustomer',
        data: MockApiRequest.getdisplayproductforcustomer,
        headers: MockApiHeaders.getdisplayproductforcustomer,
        (server) => server.reply(
          200,
          MockApiResponse.getdisplayproductforcustomerSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockGetproductcategoriesbydivision(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'GetProductCategoriesByDivision',
        data: MockApiRequest.getproductcategoriesbydivision,
        headers: MockApiHeaders.getproductcategoriesbydivision,
        (server) => server.reply(
          200,
          MockApiResponse.getproductcategoriesbydivisionSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockIsvalidpfxuser_outputrawjson(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'IsValidPfxUser/?output=rawjson',
        data: MockApiRequest.isvalidpfxuserOutputrawjson,
        headers: MockApiHeaders.isvalidpfxuserOutputrawjson,
        (server) => server.reply(
          200,
          MockApiResponse.isvalidpfxuserOutputrawjsonSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockGetpendingopelistv2_outputrawjson(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'GetPendingOPEListV2/?output=rawjson',
        data: MockApiRequest.getpendingopelistv2Outputrawjson,
        headers: MockApiHeaders.getpendingopelistv2Outputrawjson,
        (server) => server.reply(
          200,
          MockApiResponse.getpendingopelistv2OutputrawjsonSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }



  static DioAdapter mockGetpendingltplistv2_outputrawjson(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..onPost(
        'GetPendingLTPListV2/?output=rawjson',
        data: MockApiRequest.getpendingltplistv2Outputrawjson,
        headers: MockApiHeaders.getpendingltplistv2Outputrawjson,
        (server) => server.reply(
          200,
          MockApiResponse.getpendingltplistv2OutputrawjsonSuccess,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }


}