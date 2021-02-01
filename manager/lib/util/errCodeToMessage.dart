String errCodeToMessage(String message) {
  if (message == "ERR_TIDY_ENGINE_NOT_EXIST") {
    return "Tidy 엔진을 찾을 수 없습니다.";
  } else {
    return message;
  }
}
