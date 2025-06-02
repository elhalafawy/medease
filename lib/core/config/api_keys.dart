class ApiKeys {
  static const String geminiApiKey = 'AIzaSyDCp7PU3h5aXRelLgelBNS_hs_v2J3pZGg';

  static void verifyApiKey() {
    print('API Key loaded: ${geminiApiKey.substring(0, 5)}...');
  }
} 