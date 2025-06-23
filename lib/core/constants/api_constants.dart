class ApiConstants {
  static const String baseIp = '109.199.113.94';
  static const String basePort = '30079';

  static const String baseUrl = 'http://$baseIp:$basePort';

  // Services
  static const String authService = '$baseUrl/service-auth';

  // Endpoints
  static const String login = '$authService/auth/login';
  static const String register = '$baseUrl/service-users/graphql';
  static const String uploadCni = '$baseUrl/service-users/upload/cni';
  static const String accountServiceUrl = '$baseUrl/service-account/graphql';
  static const String cardServiceUrl = '$baseUrl/service-card/graphql';
  static const String bankServiceUrl = '$baseUrl/service-banks/graphql';
  static const String transactionServiceUrl = '$baseUrl/service-transactions/graphql';
  static const String transfertServiceUrl = '$baseUrl/service-transfert/graphql';
  static const String rechargeRetraitServiceUrl = '$baseUrl/service-recharge-retrait/graphql';
}
