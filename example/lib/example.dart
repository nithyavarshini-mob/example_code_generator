import 'package:example_code_generator/example_code_generator.dart';

part 'example.g.dart';

@MyAnnotation(name: 'test')
@GenerateMockApi(path: 'example/lib')
class Run {
  // Just a sample class, nothing fancy.
  
}
