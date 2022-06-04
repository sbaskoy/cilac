import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

import '../model/app_info_model.dart';
import 'network_manager.dart';

class AppState {
  static AppState _instance;
  static AppState get instance {
    _instance ??= AppState._init();
    return _instance;
  }

  AppState._init();

  Future<void> checkAppStatus(BuildContext context) async {
    if (await this.checkConnection()) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("İnternet Baglatınız Yok"),
              content: const Text("Uygulamaya devam edebilmek için lütfen internete baglanın"),
              actions: [
                TextButton(onPressed: () => exit(0), child: const Text("Kapat")),
                new TextButton(
                  child: const Text("Yeniden Dene"),
                  onPressed: () async {
                    if (await this.checkConnection()) {
                      return null;
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    AppInfoModel model =
        await NetworkManager.instance.httpPost(path: "api/lst/surum", model: new AppInfoModel(), data: {});
    var appVersion = Platform.isIOS ? model.iosVer : model.droidVer;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var apkVersion = packageInfo.version;

    int _appVersion = int.parse(appVersion?.replaceAll(".", "") ?? "0");

    int _apkVersion = int.parse(apkVersion.replaceAll(".", ""));

    if (_apkVersion < _appVersion) {
      String appID = packageInfo.packageName;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Yeni Sürüm Mevcut"),
              content: const Text("Uygulamaya devam edebilmek için lütfen uygulamayı güncelleyiniz"),
              actions: [
                TextButton(onPressed: () => exit(0), child: const Text("Kapat")),
                new TextButton(
                  child: const Text("Güncelle"),
                  onPressed: () => StoreRedirect.redirect(androidAppId: appID, iOSAppId: appID),
                )
              ],
            );
          });
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return false;
      }
      return true;
    } on SocketException catch (_) {
      return true;
    }
  }
}
