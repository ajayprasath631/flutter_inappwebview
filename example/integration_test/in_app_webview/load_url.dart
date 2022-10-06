import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void loadUrl() {
  final shouldSkip = kIsWeb ? false :
      ![
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);

  var initialUrl = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<String> firstUrlLoad = Completer<String>();
    final Completer<String> loadedUrl = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest:
          URLRequest(url: initialUrl),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (url.toString() == initialUrl.toString() && !firstUrlLoad.isCompleted) {
              firstUrlLoad.complete(url.toString());
            } else if (url.toString() == TEST_CROSS_PLATFORM_URL_1.toString() && !loadedUrl.isCompleted) {
              loadedUrl.complete(url.toString());
            }
          },
        ),
      ),
    );
    final InAppWebViewController controller =
    await controllerCompleter.future;
    expect(await firstUrlLoad.future, initialUrl.toString());

    await controller.loadUrl(
        urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1));
    expect(await loadedUrl.future, TEST_CROSS_PLATFORM_URL_1.toString());
  }, skip: shouldSkip);
}