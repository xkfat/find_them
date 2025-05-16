class CustomException implements Exception {
  final dynamic _message;
  final dynamic _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return '$_prefix: $_message';
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message])
    : super(message, 'Error During Communication');
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, 'Invalid Request');
}

class NotFoundException extends CustomException {
  NotFoundException([message]) : super(message, 'Not Found');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, 'Unauthorised');
}

class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) : super(message, 'Invalid Input');
}

class Failure {
  final int? code;
  final String? message;

  Failure({this.message, this.code});

  @override
  String toString() => message!;
}
