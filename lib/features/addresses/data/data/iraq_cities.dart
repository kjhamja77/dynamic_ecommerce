class IraqCity {
  final String name;
  final String governorate;
  final String arabicName;
  final String region;

  const IraqCity({
    required this.name,
    required this.governorate,
    required this.arabicName,
    required this.region,
  });
}

class IraqCitiesData {
  static const List<IraqCity> cities = [
    // Baghdad Governorate
    IraqCity(name: 'Baghdad', governorate: 'Baghdad', arabicName: 'بغداد', region: 'Central'),
    IraqCity(name: 'Abu Ghraib', governorate: 'Baghdad', arabicName: 'أبو غريب', region: 'Central'),
    IraqCity(name: 'Taji', governorate: 'Baghdad', arabicName: 'التاجي', region: 'Central'),
    IraqCity(name: 'Mahmudiyah', governorate: 'Baghdad', arabicName: 'المحمودية', region: 'Central'),
    
    // Basra Governorate
    IraqCity(name: 'Basra', governorate: 'Basra', arabicName: 'البصرة', region: 'South'),
    IraqCity(name: 'Zubayr', governorate: 'Basra', arabicName: 'الزبير', region: 'South'),
    IraqCity(name: 'Umm Qasr', governorate: 'Basra', arabicName: 'أم قصر', region: 'South'),
    IraqCity(name: 'Abu Al-Khaseeb', governorate: 'Basra', arabicName: 'أبو الخصيب', region: 'South'),
    
    // Mosul Governorate
    IraqCity(name: 'Mosul', governorate: 'Nineveh', arabicName: 'الموصل', region: 'North'),
    IraqCity(name: 'Sinjar', governorate: 'Nineveh', arabicName: 'سنجار', region: 'North'),
    IraqCity(name: 'Tal Afar', governorate: 'Nineveh', arabicName: 'تلعفر', region: 'North'),
    IraqCity(name: 'Al-Hamdaniya', governorate: 'Nineveh', arabicName: 'الحمدانية', region: 'North'),
    
    // Erbil Governorate
    IraqCity(name: 'Erbil', governorate: 'Erbil', arabicName: 'أربيل', region: 'Kurdistan'),
    IraqCity(name: 'Soran', governorate: 'Erbil', arabicName: 'سوران', region: 'Kurdistan'),
    IraqCity(name: 'Shaqlawa', governorate: 'Erbil', arabicName: 'شقلاوه', region: 'Kurdistan'),
    IraqCity(name: 'Koysanjaq', governorate: 'Erbil', arabicName: 'كويه', region: 'Kurdistan'),
    
    // Sulaymaniyah Governorate
    IraqCity(name: 'Sulaymaniyah', governorate: 'Sulaymaniyah', arabicName: 'السليمانية', region: 'Kurdistan'),
    IraqCity(name: 'Halabja', governorate: 'Sulaymaniyah', arabicName: 'حلبجة', region: 'Kurdistan'),
    IraqCity(name: 'Darbandikhan', governorate: 'Sulaymaniyah', arabicName: 'دربندخان', region: 'Kurdistan'),
    IraqCity(name: 'Ranya', governorate: 'Sulaymaniyah', arabicName: 'رانية', region: 'Kurdistan'),
    
    // Kirkuk Governorate
    IraqCity(name: 'Kirkuk', governorate: 'Kirkuk', arabicName: 'كركوك', region: 'North'),
    IraqCity(name: 'Hawija', governorate: 'Kirkuk', arabicName: 'الحويجة', region: 'North'),
    IraqCity(name: 'Dibis', governorate: 'Kirkuk', arabicName: 'دبس', region: 'North'),
    IraqCity(name: 'Al-Riyadh', governorate: 'Kirkuk', arabicName: 'الرياض', region: 'North'),
    
    // Anbar Governorate
    IraqCity(name: 'Ramadi', governorate: 'Anbar', arabicName: 'الرمادي', region: 'West'),
    IraqCity(name: 'Fallujah', governorate: 'Anbar', arabicName: 'الفلوجة', region: 'West'),
    IraqCity(name: 'Al-Qaim', governorate: 'Anbar', arabicName: 'القائم', region: 'West'),
    IraqCity(name: 'Haditha', governorate: 'Anbar', arabicName: 'حديثة', region: 'West'),
    
    // Diyala Governorate
    IraqCity(name: 'Baqubah', governorate: 'Diyala', arabicName: 'بعقوبة', region: 'Central'),
    IraqCity(name: 'Khanaqin', governorate: 'Diyala', arabicName: 'خانقين', region: 'Central'),
    IraqCity(name: 'Muqdadiyah', governorate: 'Diyala', arabicName: 'المقدادية', region: 'Central'),
    IraqCity(name: 'Balad Ruz', governorate: 'Diyala', arabicName: 'بلد روز', region: 'Central'),
    
    // Karbala Governorate
    IraqCity(name: 'Karbala', governorate: 'Karbala', arabicName: 'كربلاء', region: 'Central'),
    IraqCity(name: 'Ain Al-Tamur', governorate: 'Karbala', arabicName: 'عين التمر', region: 'Central'),
    IraqCity(name: 'Al-Hindiya', governorate: 'Karbala', arabicName: 'الهندية', region: 'Central'),
    
    // Najaf Governorate
    IraqCity(name: 'Najaf', governorate: 'Najaf', arabicName: 'النجف', region: 'Central'),
    IraqCity(name: 'Kufa', governorate: 'Najaf', arabicName: 'الكوفة', region: 'Central'),
    IraqCity(name: 'Manathera', governorate: 'Najaf', arabicName: 'المناذرة', region: 'Central'),
    
    // Babil Governorate
    IraqCity(name: 'Hillah', governorate: 'Babil', arabicName: 'الحلة', region: 'Central'),
    IraqCity(name: 'Al-Mahawil', governorate: 'Babil', arabicName: 'المحاويل', region: 'Central'),
    IraqCity(name: 'Al-Musayab', governorate: 'Babil', arabicName: 'المسيب', region: 'Central'),
    
    // Wasit Governorate
    IraqCity(name: 'Kut', governorate: 'Wasit', arabicName: 'الكوت', region: 'Central'),
    IraqCity(name: 'Al-Suwaira', governorate: 'Wasit', arabicName: 'الصويرة', region: 'Central'),
    IraqCity(name: 'Badra', governorate: 'Wasit', arabicName: 'بدرة', region: 'Central'),
    
    // Qadisiyah Governorate
    IraqCity(name: 'Al-Diwaniyah', governorate: 'Qadisiyah', arabicName: 'الديوانية', region: 'Central'),
    IraqCity(name: 'Al-Shamiyah', governorate: 'Qadisiyah', arabicName: 'الشمية', region: 'Central'),
    IraqCity(name: 'Afak', governorate: 'Qadisiyah', arabicName: 'عفك', region: 'Central'),
    
    // Muthanna Governorate
    IraqCity(name: 'Al-Samawah', governorate: 'Muthanna', arabicName: 'السماوة', region: 'South'),
    IraqCity(name: 'Al-Rumaitha', governorate: 'Muthanna', arabicName: 'الرميثة', region: 'South'),
    IraqCity(name: 'Al-Salman', governorate: 'Muthanna', arabicName: 'السلام', region: 'South'),
    
    // Dhi Qar Governorate
    IraqCity(name: 'Nasiriyah', governorate: 'Dhi Qar', arabicName: 'الناصرية', region: 'South'),
    IraqCity(name: 'Al-Shatrah', governorate: 'Dhi Qar', arabicName: 'الشطرة', region: 'South'),
    IraqCity(name: 'Al-Rifai', governorate: 'Dhi Qar', arabicName: 'الرفاعي', region: 'South'),
    
    // Maysan Governorate
    IraqCity(name: 'Amarah', governorate: 'Maysan', arabicName: 'العمارة', region: 'South'),
    IraqCity(name: 'Al-Majar Al-Kabir', governorate: 'Maysan', arabicName: 'المجر الكبير', region: 'South'),
    IraqCity(name: 'Al-Kahla', governorate: 'Maysan', arabicName: 'الكحلاء', region: 'South'),
    
    // Duhok Governorate
    IraqCity(name: 'Duhok', governorate: 'Duhok', arabicName: 'دهوك', region: 'Kurdistan'),
    IraqCity(name: 'Zakho', governorate: 'Duhok', arabicName: 'زاخو', region: 'Kurdistan'),
    IraqCity(name: 'Amedi', governorate: 'Duhok', arabicName: 'عمادية', region: 'Kurdistan'),
    IraqCity(name: 'Bardarash', governorate: 'Duhok', arabicName: 'بردرش', region: 'Kurdistan'),
  ];

  static List<String> get governorates {
    return cities.map((city) => city.governorate).toSet().toList()..sort();
  }

  static List<String> get regions {
    return cities.map((city) => city.region).toSet().toList()..sort();
  }

  static List<IraqCity> getCitiesByGovernorate(String governorate) {
    return cities.where((city) => city.governorate == governorate).toList();
  }

  static List<IraqCity> getCitiesByRegion(String region) {
    return cities.where((city) => city.region == region).toList();
  }

  static List<String> getCityNamesByGovernorate(String governorate) {
    return getCitiesByGovernorate(governorate).map((city) => city.name).toList();
  }
}
