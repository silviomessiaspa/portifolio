// Web implementation using dart:html (only compiled when dart.library.html is available)
import 'dart:html' as html;

Future<void> openExternal(String url) async {
  html.window.open(url, '_blank');
}

String assetPublicUrl(String assetKey) {
  if (assetKey.startsWith('assets/assets/')) return assetKey;
  if (assetKey.startsWith('assets/')) return 'assets/$assetKey';
  return 'assets/assets/$assetKey';
}

Future<void> downloadAsset(String assetKey, {String? filename}) async {
  final url = assetPublicUrl(assetKey);
  final anchor = html.AnchorElement(href: url)
    ..download = filename ?? assetKey.split('/').last
    ..target = '_blank';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> downloadFile(String url, {String? filename}) async {
  final a = html.AnchorElement(href: url);
  if (filename != null && filename.isNotEmpty) {
    a.download = filename;
  } else {
    a.setAttribute('download', '');
  }
  html.document.body?.append(a);
  a.click();
  a.remove();
}
