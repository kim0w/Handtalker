import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWebViewPlatform extends WebViewPlatform {}

void main() {
  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('웹뷰 테스트', (tester) async {
    // ...
  });
}
