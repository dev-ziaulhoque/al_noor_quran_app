import 'dart:math';

/// Built-in places for prayer times. Lets the user pick a city without GPS,
/// names a GPS fix without any online lookup, and picks the calculation
/// method used in that country.
class City {
  final String name;
  final String nameBn;
  final String country;
  final double lat;
  final double lng;

  const City(this.name, this.nameBn, this.country, this.lat, this.lng);

  String label(bool bangla) => bangla ? nameBn : name;
  bool get isBangladesh => country == 'BD';
}

class CityMatch {
  final City city;
  final double km;
  const CityMatch(this.city, this.km);
}

class Cities {
  /// All 64 districts of Bangladesh (district headquarters), divisions first.
  static const bangladesh = [
    City('Dhaka', 'ঢাকা', 'BD', 23.8103, 90.4125),
    City('Chattogram', 'চট্টগ্রাম', 'BD', 22.3569, 91.7832),
    City('Sylhet', 'সিলেট', 'BD', 24.8949, 91.8687),
    City('Rajshahi', 'রাজশাহী', 'BD', 24.3745, 88.6042),
    City('Khulna', 'খুলনা', 'BD', 22.8456, 89.5403),
    City('Barishal', 'বরিশাল', 'BD', 22.7010, 90.3535),
    City('Rangpur', 'রংপুর', 'BD', 25.7439, 89.2752),
    City('Mymensingh', 'ময়মনসিংহ', 'BD', 24.7471, 90.4203),
    City('Gazipur', 'গাজীপুর', 'BD', 23.9999, 90.4203),
    City('Narayanganj', 'নারায়ণগঞ্জ', 'BD', 23.6238, 90.5000),
    City('Cumilla', 'কুমিল্লা', 'BD', 23.4607, 91.1809),
    City("Cox's Bazar", 'কক্সবাজার', 'BD', 21.4272, 92.0058),
    City('Bogura', 'বগুড়া', 'BD', 24.8466, 89.3773),
    City('Jashore', 'যশোর', 'BD', 23.1664, 89.2081),
    City('Noakhali', 'নোয়াখালী', 'BD', 22.8696, 91.0995),
    City('Feni', 'ফেনী', 'BD', 23.0159, 91.3976),
    City('Brahmanbaria', 'ব্রাহ্মণবাড়িয়া', 'BD', 23.9571, 91.1119),
    City('Chandpur', 'চাঁদপুর', 'BD', 23.2333, 90.6713),
    City('Lakshmipur', 'লক্ষ্মীপুর', 'BD', 22.9447, 90.8282),
    City('Rangamati', 'রাঙ্গামাটি', 'BD', 22.6574, 92.1735),
    City('Khagrachhari', 'খাগড়াছড়ি', 'BD', 23.1193, 91.9847),
    City('Bandarban', 'বান্দরবান', 'BD', 22.1953, 92.2184),
    City('Tangail', 'টাঙ্গাইল', 'BD', 24.2513, 89.9167),
    City('Narsingdi', 'নরসিংদী', 'BD', 23.9322, 90.7151),
    City('Manikganj', 'মানিকগঞ্জ', 'BD', 23.8617, 90.0003),
    City('Munshiganj', 'মুন্সীগঞ্জ', 'BD', 23.5422, 90.5305),
    City('Kishoreganj', 'কিশোরগঞ্জ', 'BD', 24.4449, 90.7766),
    City('Faridpur', 'ফরিদপুর', 'BD', 23.6070, 89.8429),
    City('Gopalganj', 'গোপালগঞ্জ', 'BD', 23.0050, 89.8266),
    City('Madaripur', 'মাদারীপুর', 'BD', 23.1641, 90.1897),
    City('Shariatpur', 'শরীয়তপুর', 'BD', 23.2423, 90.4348),
    City('Rajbari', 'রাজবাড়ী', 'BD', 23.7574, 89.6445),
    City('Jamalpur', 'জামালপুর', 'BD', 24.9375, 89.9378),
    City('Sherpur', 'শেরপুর', 'BD', 25.0205, 90.0153),
    City('Netrokona', 'নেত্রকোনা', 'BD', 24.8703, 90.7279),
    City('Moulvibazar', 'মৌলভীবাজার', 'BD', 24.4829, 91.7774),
    City('Habiganj', 'হবিগঞ্জ', 'BD', 24.3749, 91.4155),
    City('Sunamganj', 'সুনামগঞ্জ', 'BD', 25.0658, 91.3950),
    City('Pabna', 'পাবনা', 'BD', 24.0064, 89.2372),
    City('Sirajganj', 'সিরাজগঞ্জ', 'BD', 24.4534, 89.7007),
    City('Natore', 'নাটোর', 'BD', 24.4206, 89.0003),
    City('Naogaon', 'নওগাঁ', 'BD', 24.7936, 88.9318),
    City('Chapainawabganj', 'চাঁপাইনবাবগঞ্জ', 'BD', 24.5965, 88.2776),
    City('Joypurhat', 'জয়পুরহাট', 'BD', 25.0968, 89.0227),
    City('Dinajpur', 'দিনাজপুর', 'BD', 25.6217, 88.6354),
    City('Thakurgaon', 'ঠাকুরগাঁও', 'BD', 26.0337, 88.4617),
    City('Panchagarh', 'পঞ্চগড়', 'BD', 26.3411, 88.5541),
    City('Nilphamari', 'নীলফামারী', 'BD', 25.9318, 88.8560),
    City('Lalmonirhat', 'লালমনিরহাট', 'BD', 25.9923, 89.2847),
    City('Kurigram', 'কুড়িগ্রাম', 'BD', 25.8072, 89.6295),
    City('Gaibandha', 'গাইবান্ধা', 'BD', 25.3288, 89.5280),
    City('Kushtia', 'কুষ্টিয়া', 'BD', 23.9013, 89.1204),
    City('Meherpur', 'মেহেরপুর', 'BD', 23.7622, 88.6318),
    City('Chuadanga', 'চুয়াডাঙ্গা', 'BD', 23.6401, 88.8418),
    City('Jhenaidah', 'ঝিনাইদহ', 'BD', 23.5450, 89.1726),
    City('Magura', 'মাগুরা', 'BD', 23.4873, 89.4199),
    City('Narail', 'নড়াইল', 'BD', 23.1725, 89.5127),
    City('Satkhira', 'সাতক্ষীরা', 'BD', 22.7185, 89.0705),
    City('Bagerhat', 'বাগেরহাট', 'BD', 22.6516, 89.7859),
    City('Patuakhali', 'পটুয়াখালী', 'BD', 22.3596, 90.3299),
    City('Bhola', 'ভোলা', 'BD', 22.6859, 90.6482),
    City('Pirojpur', 'পিরোজপুর', 'BD', 22.5841, 89.9720),
    City('Jhalokati', 'ঝালকাঠি', 'BD', 22.6406, 90.1987),
    City('Barguna', 'বরগুনা', 'BD', 22.1591, 90.1119),
  ];

  static const world = [
    City('Makkah', 'মক্কা', 'SA', 21.4225, 39.8262),
    City('Madinah', 'মদিনা', 'SA', 24.4672, 39.6111),
    City('Riyadh', 'রিয়াদ', 'SA', 24.7136, 46.6753),
    City('Jeddah', 'জেদ্দা', 'SA', 21.4858, 39.1925),
    City('Dubai', 'দুবাই', 'AE', 25.2048, 55.2708),
    City('Abu Dhabi', 'আবুধাবি', 'AE', 24.4539, 54.3773),
    City('Doha', 'দোহা', 'QA', 25.2854, 51.5310),
    City('Kuwait City', 'কুয়েত সিটি', 'KW', 29.3759, 47.9774),
    City('Muscat', 'মাস্কাট', 'OM', 23.5880, 58.3829),
    City('Manama', 'মানামা', 'BH', 26.2285, 50.5860),
    City('Kolkata', 'কলকাতা', 'IN', 22.5726, 88.3639),
    City('Delhi', 'দিল্লি', 'IN', 28.6139, 77.2090),
    City('Mumbai', 'মুম্বাই', 'IN', 19.0760, 72.8777),
    City('Karachi', 'করাচি', 'PK', 24.8607, 67.0011),
    City('Lahore', 'লাহোর', 'PK', 31.5204, 74.3587),
    City('Islamabad', 'ইসলামাবাদ', 'PK', 33.6844, 73.0479),
    City('Kuala Lumpur', 'কুয়ালালামপুর', 'MY', 3.1390, 101.6869),
    City('Singapore', 'সিঙ্গাপুর', 'SG', 1.3521, 103.8198),
    City('Jakarta', 'জাকার্তা', 'ID', -6.2088, 106.8456),
    City('Istanbul', 'ইস্তাম্বুল', 'TR', 41.0082, 28.9784),
    City('Cairo', 'কায়রো', 'EG', 30.0444, 31.2357),
    City('London', 'লন্ডন', 'GB', 51.5074, -0.1278),
    City('Paris', 'প্যারিস', 'FR', 48.8566, 2.3522),
    City('Rome', 'রোম', 'IT', 41.9028, 12.4964),
    City('Berlin', 'বার্লিন', 'DE', 52.5200, 13.4050),
    City('New York', 'নিউ ইয়র্ক', 'US', 40.7128, -74.0060),
    City('Toronto', 'টরন্টো', 'CA', 43.6532, -79.3832),
    City('Sydney', 'সিডনি', 'AU', -33.8688, 151.2093),
    City('Tokyo', 'টোকিও', 'JP', 35.6762, 139.6503),
    City('Seoul', 'সিউল', 'KR', 37.5665, 126.9780),
  ];

  static const all = [...bangladesh, ...world];

  static City get dhaka => bangladesh.first;

  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    double rad(double d) => d * pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }

  static CityMatch nearest(double lat, double lng) {
    var best = all.first;
    var bestKm = double.infinity;
    for (final c in all) {
      final d = distanceKm(lat, lng, c.lat, c.lng);
      if (d < bestKm) {
        best = c;
        bestKm = d;
      }
    }
    return CityMatch(best, bestKm);
  }

  static City? byName(String name) {
    for (final c in all) {
      if (c.name == name) return c;
    }
    return null;
  }

  static List<City> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) => c.name.toLowerCase().contains(q) || c.nameBn.contains(q)).toList();
  }

  /// Calculation method and madhab most used in a country. Unknown places
  /// get Muslim World League with the standard (Shafi'i) Asr.
  static (String method, String madhab) prayerDefaults(String? country) {
    switch (country) {
      case 'BD':
      case 'IN':
      case 'PK':
        return ('karachi', 'hanafi');
      case 'TR':
        return ('turkey', 'hanafi');
      case 'SA':
      case 'BH':
      case 'OM':
        return ('umm_al_qura', 'shafi');
      case 'AE':
        return ('dubai', 'shafi');
      case 'QA':
        return ('qatar', 'shafi');
      case 'KW':
        return ('kuwait', 'shafi');
      case 'MY':
      case 'SG':
      case 'ID':
        return ('singapore', 'shafi');
      case 'EG':
        return ('egypt', 'shafi');
      case 'US':
      case 'CA':
        return ('isna', 'shafi');
      default:
        return ('mwl', 'shafi');
    }
  }

  /// Country for a GPS fix, from the nearest known city when it is close
  /// enough to trust.
  static String? countryNear(double lat, double lng) {
    final m = nearest(lat, lng);
    final limit = m.city.isBangladesh ? 120.0 : 400.0;
    return m.km <= limit ? m.city.country : null;
  }
}
