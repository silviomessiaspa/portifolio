// Web implementation using dart:html (only compiled when dart.library.html is available)
import 'dart:html' as html;

Future<void> openExternal(String url) async {
  html.window.open(url, '_blank');
}
