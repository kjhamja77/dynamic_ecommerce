import 'country_code_detector.dart';

/// Simple test class to demonstrate country code detection
/// This can be used for testing and debugging purposes
class CountryCodeDetectorTest {
  static void runTests() {
    print('🧪 Testing Country Code Detection...\n');
    
    // Test cases with expected results
    final testCases = [
      ('1234567890', 'US'), // US number
      ('44123456789', 'GB'), // UK number
      ('49123456789', 'DE'), // German number
      ('33123456789', 'FR'), // French number
      ('86123456789', 'CN'), // Chinese number
      ('81123456789', 'JP'), // Japanese number
      ('55123456789', 'BR'), // Brazilian number
      ('6123456789', 'AU'), // Australian number
      ('123456789', 'US'), // US number (shorter)
      ('999999999', null), // Unknown prefix
      ('', null), // Empty string
    ];
    
    int passed = 0;
    int total = testCases.length;
    
    for (final testCase in testCases) {
      final phoneNumber = testCase.$1;
      final expectedCountryCode = testCase.$2;
      
      final detectedCountryCode = CountryCodeDetector.detectCountryCode(phoneNumber);
      final success = detectedCountryCode == expectedCountryCode;
      
      print('📱 Phone: $phoneNumber');
      print('   Expected: ${expectedCountryCode ?? 'null'}');
      print('   Detected: ${detectedCountryCode ?? 'null'}');
      print('   Result: ${success ? '✅ PASS' : '❌ FAIL'}');
      print('');
      
      if (success) passed++;
    }
    
    print('📊 Test Results: $passed/$total tests passed');
    print('Success Rate: ${(passed / total * 100).toStringAsFixed(1)}%');
  }
  
  static void testSpecificCountries() {
    print('🌍 Testing Specific Countries...\n');
    
    final countryTests = [
      ('+1 555 123 4567', 'US'),
      ('+44 20 7946 0958', 'GB'),
      ('+49 30 12345678', 'DE'),
      ('+33 1 42 86 83 26', 'FR'),
      ('+86 138 0013 8000', 'CN'),
      ('+81 3 1234 5678', 'JP'),
      ('+55 11 99999 9999', 'BR'),
      ('+61 2 1234 5678', 'AU'),
      ('+91 98765 43210', 'IN'),
      ('+971 50 123 4567', 'AE'),
    ];
    
    for (final test in countryTests) {
      final phoneNumber = test.$1;
      final expectedCountry = test.$2;
      
      // Remove + and spaces for testing
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final detectedCountry = CountryCodeDetector.detectCountry(cleanNumber);
      
      print('📞 $phoneNumber');
      print('   Clean: $cleanNumber');
      print('   Expected: $expectedCountry');
      print('   Detected: ${detectedCountry?.countryCode ?? 'null'}');
      print('   Country: ${detectedCountry?.name ?? 'null'}');
      print('   Flag: ${detectedCountry?.flagEmoji ?? 'null'}');
      print('');
    }
  }
}
