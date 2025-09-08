// Fallback (non-web or when dart:html not available). No-op implementations.
Future<void> openExternal(String url) async {
  // Could integrate url_launcher later for mobile/desktop.
}

// Maps a Flutter asset key to the public URL in Flutter web build output.
// Example: 'assets/pdf/file.pdf' -> 'assets/assets/pdf/file.pdf'
String assetPublicUrl(String assetKey) {
  if (assetKey.startsWith('assets/assets/')) return assetKey;
  if (assetKey.startsWith('assets/')) return 'assets/$assetKey';
  return 'assets/assets/$assetKey';
}

// No-op on non-web. On web we trigger a download; here we just compute URL.
Future<void> downloadAsset(String assetKey, {String? filename}) async {
  // Intentionally no-op on non-web.
}

Future<void> downloadFile(String url, {String? filename}) async {
  // No-op on non-web in this project.
}
