// lib/data/services/quran_service.dart
import 'package:dio/dio.dart';
import '../models/models.dart';

class QuranService {
  final Dio _dio;

  QuranService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.alquran.cloud/v1',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<List<SurahModel>> fetchSurahList() async {
    try {
      final response = await _dio.get('/surah');
      final List data = response.data['data'] as List;
      return data.map((e) => SurahModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<AyahModel>> fetchSurahAyahs(int surahNumber) async {
    try {
      // Fetching Arabic text, English translation, and Audio links
      final response = await _dio.get('/surah/$surahNumber/editions/quran-uthmani,en.sahih,ar.alafasy');
      final data = response.data['data'] as List;

      final List arabicAyahs = data[0]['ayahs'];
      final List englishAyahs = data[1]['ayahs'];
      final List audioAyahs = data[2]['ayahs'];

      List<AyahModel> result = [];
      for (int i = 0; i < arabicAyahs.length; i++) {
        result.add(AyahModel(
          number: arabicAyahs[i]['numberInSurah'],
          arabic: arabicAyahs[i]['text'],
          translation: englishAyahs[i]['text'],
          surahNumber: surahNumber,
          audio: audioAyahs[i]['audio'],
        ));
      }
      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) return 'No internet connection.';
    return 'Failed to load data. Please check internet and try again.';
  }
}
