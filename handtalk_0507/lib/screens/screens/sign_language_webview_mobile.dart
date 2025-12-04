import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignLanguageWebViewPlatform extends StatefulWidget {
  final String title;
  final String url;

  const SignLanguageWebViewPlatform({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<SignLanguageWebViewPlatform> createState() =>
      _SignLanguageWebViewPlatformState();
}

class _SignLanguageWebViewPlatformState
    extends State<SignLanguageWebViewPlatform> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 자바스크립트 허용
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
