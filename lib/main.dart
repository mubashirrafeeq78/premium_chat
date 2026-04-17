import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PremiumWebView(),
  ));
}

class PremiumWebView extends StatefulWidget {
  const PremiumWebView({super.key});

  @override
  State<PremiumWebView> createState() => _PremiumWebViewState();
}

class _PremiumWebViewState extends State<PremiumWebView> {
  late final WebViewController _controller;
  bool _isLoading = true; // لوڈنگ کی حالت معلوم کرنے کے لیے

  @override
  void initState() {
    super.initState();

    // پلیٹ فارم کے مطابق ویب ویو کنٹرولر کی سیٹنگ
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserActionForPlayback: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // جب پیج لوڈ ہونا شروع ہو
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // جب پیج مکمل لوڈ ہو جائے
            });
          },
        ),
      )
      // آپ کا ڈومین یہاں شامل ہے
      ..loadRequest(Uri.parse('https://lavenderblush-eagle-882875.hostingersite.com/chat_group.php'));

    // اینڈرائیڈ کے لیے کیمرہ اور مائیکروفون کی پرمیشنز کی اجازت
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // اصل ویب ویو
            WebViewWidget(controller: _controller),
            
            // لوڈنگ سرکل - صرف تب نظر آئے گا جب پیج لوڈ ہو رہا ہو
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue, // آپ اپنی پسند کا رنگ رکھ سکتے ہیں
                ),
              ),
          ],
        ),
      ),
    );
  }
}
