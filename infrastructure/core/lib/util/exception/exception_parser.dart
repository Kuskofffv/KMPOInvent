import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class ExceptionParser {
  ExceptionParser._();

  static String parseException(Object exception) {
    if (exception is ParseError) {
      return exception.message;

      // return switch (exception.code) {
      //   ParseError.accountAlreadyLinked => "Аккаунт уже привязан",
      //   ParseError.aggregateError => "Ошибка агрегации",
      //   ParseError.cacheMiss => "Кэш не найден",
      //   ParseError.commandUnavailable => "Команда недоступна",
      //   ParseError.connectionFailed => "Ошибка соединения",
      //   ParseError.duplicateValue => "Дублирующее значение",
      //   ParseError.emailMissing => "Email не найден",
      //   ParseError.emailNotFound => "Email не найден",
      //   ParseError.emailTaken => "Email занят",
      //   ParseError.exceededQuota => "Превышена квота",
      //   ParseError.fileDeleteError => "Ошибка удаления файла",
      //   ParseError.fileReadError => "Ошибка чтения файла",
      //   ParseError.fileSaveError => "Ошибка сохранения файла",
      //   ParseError.incorrectType => "Некорректный тип",
      //   ParseError.internalServerError => "Внутренняя ошибка сервера",
      //   ParseError.invalidAcl => "Некорректный ACL",
      //   ParseError.invalidChannelName => "Некорректное имя канала",
      //   ParseError.invalidClassName => "Некорректное имя класса",
      //   ParseError.invalidEmailAddress => "Некорректный email",
      //   ParseError.invalidEventName => "Некорректное имя события",
      //   ParseError.invalidFileName => "Некорректное имя файла",
      //   ParseError.invalidImageData => "Некорректные данные изображения",
      //   ParseError.invalidJson => "Некорректный JSON",
      //   ParseError.invalidKeyName => "Некорректное имя ключа",
      //   ParseError.invalidLinkedSession => "Некорректная привязка сессии",
      //   ParseError.invalidQuery => "Неверный запрос",
      //   ParseError.missingObjectId => "Не указан идентификатор объекта",
      //   ParseError.invalidPointer => "Неверный указатель",
      //   ParseError.notInitialized =>
      //     "Вы должны вызвать Parse().initialize перед использованием библиотеки Parse",
      //   ParseError.pushMisconfigured => "Неправильная конфигурация Push",
      //   ParseError.objectTooLarge => "Объект слишком большой",
      //   ParseError.operationForbidden => "Операция запрещена",
      //   ParseError.invalidNestedKey => "Неверный ключ в вложенном JSONObject",
      //   ParseError.timeout => "Запрос на сервере завершился по таймауту",
      //   ParseError.missingContentType => "Отсутствует тип содержимого",
      //   ParseError.missingContentLength => "Отсутствует длина содержимого",
      //   ParseError.invalidContentLength => "Неверная длина содержимого",
      //   ParseError.fileTooLarge => "Файл слишком большой",
      //   ParseError.invalidRoleName => "Неверное имя роли",
      //   ParseError.otherCause => "Ошибка соединения",
      //   _ => "Произошла ошибка"
      // };
    } else if (exception is HandshakeException) {
      return 'Ошибка соединения';
    } else if (exception is TimeoutException) {
      return 'Время ожидания ответа истекло';
    } else if (exception is TypeError) {
      return 'Некорректный формат данных';
    } else if (exception is FormatException) {
      return 'Некорректный формат данных';
    } else if (exception is DioException) {
      final codeMessage = switch (exception.response?.statusCode) {
        400 => 'Ошибка ввода данных',
        401 => 'Необходима авторизация',
        402 => 'Необходима оплата',
        403 => 'Доступ запрещен',
        404 => 'Запрашиваемый ресурс не найден',
        405 => 'Метод не поддерживается',
        406 => 'Неприемлемо',
        407 => 'Требуется аутентификация прокси',
        408 => 'Время ожидания истекло',
        409 => 'Конфликт',
        410 => 'Удалено',
        411 => 'Необходима длина',
        412 => 'Предусловие не соблюдено',
        413 => 'Слишком длинный запрос',
        414 => 'Слишком длинный запрос',
        415 => 'Неподдерживаемый тип данных',
        416 => 'Диапазон не удовлетворен',
        417 => 'Ожидаемое недоступно',
        418 => 'Что то пошло не так',
        500 => 'Внутренняя ошибка сервера',
        502 => 'Неверный ответ сервера',
        503 => 'Сервис недоступен',
        504 => 'Сервер не отвечает',
        _ => null,
      };

      final typeMessage = switch (exception.type) {
        DioExceptionType.connectionTimeout => 'Время ожидания ответа истекло',
        DioExceptionType.sendTimeout => 'Время ожидания ответа истекло',
        DioExceptionType.receiveTimeout => 'Время ожидания ответа истекло',
        DioExceptionType.badCertificate => 'Неверный сертификат',
        DioExceptionType.badResponse => 'Неверный ответ сервера',
        DioExceptionType.cancel => 'Запрос отменен',
        DioExceptionType.connectionError => 'Не удалось установить соединение',
        DioExceptionType.unknown => 'Неизвестная ошибка',
      };

      String? tMessage;

      // Trying to get the error message from the server response
      try {
        tMessage = exception.response?.data['humanMessage'];
      } catch (e) {}

      // If the message is not found, try to get it from the plain response
      // TS-404: See RequestOptions _setStreamType<T>(RequestOptions requestOptions)
      if (tMessage == null) {
        try {
          final response = exception.response?.data;
          tMessage = json.decode(response)['humanMessage'];
        } catch (e) {}
      }

      // Hiding the default message
      if (tMessage == "Произошла ошибка") {
        tMessage = null;
      }
      return tMessage ?? codeMessage ?? typeMessage;
    } else if (exception is ParseException || exception is ParseError) {
      try {
        return (exception as dynamic).message;
      } catch (e) {
        return exception.toString();
      }
    } else {
      if (exception is Exception) {
        try {
          return (exception as dynamic).message;
        } on Object {}
      }
      return 'Неизвестная ошибка';
    }
  }
}

class ParseErrorCodes {
  ParseErrorCodes._();

  /// Error code indicating some error other than those enumerated here.
  static const int otherCause = -1;

  /// Error code indicating that something has gone wrong with the server.
  static const int internalServerError = 1;

  /// Error code indicating the connection to the Parse servers failed.
  static const int connectionFailed = 100;

  /// Error code indicating the specified object doesn't exist.
  static const int objectNotFound = 101;

  /// Error code indicating you tried to query with a datatype that doesn't
  /// support it, like exact matching an array or object.
  static const int invalidQuery = 102;

  /// Error code indicating a missing or invalid classname. Classnames are
  /// case-sensitive. They must start with a letter, and a-zA-Z0-9_ are the
  /// only valid characters.
  static const int invalidClassName = 103;

  /// Error code indicating an unspecified object id.
  static const int missingObjectId = 104;

  /// Error code indicating an invalid key name. Keys are case-sensitive. They
  /// must start with a letter, and a-zA-Z0-9_ are the only valid characters.
  static const int invalidKeyName = 105;

  /// Error code indicating a malformed pointer. You should not see this unless
  /// you have been mucking about changing internal Parse code.
  static const int invalidPointer = 106;

  /// Error code indicating that badly formed JSON was received upstream. This
  /// either indicates you have done something unusual with modifying how
  /// things encode to JSON, or the network is failing badly.
  static const int invalidJson = 107;

  /// Error code indicating that the feature you tried to access is only
  /// available internally for testing purposes.
  static const int commandUnavailable = 108;

  /// You must call Parse().initialize before using the Parse library.
  static const int notInitialized = 109;

  /// Error code indicating that a field was set to an inconsistent type.
  static const int incorrectType = 111;

  /// Error code indicating an invalid channel name. A channel name is either
  /// an empty string (the broadcast channel) or contains only a-zA-Z0-9_
  /// characters and starts with a letter.
  static const int invalidChannelName = 112;

  /// Error code indicating that push is misconfigured.
  static const int pushMisconfigured = 115;

  /// Error code indicating that the object is too large.
  static const int objectTooLarge = 116;

  /// Error code indicating that the operation isn't allowed for clients.
  static const int operationForbidden = 119;

  /// Error code indicating the result was not found in the cache.
  static const int cacheMiss = 120;

  /// Error code indicating that an invalid key was used in a nested
  /// JSONObject.
  static const int invalidNestedKey = 121;

  /// Error code indicating that an invalid filename was used for ParseFile.
  /// A valid file name contains only a-zA-Z0-9_. characters and is between 1
  /// and 128 characters.
  static const int invalidFileName = 122;

  /// Error code indicating an invalid ACL was provided.
  static const int invalidAcl = 123;

  /// Error code indicating that the request timed out on the server. Typically
  /// this indicates that the request is too expensive to run.
  static const int timeout = 124;

  /// Error code indicating that the email address was invalid.
  static const int invalidEmailAddress = 125;

  /// Error code indicating a missing content type.
  static const int missingContentType = 126;

  /// Error code indicating a missing content length.
  static const int missingContentLength = 127;

  /// Error code indicating an invalid content length.
  static const int invalidContentLength = 128;

  /// Error code indicating a file that was too large.
  static const int fileTooLarge = 129;

  /// Error code indicating an error saving a file.
  static const int fileSaveError = 130;

  /// Error code indicating that a unique field was given a value that is
  /// already taken.
  static const int duplicateValue = 137;

  /// Error code indicating that a role's name is invalid.
  static const int invalidRoleName = 139;

  /// Error code indicating that an application quota was exceeded.  Upgrade to
  /// resolve.
  static const int exceededQuota = 140;

  /// Error code indicating that a Cloud Code script failed.
  static const int scriptFailed = 141;

  /// Error code indicating that a Cloud Code validation failed.
  static const int validationError = 142;

  /// Error code indicating that invalid image data was provided.
  static const int invalidImageData = 143;

  /// Error code indicating an unsaved file.
  static const int unsavedFileError = 151;

  /// Error code indicating an invalid push time.
  static const int invalidPushTimeError = 152;

  /// Error code indicating an error deleting a file.
  static const int fileDeleteError = 153;

  /// Error code indicating an error deleting an unnamed file.
  static const int fileDeleteUnnamedError = 161;

  /// Error code indicating that the application has exceeded its request
  /// limit.
  static const int requestLimitExceeded = 155;

  /// Error code indicating that the request was a duplicate and has been discarded due to
  /// idempotency rules.
  static const int duplicateRequest = 159;

  /// Error code indicating an invalid event name.
  static const int invalidEventName = 160;

  /// Error code indicating that a field had an invalid value.
  static const int invalidValue = 162;

  /// Error code indicating that the username is missing or empty.
  static const int usernameMissing = 200;

  /// Error code indicating that the password is missing or empty.
  static const int passwordMissing = 201;

  /// Error code indicating that the username has already been taken.
  static const int usernameTaken = 202;

  /// Error code indicating that the email has already been taken.
  static const int emailTaken = 203;

  /// Error code indicating that the email is missing, but must be specified.
  static const int emailMissing = 204;

  /// Error code indicating that a user with the specified email was not found.
  static const int emailNotFound = 205;

  /// Error code indicating that a user object without a valid session could
  /// not be altered.
  static const int sessionMissing = 206;

  /// Error code indicating that a user can only be created through signup.
  static const int mustCreateUserThroughSignup = 207;

  /// Error code indicating that an an account being linked is already linked
  /// to another user.
  static const int accountAlreadyLinked = 208;

  /// Error code indicating that the current session token is invalid.
  static const int invalidSessionToken = 209;

  /// Error code indicating an error enabling or verifying MFA
  static const int mfaError = 210;

  /// Error code indicating that a valid MFA token must be provided
  static const int mfaTokenRequired = 211;

  /// Error code indicating that a user cannot be linked to an account because
  /// that account's id could not be found.
  static const int linkedIdMissing = 250;

  /// Error code indicating that a user with a linked (e.g. Facebook) account
  /// has an invalid session.
  static const int invalidLinkedSession = 251;

  /// Error code indicating that a service being linked (e.g. Facebook or
  /// Twitter) is unsupported.
  static const int unsupportedService = 252;

  /// Error code indicating an invalid operation occured on schema
  static const int invalidSchemaOperation = 255;

  /// Error code indicating that there were multiple errors. Aggregate errors
  /// have an "errors" property, which is an array of error objects with more
  /// detail about each error that occurred.
  static const int aggregateError = 600;

  /// Error code indicating the client was unable to read an input file.
  static const int fileReadError = 601;

  /// Error code indicating a real error code is unavailable because
  /// we had to use an XDomainRequest object to allow CORS requests in
  /// Internet Explorer, which strips the body from HTTP responses that have
  /// a non-2XX status code.
  static const int xDomainRequest = 602;
}
