import 'package:flutter/services.dart';

import 'share_platform_stub.dart' if (dart.library.js_interop) 'share_platform_web.dart' as platform;

enum ShareOutcome {
  /// Menu de partage du système ouvert.
  shared,

  /// Pas de menu de partage : lien copié dans le presse-papiers.
  copied,

  /// Ni menu de partage ni presse-papiers (refusé par le navigateur) : le
  /// lien est à montrer pour une copie à la main.
  failed,
}

/// Partage d'un lien : menu de partage du système quand il existe (surtout
/// sur téléphone), sinon copie du lien.
class ShareService {
  static Future<ShareOutcome> share({required String text, required Uri url}) async {
    if (await platform.nativeShare(text, url.toString())) return ShareOutcome.shared;
    try {
      await Clipboard.setData(ClipboardData(text: url.toString()));
      return ShareOutcome.copied;
    } on PlatformException {
      return ShareOutcome.failed;
    }
  }
}
