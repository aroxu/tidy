class SettingFolderModel {
  String id;
  String name;
  String description;
  String path;
  List<String> accessRole;

  SettingFolderModel(
      {this.id, this.name, this.description, this.path, this.accessRole});

  SettingFolderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    path = json['path'];
    accessRole = json['accessRole'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['path'] = this.path;
    data['accessRole'] = this.accessRole;
    return data;
  }
}
