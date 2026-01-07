import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_viewmodel.dart';

/// WebView page for ECU SIS authentication.
/// Opens the ECU login page and extracts the session token after successful login.
class AuthWebViewPage extends StatefulWidget {
  const AuthWebViewPage({super.key});

  @override
  State<AuthWebViewPage> createState() => _AuthWebViewPageState();
}

class _AuthWebViewPageState extends State<AuthWebViewPage> {
  static const String _targetUrl = 'https://sis.ecu.edu.eg/UI/StudentView/Home.aspx';
  static const String _cookieDomain = 'https://sis.ecu.edu.eg';
  
  InAppWebViewController? _webViewController;
  final CookieManager _cookieManager = CookieManager.instance();
  
  bool _isLoading = true;
  double _progress = 0;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Clear all cookies for a fresh session to avoid redirect loops
    if (!kIsWeb) {
      await _cookieManager.deleteAllCookies();
    }
    setState(() {
      _hasInitialized = true;
    });
  }

  Future<void> _checkForSessionCookie() async {
    if (kIsWeb) {
      // On web, we can't access cookies from external domains
      if (mounted) {
        _showWebPlatformSnackBar();
      }
      return;
    }

    try {
      // Check cookies from the domain
      final cookies = await _cookieManager.getCookies(
        url: WebUri(_cookieDomain),
      );

      debugPrint('All cookies found: ${cookies.length}');
      for (final cookie in cookies) {
        debugPrint('Cookie: ${cookie.name} = ${cookie.value}');
        if (cookie.name == 'ASP.NET_SessionId') {
          await _saveAndClose(cookie.value);
          return;
        }
      }

      // Also check with full URL path
      final cookiesWithPath = await _cookieManager.getCookies(
        url: WebUri(_targetUrl),
      );

      for (final cookie in cookiesWithPath) {
        debugPrint('Cookie (with path): ${cookie.name} = ${cookie.value}');
        if (cookie.name == 'ASP.NET_SessionId') {
          await _saveAndClose(cookie.value);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session cookie not found yet. Please complete login.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking cookies: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking cookies: $e')),
        );
      }
    }
  }

  Future<void> _saveAndClose(String token) async {
    if (!mounted) return;
    
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.saveSessionToken(token);
    
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showWebPlatformSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'On web, please use DevTools (F12 > Application > Cookies) to get the session token.',
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _showManualTokenDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Session Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If automatic detection fails:\n'
              '1. Open browser DevTools (F12)\n'
              '2. Go to Application > Cookies\n'
              '3. Find ASP.NET_SessionId\n'
              '4. Copy and paste the value below',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'ASP.NET_SessionId',
                border: OutlineInputBorder(),
                hintText: 'Paste your session token here',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _saveAndClose(controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPage() async {
    await _cookieManager.deleteAllCookies();
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_targetUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('ECU Authentication'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ECU Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkForSessionCookie,
            tooltip: 'Get Session Token',
          ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showManualTokenDialog,
              tooltip: 'Enter Token Manually',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
            ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_targetUrl)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: false,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                clearCache: false,
                cacheEnabled: true,
                thirdPartyCookiesEnabled: true,
                sharedCookiesEnabled: true,
                allowsBackForwardNavigationGestures: true,
                userAgent:
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                supportZoom: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                allowContentAccess: true,
                allowFileAccess: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                debugPrint('Loading: $url');
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                debugPrint('Loaded: $url');
                setState(() {
                  _isLoading = false;
                });

                // Check if we're on the home page after auth
                if (url != null && url.toString().contains('StudentView/Home.aspx')) {
                  await _checkForSessionCookie();
                }
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                // Accept SSL certificates
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onReceivedError: (controller, request, error) {
                debugPrint('WebView Error: ${error.description}');
              },
              onReceivedHttpError: (controller, request, response) {
                debugPrint(
                  'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
