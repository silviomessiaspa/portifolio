import 'package:web/web.dart' as web;

Future<void> openExternal(String url) async {
  web.window.open(url, '_blank');
}

String assetPublicUrl(String assetKey) {
  if (assetKey.startsWith('assets/assets/')) return assetKey;
  if (assetKey.startsWith('assets/')) return 'assets/$assetKey';
  return 'assets/assets/$assetKey';
}

Future<void> downloadAsset(String assetKey, {String? filename}) async {
  final url = assetPublicUrl(assetKey);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename ?? assetKey.split('/').last
    ..target = '_blank';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> downloadFile(String url, {String? filename}) async {
  final anchor = web.HTMLAnchorElement()..href = url;
  if (filename != null && filename.isNotEmpty) {
    anchor.download = filename;
  } else {
    anchor.setAttribute('download', '');
  }
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
