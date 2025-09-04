import 'package:example_code_generator/example_code_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class MyGenerator extends GeneratorForAnnotation<MyAnnotation> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final className = element.displayName;
    final nameValue = annotation.read('name').stringValue;
    print(className);
    return '''
      // GENERATED CODE - DO NOT MODIFY BY HAND
      extension ${className}X on $className {
        void hello() => print("Hello from generator for $nameValue!");
      }
    ''';
  }
}

class MockApiGenerator extends GeneratorForAnnotation<GenerateMockApi> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final path = annotation.read('path').stringValue;
    print(path);
    final Directory dir = Directory(path);

print(dir.existsSync());
    if (!dir.existsSync()) return '';

    final List<File> dartFiles = dir
        .listSync(recursive: true)
        .where((f) => f is File && f.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    for (final file in dartFiles) {
      final String sourceCode = await file.readAsString();
      final ParseStringResult result = parseString(content: sourceCode);
      final CompilationUnit unit = result.unit;

      final apiVisitor = ApiVisitor();
      unit.visitChildren(apiVisitor);

      print(apiVisitor.apiCalls.length);

      if (apiVisitor.apiCalls.isNotEmpty) {
        print('📂 File: ${file.path}');
        for (final api in apiVisitor.apiCalls) {
           print('   - Method: ${api['method']}');
        print('     URL: ${api['url']}');
        print('     Headers: ${api['headers']}');
        print('     Data: ${api['data']}');
          _generateMockFiles(api,path);
        }
      }
    }
    return ''; // no inline generated code, just side-effect files
  }

  void _generateMockFiles(Map<String, dynamic> api, String sourceFilePath) {
  final name = api['url']
      .replaceAll('/', '_')
      .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
      .replaceAll(RegExp(r'^_+|_+$'), '')
      .toLowerCase();

  final folder = Directory('test/api_mocks/$name');
  folder.createSync(recursive: true);

  final className = _capitalize(name);

  // request
  File('${folder.path}/${name}_mock_api_request.dart').writeAsStringSync('''
// TODO: Fill in request payload for ${api['method'].toUpperCase()} ${api['url']}
class ${className}MockApiRequest {
  static Map<String, dynamic> request = {
    // TODO
  };
}
''');

  // headers
  File('${folder.path}/${name}_mock_api_headers.dart').writeAsStringSync('''
// TODO: Fill in headers for ${api['method'].toUpperCase()} ${api['url']}
class ${className}MockApiHeaders {
  static Map<String, String> headers = {
    // TODO
  };
}
''');

  // response
  File('${folder.path}/${name}_mock_api_response.dart').writeAsStringSync('''
// TODO: Fill in responses for ${api['method'].toUpperCase()} ${api['url']}
class ${className}MockApiResponse {
  static Map<String, dynamic> success = {
    // TODO
  };

  static Map<String, dynamic> error = {
    // TODO
  };
}
''');

  // main adapter
  File('${folder.path}/${name}_mock_api.dart').writeAsStringSync('''
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '${name}_mock_api_request.dart';
import '${name}_mock_api_headers.dart';
import '${name}_mock_api_response.dart';

class ${className}MockApi {
  ${className}MockApi({required this.mockDio});
  final Dio mockDio;

  static DioAdapter successMockAdapter(Dio mockDio) {
    return DioAdapter(dio: mockDio, printLogs: true)
      ..on${_capitalize(api['method'])}(
        '${api['url']}',
        data: ${className}MockApiRequest.request,
        headers: ${className}MockApiHeaders.headers,
        (MockServer server) => server.reply(
          200,
          ${className}MockApiResponse.success,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }
}
''');
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

}

/// Holds API call metadata
class ApiCall {
  final String method;
  final String url;
  ApiCall(this.method, this.url);
}

/// AST visitor to find dio API calls
class ApiVisitor extends RecursiveAstVisitor<void> {
  final List<Map<String, dynamic>> apiCalls = <Map<String, dynamic>>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final String methodName = node.methodName.name;

    // Detect Dio / http calls
    if (<String>[
      'get',
      'post',
      'put',
      'delete',
      'patch'
    ].contains(methodName)) {
      String? url;
      String? data;
      String? headers;

      // Check arguments
      if (node.argumentList.arguments.isNotEmpty) {
        final Expression firstArg = node.argumentList.arguments.first;
        if (firstArg is StringLiteral) {
          url = firstArg.stringValue;
        }
      }

      for (final Expression arg in node.argumentList.arguments) {
        if (arg is NamedExpression) {
          final String name = arg.name.label.name;
          if (name == 'data') {
            data = arg.expression.toSource();
          } else if (name == 'options') {
            headers = arg.expression.toSource();
          }
        }
      }

      apiCalls.add(<String, dynamic>{
        'method': methodName.toUpperCase(),
        'url': url ?? 'TODO: Add URL',
        'headers': headers ?? 'TODO: Add headers',
        'data': data ?? 'TODO: Add payload',
      });
    }

    super.visitMethodInvocation(node);
  }
}


class SoloMockApiGenerator extends GeneratorForAnnotation<GenerateMockApi> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final path = annotation.read('path').stringValue;
    final dir = Directory(path);

    if (!dir.existsSync()) return '';

    final List<File> dartFiles = dir
        .listSync(recursive: true)
        .where((f) => f is File && f.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    final List<Map<String, dynamic>> allApis = [];

    for (final file in dartFiles) {
      final String sourceCode = await file.readAsString();
      final ParseStringResult result = parseString(content: sourceCode);
      final CompilationUnit unit = result.unit;

      final apiVisitor = ApiVisitor();
      unit.visitChildren(apiVisitor);

      if (apiVisitor.apiCalls.isNotEmpty) {
        allApis.addAll(apiVisitor.apiCalls);
      }
    }

    if (File('test/api_mocks/mock_api_headers.dart').existsSync()){
      var content = File('test/api_mocks/mock_api_headers.dart').readAsStringSync();
      var lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    content = content.substring(0, lastIndex).trimRight();
    File('test/api_mocks/mock_api_headers.dart').writeAsStringSync(content);
  }
   content = File('test/api_mocks/mock_api_request.dart').readAsStringSync();
       lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    content = content.substring(0, lastIndex).trimRight();
    File('test/api_mocks/mock_api_request.dart').writeAsStringSync(content);
  }
   content = File('test/api_mocks/mock_api_response.dart').readAsStringSync();
       lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    content = content.substring(0, lastIndex).trimRight();
    File('test/api_mocks/mock_api_response.dart').writeAsStringSync(content);
  }
   content = File('test/api_mocks/mock_api.dart').readAsStringSync();
       lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    content = content.substring(0, lastIndex).trimRight();
    File('test/api_mocks/mock_api.dart').writeAsStringSync(content);
  }
    }

    if (allApis.isNotEmpty) {
      for (final api in allApis) {
        _generateCommonMockFiles(api); // ✅ now iterating per API
      }
  //     _ensureFileEndsWithBrace(File('test/api_mocks/mock_api_headers.dart'));
  // _ensureFileEndsWithBrace(File('test/api_mocks/mock_api_request.dart'));
  // _ensureFileEndsWithBrace(File('test/api_mocks/mock_api_response.dart'));
  // _ensureFileEndsWithBrace(File('test/api_mocks/mock_api.dart'));
    }

    return ''; // no inline code
  }

// void _ensureFileEndsWithBrace(File file) {
//     file.writeAsStringSync('\n}', mode: FileMode.append);
  
// }


  /// Generate **one common set of files**, extend them per API
  void _generateCommonMockFiles(Map<String, dynamic> api) {
    final folder = Directory('test/api_mocks');
    folder.createSync(recursive: true);

    // Normalize to valid identifier
    final rawName = api['url']
        .replaceAll('/', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toLowerCase();

    // UpperCamelCase for extensions
    final className = _capitalize(rawName.isEmpty ? 'Api' : rawName);

    // lowerCamelCase for getters (lint-safe)
    final getterName = _toLowerCamelCase(rawName.isEmpty ? 'api' : rawName);

    // === HEADERS FILE ===
    final headersFile = File('${folder.path}/mock_api_headers.dart');
    if (!headersFile.existsSync()) {
      headersFile.writeAsStringSync('''
/// Auto-generated mock headers
class MockApiHeaders {
''');
    }
   _appendIfNotExists(
  headersFile,
  getterName,
  '''
  static Map<String, String> $getterName = {
    // TODO: headers for ${api['method']} ${api['url']}
  };
  '''
);
 


    // === REQUEST FILE ===
    final requestFile = File('${folder.path}/mock_api_request.dart');
    if (!requestFile.existsSync()) {
      requestFile.writeAsStringSync('''
/// Auto-generated mock requests
class MockApiRequest {
''');
    }
    _appendIfNotExists(requestFile,getterName, '''

   static Map<String, dynamic> $getterName = {
    // TODO: request body for ${api['method']} ${api['url']}
  };
''');

    // === RESPONSE FILE ===
    final responseFile = File('${folder.path}/mock_api_response.dart');
    if (!responseFile.existsSync()) {
      responseFile.writeAsStringSync('''
/// Auto-generated mock responses
class MockApiResponse {
''');
    }
    _appendIfNotExists(responseFile,getterName, '''
static Map<String, dynamic>  ${getterName}Success = {
    // TODO: success response for ${api['method']} ${api['url']}
  };

  static Map<String, dynamic>  ${getterName}Error = {
    // TODO: error response for ${api['method']} ${api['url']}
  };
''');

    // === MAIN ADAPTER FILE ===
    final adapterFile = File('${folder.path}/mock_api.dart');
    if (!adapterFile.existsSync()) {
      adapterFile.writeAsStringSync('''
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'mock_api_request.dart';
import 'mock_api_headers.dart';
import 'mock_api_response.dart';

/// Auto-generated adapters
class MockApi {
MockApi({required this.mockDio});
  Dio mockDio;
''');
    }
    _appendIfNotExists(adapterFile,getterName, '''
  static DioAdapter mock$className(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..on${_capitalize(api['method'])}(
        '${api['url']}',
        data: MockApiRequest.$getterName,
        headers: MockApiHeaders.$getterName,
        (MockServer server) => server.reply(
          200,
          MockApiResponse.${getterName}Success,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }

''');
  }

  /// Append only if the snippet doesn’t already exist
  /// Append code only if the snippet with same name does not already exist
/// Append code only if the snippet with same identifier does not already exist
/// Append code only if the snippet with same identifier does not already exist
void _appendIfNotExists(File file, String identifier, String content) {
  if (!file.existsSync()) return;

  var existing = file.readAsStringSync();

  // Check if this snippet already exists in file
  // We search for a static field or method that starts with the identifier
  final regex = RegExp(r'(static\s+[^\n]*\s+' + identifier + r'\b)');
  if (regex.hasMatch(existing)) {
    // ✅ already generated for this API
    return;
  }

  // Remove trailing `}` to inject new content before it
  if (existing.trimRight().endsWith('}')) {
    existing = existing.trimRight().substring(
      0,
      existing.trimRight().length - 1,
    );
  }

  // Append new snippet and close class again
  final newContent = '$existing\n$content\n}';
  file.writeAsStringSync(newContent);
}

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _toLowerCamelCase(String s) {
    if (s.isEmpty) return s;
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((p) => _capitalize(p)).join();
  }
}
