import 'package:build/build.dart';
import 'package:example_code_generator/src/example_code_generator.dart';
import 'package:source_gen/source_gen.dart';

/// SharedPartBuilder lets multiple generators safely write into `.g.dart`
/// files without conflicting, as long as they use different identifiers.
Builder myBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [SoloMockApiGenerator()],
    'example_code_generator', // 👈 unique identifier for your generator
  );
}
