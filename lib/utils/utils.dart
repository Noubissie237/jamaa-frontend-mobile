String formatAccountNumber(String accountNumber) {
  return accountNumber.replaceAllMapped(RegExp(r".{1,4}"), (match) => '${match.group(0)} ').trim();
}

String maskAccountNumber(String accountNumber) {
  final lastFour = accountNumber.substring(accountNumber.length - 4);
  return '**** **** **** $lastFour';
}
