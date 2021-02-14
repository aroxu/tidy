class SettingUserModel {
  String name;
  String password;
  List<String> role;

  SettingUserModel({this.name, this.password, this.role});

  SettingUserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
    role = json['role'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['password'] = this.password;
    data['role'] = this.role;
    return data;
  }
}
