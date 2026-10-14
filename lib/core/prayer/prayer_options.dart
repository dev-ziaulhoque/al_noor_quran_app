import 'package:adhan/adhan.dart';

class PrayerMethodOption {
  final String id;
  final String name;
  final String shortName;
  final String region;
  final CalculationMethod method;

  const PrayerMethodOption({
    required this.id,
    required this.name,
    required this.shortName,
    required this.region,
    required this.method,
  });
}

class MadhabOption {
  final String id;
  final String name;
  final String asrNote;
  final Madhab madhab;

  const MadhabOption({
    required this.id,
    required this.name,
    required this.asrNote,
    required this.madhab,
  });
}

class MuazzinOption {
  final String id;
  final String name;
  final String style;

  /// Recording names in the azan audio collection (see AzanAudioService).
  final String azanFile;
  final String fajrFile;

  /// Set when the Fajr azan (with "as-salatu khayrun minan-nawm") is in another voice.
  final String? fajrVoice;

  const MuazzinOption({
    required this.id,
    required this.name,
    required this.style,
    required this.azanFile,
    required this.fajrFile,
    this.fajrVoice,
  });
}

class PrayerOptions {
  /// Karachi + Hanafi matches the method most used in Bangladesh.
  static const String defaultMethodId = 'karachi';
  static const String defaultMadhabId = 'hanafi';
  static const String defaultMuazzinId = 'makkah';

  static const List<PrayerMethodOption> methods = [
    PrayerMethodOption(
      id: 'karachi',
      name: 'University of Islamic Sciences, Karachi',
      shortName: 'Karachi',
      region: 'Bangladesh, Pakistan, India',
      method: CalculationMethod.karachi,
    ),
    PrayerMethodOption(
      id: 'mwl',
      name: 'Muslim World League',
      shortName: 'MWL',
      region: 'Europe, Far East',
      method: CalculationMethod.muslim_world_league,
    ),
    PrayerMethodOption(
      id: 'isna',
      name: 'ISNA (North America)',
      shortName: 'ISNA',
      region: 'North America',
      method: CalculationMethod.north_america,
    ),
    PrayerMethodOption(
      id: 'egypt',
      name: 'Egyptian General Authority',
      shortName: 'Egypt',
      region: 'Africa, Syria, Lebanon',
      method: CalculationMethod.egyptian,
    ),
    PrayerMethodOption(
      id: 'umm_al_qura',
      name: 'Umm al-Qura',
      shortName: 'Umm al-Qura',
      region: 'Saudi Arabia',
      method: CalculationMethod.umm_al_qura,
    ),
    PrayerMethodOption(
      id: 'dubai',
      name: 'Dubai',
      shortName: 'Dubai',
      region: 'UAE',
      method: CalculationMethod.dubai,
    ),
    PrayerMethodOption(
      id: 'kuwait',
      name: 'Kuwait',
      shortName: 'Kuwait',
      region: 'Kuwait',
      method: CalculationMethod.kuwait,
    ),
    PrayerMethodOption(
      id: 'qatar',
      name: 'Qatar',
      shortName: 'Qatar',
      region: 'Qatar',
      method: CalculationMethod.qatar,
    ),
    PrayerMethodOption(
      id: 'singapore',
      name: 'Singapore',
      shortName: 'Singapore',
      region: 'Singapore, Malaysia',
      method: CalculationMethod.singapore,
    ),
    PrayerMethodOption(
      id: 'turkey',
      name: 'Diyanet (Turkey)',
      shortName: 'Diyanet',
      region: 'Turkey',
      method: CalculationMethod.turkey,
    ),
    PrayerMethodOption(
      id: 'moonsighting',
      name: 'Moonsighting Committee',
      shortName: 'Moonsighting',
      region: 'Worldwide',
      method: CalculationMethod.moon_sighting_committee,
    ),
  ];

  static const List<MadhabOption> madhabs = [
    MadhabOption(
      id: 'hanafi',
      name: 'Hanafi',
      asrNote: 'Asr when an object’s shadow is twice its length',
      madhab: Madhab.hanafi,
    ),
    MadhabOption(
      id: 'shafi',
      name: 'Shafi‘i, Maliki, Hanbali',
      asrNote: 'Asr when an object’s shadow equals its length',
      madhab: Madhab.shafi,
    ),
  ];

  /// Named styles for the alert. The tone itself is the phone notification
  /// sound, so several full azan recordings are not packed into the app.
  static const List<MuazzinOption> muazzins = [
    MuazzinOption(
      id: 'makkah',
      name: 'Makkah · Sheikh Ali Mulla',
      style: 'Masjid al-Haram',
      azanFile: 'Adhan 1 - Makkah - Sheikh Ali Mulla - High Q.mp3',
      fajrFile: 'Fajr 3 - Makkah QC.mp3',
    ),
    MuazzinOption(
      id: 'madinah',
      name: 'Madinah',
      style: 'Masjid an-Nabawi',
      azanFile: 'Adhan 10 - Madina .mp3',
      fajrFile: 'Fajr 3 - Makkah QC.mp3',
      fajrVoice: 'Makkah',
    ),
    MuazzinOption(
      id: 'mishary',
      name: 'Mishary Rashid Alafasy',
      style: 'Kuwait',
      azanFile: 'Adhan 3 - Mishary Al Afasy.mp3',
      fajrFile: 'Fajr 1 - Mishary .mp3',
    ),
    MuazzinOption(
      id: 'ahmad_khoja',
      name: 'Ahmad Khoja',
      style: 'Recorded azan',
      azanFile: 'Adhan 14 - Ahmad Khoja.mp3',
      fajrFile: 'Fajr 3 - Makkah QC.mp3',
      fajrVoice: 'Makkah',
    ),
  ];

  static PrayerMethodOption methodById(String id) {
    return methods.firstWhere((m) => m.id == id, orElse: () => methods.first);
  }

  static MadhabOption madhabById(String id) {
    return madhabs.firstWhere((m) => m.id == id, orElse: () => madhabs.first);
  }

  static MuazzinOption muazzinById(String id) {
    return muazzins.firstWhere((m) => m.id == id, orElse: () => muazzins.first);
  }
}
