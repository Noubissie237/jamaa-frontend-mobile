class ApiConstants {
  static const String baseIp = '10.226.2.2';
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
  static const String bankServiceUrl = '$baseUrl/SERVICE-BANKS/graphql';
  static const String transactionServiceUrl = '$baseUrl/SERVICE-TRANSACTIONS/graphql';
  static const String transfertServiceUrl = '$baseUrl/SERVICE-TRANSFERT/graphql';
  static const String rechargeRetraitServiceUrl = '$baseUrl/SERVICE-RECHARGE-RETRAIT/graphql';
}
