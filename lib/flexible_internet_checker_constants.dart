part of 'flexible_internet_checker.dart';

abstract class FlexibleInternetCheckerConstants {
  /// Default timeout duration (5 seconds) for checking connectivity.
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 2);

  /// Default interval (5 seconds) between consecutive connectivity checks.
  static const Duration DEFAULT_INTERVAL = Duration(seconds: 2);

  /// Default threshold duration to consider a connection as "slow".
  static const Duration DEFAULT_SLOW_CONNECTION_THRESHOLD = Duration(
    seconds: 2,
  );

  /// URLs used for connectivity checks.

  /// URL 1
  static const String URL_1 = 'https://one.one.one.one';

  /// URL 2
  static const String URL_2 = 'https://dns.google';

  /// URL 3
  static const String URL_3 = 'http://captive.apple.com';

  /// Default list of addresses to check connectivity against.
  // ignore: non_constant_identifier_names
  static final List<AddressCheckOption> DEFAULT_ADDRESSES =
      List<AddressCheckOption>.unmodifiable(<AddressCheckOption>[
    AddressCheckOption(uri: Uri.parse(URL_1)),
    AddressCheckOption(uri: Uri.parse(URL_2)),
    AddressCheckOption(uri: Uri.parse(URL_3)),
  ]);
}
