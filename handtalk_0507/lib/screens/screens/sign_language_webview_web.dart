import 'package:flutter/material.dart';
import 'dart:ui_web' as ui; // Flutter 3.10 이상
import 'dart:html' as html;

class SignLanguageWebViewPlatform extends StatelessWidget {
  final String title;
  final String url;

  const SignLanguageWebViewPlatform({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final String viewType = 'iframe-${url.hashCode}';

    // IFrame 등록
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final element = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return element;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: HtmlElementView(viewType: viewType),
    );
  }
}
