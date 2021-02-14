library manager.globals;

import 'model/settingFolderModel.dart';
import 'model/settingUserModel.dart';

bool engineInstalledChecked = false;
bool reCheckRequired = true;
bool installingEngine = false;
bool isCheckingPassword = false;
bool isEngineServiceRunning = false;

List<dynamic> prevEngineData;

String userPasswordForSudo = "";

bool settingsGeneralEnableAuth;
bool settingsGeneralEnableAuthModified = false;
int settingsGeneralPort;
bool settingsGeneralPortModified = false;
String settingsGeneralName;
bool settingsGeneralNameModified = false;
String settingsGeneralJwtSecret;
bool settingsGeneralJwtSecretModified = false;
String settingsGeneralStartOnBoot;
bool settingsGeneralStartOnBootModified = false;
List<SettingUserModel> settingsUser;
bool settingsUserModified = false;
List<SettingFolderModel> settingsFolder;
bool settingsFolderModified = false;
