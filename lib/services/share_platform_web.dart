import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Ouvre le menu de partage du navigateur (Web Share API) ; false s'il
/// n'existe pas ou échoue (le lien est alors copié).
Future<bool> nativeShare(String text, String url) async {
  final navigator = web.window.navigator;
  if (!(navigator as JSObject).has('share')) return false;
  final data = web.ShareData(text: text, url: url);
  if (navigator.has('canShare') && !navigator.canShare(data)) return false;
  try {
    await navigator.share(data).toDart;
    return true;
  } catch (error) {
    // Menu fermé sans partager : rien de plus à faire.
    if (error.toString().contains('AbortError')) return true;
    return false;
  }
}
