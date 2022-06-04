class AppInfoModel {
  int id;
  String webVer;
  String apiVer;
  String iosVer;
  String droidVer;


  AppInfoModel({this.id, this.webVer, this.apiVer, this.iosVer, this.droidVer});
  AppInfoModel.fromJson(json) {
    id = json["id"];
    webVer = json["webVer"];
    apiVer = json["apiVer"];
    iosVer = json["iosVer"];
    droidVer = json["droidVer"];

  }
  fromJson(json) => AppInfoModel.fromJson(json);
}
