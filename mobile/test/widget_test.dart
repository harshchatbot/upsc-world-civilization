import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upsc_world_civilization/app/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UpscWorldApp()));
    expect(find.byType(UpscWorldApp), findsOneWidget);
  });
}
