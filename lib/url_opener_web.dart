import 'dart:js_interop';

@JS('window.open')
external void _windowOpen(String url, String target);

@JS('document.createElement')
external JSObject _createElement(String tagName);

extension type HTMLAnchorElement(JSObject _) implements JSObject {
  @JS('href')
  external set href(String value);
  @JS('download')
  external set download(String value);
  @JS('target')
  external set target(String value);
  @JS('click')
  external void click();
  @JS('remove')
  external void remove();
  @JS('setAttribute')
  external void setAttribute(String name, String value);
}

@JS('document.body.append')
external void _bodyAppend(JSObject element);

Future<void> openExternal(String url) async {
  _windowOpen(url, '_blank');
}

String assetPublicUrl(String assetKey) {
  if (assetKey.startsWith('assets/assets/')) return assetKey;
  if (assetKey.startsWith('assets/')) return 'assets/$assetKey';
  return 'assets/assets/$assetKey';
}

Future<void> downloadAsset(String assetKey, {String? filename}) async {
  final url = assetPublicUrl(assetKey);
  final anchor = HTMLAnchorElement(_createElement('a'))
    ..href = url
    ..download = filename ?? assetKey.split('/').last
    ..target = '_blank';
  _bodyAppend(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> downloadFile(String url, {String? filename}) async {
  final anchor = HTMLAnchorElement(_createElement('a'))
    ..href = url;
  if (filename != null && filename.isNotEmpty) {
    anchor.download = filename;
  } else {
    anchor.setAttribute('download', '');
  }
  _bodyAppend(anchor);
  anchor.click();
  anchor.remove();
}
