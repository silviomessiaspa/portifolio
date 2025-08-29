// Fallback (non-web or when dart:html not available). No-op implementation.
Future<void> openExternal(String url) async {
  // Could integrate url_launcher later for mobile/desktop.
}
