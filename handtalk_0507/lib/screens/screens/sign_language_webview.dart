import 'package:flutter/material.dart';

import 'sign_language_webview_mobile.dart'
    if (dart.library.html) 'sign_language_webview_web.dart' as platform_impl;

class SignLanguageWebView extends StatelessWidget {
  final String title;
  final String url;

  const SignLanguageWebView({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return platform_impl.SignLanguageWebViewPlatform(
      title: title,
      url: url,
    );
  }
}
