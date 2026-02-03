import 'package:country_picker/country_picker.dart';

class CountryCodeDetector {
  // Mapping of phone number prefixes to country codes
  // This covers the most common country codes
  static const Map<String, String> _prefixToCountryCode = {
    // North America
    '1': 'US', // United States/Canada
    
    // Europe
    '44': 'GB', // United Kingdom
    '49': 'DE', // Germany
    '33': 'FR', // France
    '39': 'IT', // Italy
    '34': 'ES', // Spain
    '31': 'NL', // Netherlands
    '32': 'BE', // Belgium
    '41': 'CH', // Switzerland
    '43': 'AT', // Austria
    '45': 'DK', // Denmark
    '46': 'SE', // Sweden
    '47': 'NO', // Norway
    '48': 'PL', // Poland
    '351': 'PT', // Portugal
    '30': 'GR', // Greece
    '353': 'IE', // Ireland
    '358': 'FI', // Finland
    '420': 'CZ', // Czech Republic
    '421': 'SK', // Slovakia
    '385': 'HR', // Croatia
    '386': 'SI', // Slovenia
    '370': 'LT', // Lithuania
    '371': 'LV', // Latvia
    '372': 'EE', // Estonia
    '356': 'MT', // Malta
    '357': 'CY', // Cyprus
    '352': 'LU', // Luxembourg
    
    // Asia
    '86': 'CN', // China
    '81': 'JP', // Japan
    '82': 'KR', // South Korea
    '65': 'SG', // Singapore
    '60': 'MY', // Malaysia
    '66': 'TH', // Thailand
    '63': 'PH', // Philippines
    '62': 'ID', // Indonesia
    '84': 'VN', // Vietnam
    '855': 'KH', // Cambodia
    '856': 'LA', // Laos
    '95': 'MM', // Myanmar
    '880': 'BD', // Bangladesh
    '91': 'IN', // India
    '92': 'PK', // Pakistan
    '93': 'AF', // Afghanistan
    '94': 'LK', // Sri Lanka
    '977': 'NP', // Nepal
    '975': 'BT', // Bhutan
    '960': 'MV', // Maldives
    '98': 'IR', // Iran
    '964': 'IQ', // Iraq
    '965': 'KW', // Kuwait
    '966': 'SA', // Saudi Arabia
    '971': 'AE', // UAE
    '973': 'BH', // Bahrain
    '974': 'QA', // Qatar
    '968': 'OM', // Oman
    '967': 'YE', // Yemen
    '962': 'JO', // Jordan
    '961': 'LB', // Lebanon
    '963': 'SY', // Syria
    '972': 'IL', // Israel
    '970': 'PS', // Palestine
    '90': 'TR', // Turkey
    '374': 'AM', // Armenia
    '994': 'AZ', // Azerbaijan
    '995': 'GE', // Georgia
    '7': 'RU', // Russia/Kazakhstan
    
    // Africa
    '20': 'EG', // Egypt
    '27': 'ZA', // South Africa
    '234': 'NG', // Nigeria
    '254': 'KE', // Kenya
    '233': 'GH', // Ghana
    '212': 'MA', // Morocco
    '213': 'DZ', // Algeria
    '216': 'TN', // Tunisia
    '218': 'LY', // Libya
    '220': 'GM', // Gambia
    '221': 'SN', // Senegal
    '222': 'MR', // Mauritania
    '223': 'ML', // Mali
    '224': 'GN', // Guinea
    '225': 'CI', // Ivory Coast
    '226': 'BF', // Burkina Faso
    '227': 'NE', // Niger
    '228': 'TG', // Togo
    '229': 'BJ', // Benin
    '230': 'MU', // Mauritius
    '231': 'LR', // Liberia
    '232': 'SL', // Sierra Leone
    '235': 'TD', // Chad
    '236': 'CF', // Central African Republic
    '237': 'CM', // Cameroon
    '238': 'CV', // Cape Verde
    '239': 'ST', // São Tomé and Príncipe
    '240': 'GQ', // Equatorial Guinea
    '241': 'GA', // Gabon
    '242': 'CG', // Republic of the Congo
    '243': 'CD', // Democratic Republic of the Congo
    '244': 'AO', // Angola
    '245': 'GW', // Guinea-Bissau
    '246': 'IO', // British Indian Ocean Territory
    '247': 'AC', // Ascension Island
    '248': 'SC', // Seychelles
    '249': 'SD', // Sudan
    '250': 'RW', // Rwanda
    '251': 'ET', // Ethiopia
    '252': 'SO', // Somalia
    '253': 'DJ', // Djibouti
    '255': 'TZ', // Tanzania
    '256': 'UG', // Uganda
    '257': 'BI', // Burundi
    '258': 'MZ', // Mozambique
    '260': 'ZM', // Zambia
    '261': 'MG', // Madagascar
    '262': 'RE', // Réunion
    '263': 'ZW', // Zimbabwe
    '264': 'NA', // Namibia
    '265': 'MW', // Malawi
    '266': 'LS', // Lesotho
    '267': 'BW', // Botswana
    '268': 'SZ', // Eswatini
    '269': 'KM', // Comoros
    '290': 'SH', // Saint Helena
    '291': 'ER', // Eritrea
    
    // Oceania
    '61': 'AU', // Australia
    '64': 'NZ', // New Zealand
    '679': 'FJ', // Fiji
    '685': 'WS', // Samoa
    '676': 'TO', // Tonga
    '678': 'VU', // Vanuatu
    '687': 'NC', // New Caledonia
    '689': 'PF', // French Polynesia
    '684': 'AS', // American Samoa
    '691': 'FM', // Micronesia
    '692': 'MH', // Marshall Islands
    '680': 'PW', // Palau
    '686': 'KI', // Kiribati
    '688': 'TV', // Tuvalu
    '683': 'NU', // Niue
    '682': 'CK', // Cook Islands
    
    // South America
    '55': 'BR', // Brazil
    '54': 'AR', // Argentina
    '56': 'CL', // Chile
    '57': 'CO', // Colombia
    '58': 'VE', // Venezuela
    '51': 'PE', // Peru
    '591': 'BO', // Bolivia
    '593': 'EC', // Ecuador
    '595': 'PY', // Paraguay
    '598': 'UY', // Uruguay
    '597': 'SR', // Suriname
    '592': 'GY', // Guyana
    
    // Central America & Caribbean
    '52': 'MX', // Mexico
    '502': 'GT', // Guatemala
    '503': 'SV', // El Salvador
    '504': 'HN', // Honduras
    '505': 'NI', // Nicaragua
    '506': 'CR', // Costa Rica
    '507': 'PA', // Panama
    '1809': 'DO', // Dominican Republic
    '1876': 'JM', // Jamaica
    '1869': 'KN', // Saint Kitts and Nevis
    '1758': 'LC', // Saint Lucia
    '1784': 'VC', // Saint Vincent and the Grenadines
    '1242': 'BS', // Bahamas
    '1246': 'BB', // Barbados
    '1264': 'AI', // Anguilla
    '1268': 'AG', // Antigua and Barbuda
    '1284': 'VG', // British Virgin Islands
    '1340': 'VI', // US Virgin Islands
    '1345': 'KY', // Cayman Islands
    '1473': 'GD', // Grenada
    '1649': 'TC', // Turks and Caicos Islands
    '1664': 'MS', // Montserrat
    '1670': 'MP', // Northern Mariana Islands
    '1671': 'GU', // Guam
    '1684': 'AS', // American Samoa
    '1721': 'SX', // Sint Maarten
    '1787': 'PR', // Puerto Rico
    '1939': 'PR', // Puerto Rico
  };

  /// Detects the country code based on the phone number prefix
  /// Returns the country code (e.g., 'US', 'GB') or null if not found
  static String? detectCountryCode(String phoneNumber) {
    // Remove any non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.isEmpty) return null;
    
    // Try to match the longest possible prefix first
    // Sort keys by length (longest first) to ensure we match the most specific prefix
    final sortedPrefixes = _prefixToCountryCode.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    
    for (final prefix in sortedPrefixes) {
      if (cleanNumber.startsWith(prefix)) {
        return _prefixToCountryCode[prefix];
      }
    }
    
    return null;
  }

  /// Gets the country object from country code
  static Country? getCountryFromCode(String countryCode) {
    try {
      // Create a country object with the detected country code
      // We'll use a default phone code and let the country picker handle the rest
      return Country.parse(countryCode);
    } catch (e) {
      return null;
    }
  }

  /// Detects country and returns Country object
  static Country? detectCountry(String phoneNumber) {
    final countryCode = detectCountryCode(phoneNumber);
    if (countryCode == null) return null;
    
    return getCountryFromCode(countryCode);
  }

  /// Gets all available country codes for debugging
  static List<String> getAllCountryCodes() {
    return _prefixToCountryCode.values.toSet().toList()..sort();
  }

  /// Gets all available prefixes for debugging
  static List<String> getAllPrefixes() {
    return _prefixToCountryCode.keys.toList()..sort();
  }
}
