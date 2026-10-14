// Builds the Quran text shipped inside the app so the first open works
// offline. Run from the project root:  dart run tool/bundle_quran.dart
import 'dart:convert';
import 'dart:io';

const _api = 'https://api.alquran.cloud/v1';
const _editions = ['quran-uthmani', 'en.sahih', 'bn.bengali'];

Future<dynamic> _get(HttpClient client, String path) async {
  final req = await client.getUrl(Uri.parse('$_api$path'));
  final res = await req.close();
  if (res.statusCode != 200) throw 'GET $path -> ${res.statusCode}';
  final body = await res.transform(utf8.decoder).join();
  return (jsonDecode(body) as Map)['data'];
}

void _write(String name, Object data) {
  final file = File('assets/quran/$name.json.gz')..parent.createSync(recursive: true);
  file.writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode(data))));
  stdout.writeln('${file.path}  ${(file.lengthSync() / 1024).toStringAsFixed(0)} KB');
}

Future<void> main() async {
  final client = HttpClient();
  try {
    final surahs = await _get(client, '/surah') as List;
    if (surahs.length != 114) throw 'surah list incomplete';
    _write('surahs', surahs);

    for (final edition in _editions) {
      final data = await _get(client, '/quran/$edition') as Map;
      final list = data['surahs'] as List;
      if (list.length != 114) throw '$edition incomplete';
      var total = 0;
      final compact = [
        for (final s in list)
          {
            'number': s['number'],
            'ayahs': [
              for (final a in s['ayahs'] as List)
                {'number': a['number'], 'numberInSurah': a['numberInSurah'], 'text': a['text']},
            ],
          },
      ];
      for (final s in compact) {
        total += (s['ayahs'] as List).length;
      }
      if (total != 6236) throw '$edition has $total ayahs, expected 6236';
      _write(edition, compact);
    }
  } finally {
    client.close();
  }
}
