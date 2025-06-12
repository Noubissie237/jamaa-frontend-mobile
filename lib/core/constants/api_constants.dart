class ApiConstants {
  static const String baseIp = '10.244.168.2';
  static const String basePort = '8079';

  static const String baseUrl = 'http://$baseIp:$basePort';

  // Services
  static const String authService = '$baseUrl/SERVICE-AUTH';

  // Endpoints
  static const String login = '$authService/auth/login';
  static const String register = '$baseUrl/SERVICE-USERS/graphql';
}
