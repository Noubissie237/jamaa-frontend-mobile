class ApiConstants {
  static const String baseIp = '10.163.131.2';
  static const String basePort = '8079';

  static const String baseUrl = 'http://$baseIp:$basePort';

  // Services
  static const String authService = '$baseUrl/SERVICE-AUTH';

  // Endpoints
  static const String login = '$authService/auth/login';
  static const String register = '$baseUrl/SERVICE-USERS/graphql';
  static const String uploadCni = '$baseUrl/SERVICE-USERS/upload/cni';
  static const String accountServiceUrl = '$baseUrl/SERVICE-ACCOUNT/graphql';
  static const String cardServiceUrl = '$baseUrl/SERVICE-CARD/graphql';
}
