class SettingConfigModel {
  String name;
  int port;
  String jwtSecret;
  bool enableAuth;

  SettingConfigModel({this.name, this.port, this.jwtSecret, this.enableAuth});

  SettingConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    port = json['port'];
    jwtSecret = json['jwtSecret'];
    enableAuth = json['enableAuth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['port'] = this.port;
    data['jwtSecret'] = this.jwtSecret;
    data['enableAuth'] = this.enableAuth;
    return data;
  }
}
