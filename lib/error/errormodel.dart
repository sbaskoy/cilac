class BadRequestError implements Exception {
  final String msg;

  BadRequestError({this.msg});

  @override
  String toString() {
    super.toString();
    return this.msg ?? "Bad request error";
  }
}

class InternalServerError implements Exception {
  final String msg;

  InternalServerError({this.msg});
  static to() {
    return InternalServerError(msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
  }

  @override
  String toString() {
    super.toString();
    return this.msg ?? "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz";
  }
}

class AuthorizeError implements Exception {
  final String msg;
  AuthorizeError({this.msg});
  static to() {
    return AuthorizeError(msg: "Oturumunuzun süresi dolmuş.Yeniden giriş yapınız");
  }

  @override
  String toString() {
    super.toString();
    return this.msg ?? "Oturumunuzun süresi dolmuş.Yeniden giriş yapınız";
  }
}
