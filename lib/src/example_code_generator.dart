import 'package:example_code_generator/example_code_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// AST visitor to detect Dio API calls
class ApiVisitor extends RecursiveAstVisitor<void> {
  final List<Map<String, dynamic>> apiCalls = <Map<String, dynamic>>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final String methodName = node.methodName.name;

    if (<String>['get', 'post', 'put', 'delete', 'patch'].contains(methodName)) {
      String? url;
      String? data;
      String? headers;

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

    if (allApis.isNotEmpty) {
      for (final api in allApis) {
        _generateCommonMockFiles(api);
      }
    }

    return ''; // no inline code, side-effect files only
  }

  /// Generate **one common set of files**, append APIs without duplication
  void _generateCommonMockFiles(Map<String, dynamic> api) {
    final folder = Directory('test/api_mocks');
    folder.createSync(recursive: true);

    final rawName = api['url']
        .replaceAll('/', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toLowerCase();

    final className = _capitalize(rawName.isEmpty ? 'Api' : rawName);
    final getterName = _toLowerCamelCase(rawName.isEmpty ? 'api' : rawName);

    // === HEADERS FILE ===
    final headersFile = File('${folder.path}/mock_api_headers.dart');
    if (!headersFile.existsSync()) {
      headersFile.writeAsStringSync('''
/// Auto-generated mock headers
class MockApiHeaders {
}
''');
    }
    _appendIfNotExists(
      headersFile,
      identifier: getterName,
      snippet: '''
  static Map<String, String> $getterName = {
    // TODO: headers for ${api['method']} ${api['url']}
  };
''',
    );

    // === REQUEST FILE ===
    final requestFile = File('${folder.path}/mock_api_request.dart');
    if (!requestFile.existsSync()) {
      requestFile.writeAsStringSync('''
/// Auto-generated mock requests
class MockApiRequest {
}
''');
    }
    _appendIfNotExists(
      requestFile,
      identifier: getterName,
      snippet: '''
  static Map<String, dynamic> $getterName = {
    // TODO: request body for ${api['method']} ${api['url']}
  };
''',
    );

    // === RESPONSE FILE ===
    final responseFile = File('${folder.path}/mock_api_response.dart');
    if (!responseFile.existsSync()) {
      responseFile.writeAsStringSync('''
/// Auto-generated mock responses
class MockApiResponse {
}
''');
    }
    _appendIfNotExists(
      responseFile,
      identifier: '${getterName}Success',
      snippet: '''
  static Map<String, dynamic> ${getterName}Success = {
    // TODO: success response for ${api['method']} ${api['url']}
  };

  static Map<String, dynamic> ${getterName}Error = {
    // TODO: error response for ${api['method']} ${api['url']}
  };
''',
    );

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
  final Dio mockDio;
}
''');
    }
    _appendIfNotExists(
      adapterFile,
      identifier: 'mock$className',
      snippet: '''
  static DioAdapter mock$className(Dio dio) {
    return DioAdapter(dio: dio, printLogs: true)
      ..on${_capitalize(api['method'])}(
        '${api['url']}',
        data: MockApiRequest.$getterName,
        headers: MockApiHeaders.$getterName,
        (server) => server.reply(
          200,
          MockApiResponse.${getterName}Success,
          statusMessage: 'OK',
          delay: const Duration(milliseconds: 500),
        ),
      );
  }
''',
    );
  }

  /// Append code only if snippet with identifier doesn’t exist already
  void _appendIfNotExists(File file,
      {required String identifier, required String snippet}) {
    if (!file.existsSync()) return;

    var existing = file.readAsStringSync();

    // More strict: look for static field/method with this identifier
    final regex = RegExp(r'(static\s+[^\n]*\s+' + identifier + r'\b)');
    if (regex.hasMatch(existing)) {
      return; // already present
    }

    // Trim last `}`
    if (existing.trimRight().endsWith('}')) {
      existing = existing.trimRight().substring(0, existing.trimRight().length - 1);
    }

    final newContent = '$existing\n$snippet\n}';
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
