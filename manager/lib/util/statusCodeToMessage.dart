String statusCodeToMessage(String message) {
  switch (message) {
    case "ERR_TIDY_ENGINE_NOT_EXIST":
      return "Tidy 엔진을 찾을 수 없어 시작하거나 정지할 수 없습니다.";
    case "ERR_ALREADY_STARTED":
      return "Tidy 엔진이 이미 시작되었습니다.";
    case "ERR_ALREADY_STOPPED":
      return "Tidy 엔진이 이미 중지되었습니다.";
    case "STP_BEFORE_UNINSTALL":
      return "삭제 하기 전에 Tidy 엔진을 정지하는 중입니다.";
    case "PROCESS_RUNNING":
      return "Tidy 엔진이 실행중입니다.";
    case "PROCESS_STOPPED":
      return "Tidy 엔진이 실행중이지 않습니다.";
    case "PROCESS_STOPPED_OR_NOT_INSTALLED":
      return "Tidy 엔진이 실행중이지 않습니다.";

    case "WRONG_PASS":
      return "비밀번호가 올바르지 않습니다.";

    default:
      return message;
  }
}
