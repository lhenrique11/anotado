import 'dart:io';

class AdHelper{
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-4975130382486636/8639755770";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4975130382486636/8639755770";
    } else {
      throw new UnsupportedError("Unsupported Platform");
    }
  }
}