import 'package:flutter/material.dart';
import 'package:flutter_bkash/src/bkash_payment_status.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FlutterBkashView extends StatefulWidget {
  final String bkashURL;
  final String successCallbackURL;
  final String failureCallbackURL;
  final String cancelledCallbackURL;

  const FlutterBkashView({
    super.key,
    required this.bkashURL,
    required this.successCallbackURL,
    required this.failureCallbackURL,
    required this.cancelledCallbackURL,
  });

  @override
  State<FlutterBkashView> createState() => _FlutterBkashViewState();
}

class _FlutterBkashViewState extends State<FlutterBkashView> {
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (webViewController != null &&
              await webViewController!.canGoBack()) {
            await webViewController!.goBack();
          } else {
            if (context.mounted) {
              Navigator.of(context).pop(BkashPaymentStatus.canceled);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.pink,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>
                Navigator.of(context).pop(BkashPaymentStatus.canceled),
          ),
          title: const Text('bKash Checkout'),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.bkashURL)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            clearCache: true,
            useOnLoadResource: true,
            useShouldOverrideUrlLoading: true,
            supportZoom: false,
            transparentBackground: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url.toString();

            if (url.startsWith(widget.successCallbackURL)) {
              Navigator.of(context).pop(BkashPaymentStatus.successed);
              return NavigationActionPolicy.CANCEL;
            } else if (url.startsWith(widget.failureCallbackURL)) {
              Navigator.of(context).pop(BkashPaymentStatus.failed);
              return NavigationActionPolicy.CANCEL;
            } else if (url.startsWith(widget.cancelledCallbackURL)) {
              Navigator.of(context).pop(BkashPaymentStatus.canceled);
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadError: (controller, url, code, message) {
            Navigator.of(context).pop(BkashPaymentStatus.failed);
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            Navigator.of(context).pop(BkashPaymentStatus.failed);
          },
        ),
      ),
    );
  }
}
