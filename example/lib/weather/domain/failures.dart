sealed class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super("Can't reach weather service");
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super("City not found. Try another name.");
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super("Something went wrong");
}
