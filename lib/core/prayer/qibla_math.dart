import 'dart:math' as math;

enum SunQiblaKind { faceSun, shadow }

class SunQiblaMoment {
  final DateTime at;
  final SunQiblaKind kind;
  const SunQiblaMoment(this.at, this.kind);
}

/// Offline Qibla geometry: great-circle bearing, distance, and the sun's
/// position so the direction can be checked without a compass.
class QiblaMath {
  static const kaabaLat = 21.422487;
  static const kaabaLng = 39.826206;
  static const _earthKm = 6371.0;

  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;
  static double norm(double d) => (d % 360 + 360) % 360;

  /// Signed shortest turn from [from] to [to], in (-180, 180].
  static double delta(double from, double to) {
    final d = norm(to - from);
    return d > 180 ? d - 360 : d;
  }

  /// Initial great-circle bearing from the place to the Kaaba, clockwise from true north.
  static double bearing(double lat, double lng) {
    final p1 = _rad(lat), p2 = _rad(kaabaLat);
    final dl = _rad(kaabaLng - lng);
    final y = math.sin(dl) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
    return norm(_deg(math.atan2(y, x)));
  }

  static double distanceKm(double lat, double lng) {
    final dp = _rad(kaabaLat - lat), dl = _rad(kaabaLng - lng);
    final a = math.pow(math.sin(dp / 2), 2) +
        math.cos(_rad(lat)) * math.cos(_rad(kaabaLat)) * math.pow(math.sin(dl / 2), 2);
    return 2 * _earthKm * math.asin(math.min(1.0, math.sqrt(a)));
  }

  /// 16-point compass key ('N', 'NNE', ... ) for a bearing.
  static String cardinal(double bearing) {
    const points = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    return points[((norm(bearing) + 11.25) ~/ 22.5) % 16];
  }

  /// Sun azimuth (clockwise from north) and altitude in degrees (low-precision
  /// solar position, good to a fraction of a degree).
  static ({double azimuth, double altitude}) sun(DateTime time, double lat, double lng) {
    final utc = time.toUtc();
    final n = utc.millisecondsSinceEpoch / 86400000.0 + 2440587.5 - 2451545.0;
    final l = norm(280.460 + 0.9856474 * n);
    final g = _rad(norm(357.528 + 0.9856003 * n));
    final lambda = _rad(l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g));
    final eps = _rad(23.439 - 0.0000004 * n);
    final ra = math.atan2(math.cos(eps) * math.sin(lambda), math.cos(lambda));
    final dec = math.asin(math.sin(eps) * math.sin(lambda));
    final gmst = norm(280.46061837 + 360.98564736629 * n);
    final h = _rad(norm(gmst + lng - _deg(ra)));
    final phi = _rad(lat);
    final alt = math.asin(math.sin(phi) * math.sin(dec) + math.cos(phi) * math.cos(dec) * math.cos(h));
    final az = math.atan2(math.sin(h), math.cos(h) * math.sin(phi) - math.tan(dec) * math.cos(phi));
    return (azimuth: norm(_deg(az) + 180), altitude: _deg(alt));
  }

  /// Times on [day] (local) when the sun stands in the Qibla direction, or
  /// exactly behind it so shadows point to the Qibla. Sun must be above 3°.
  static List<SunQiblaMoment> sunAlignments(DateTime day, double lat, double lng) {
    final qibla = bearing(lat, lng);
    final start = DateTime(day.year, day.month, day.day);
    final out = <SunQiblaMoment>[];
    double? prevFace, prevShadow;
    for (var m = 0; m <= 24 * 60; m++) {
      final t = start.add(Duration(minutes: m));
      final s = sun(t, lat, lng);
      if (s.altitude < 3) {
        prevFace = prevShadow = null;
        continue;
      }
      final face = delta(qibla, s.azimuth);
      final shadow = delta(norm(qibla + 180), s.azimuth);
      if (prevFace != null && _crossed(prevFace, face)) out.add(SunQiblaMoment(t, SunQiblaKind.faceSun));
      if (prevShadow != null && _crossed(prevShadow, shadow)) out.add(SunQiblaMoment(t, SunQiblaKind.shadow));
      prevFace = face;
      prevShadow = shadow;
    }
    return out;
  }

  static bool _crossed(double a, double b) => (a <= 0 && b > 0 || a >= 0 && b < 0) && (a - b).abs() < 20;

  /// Next time the sun is almost straight over the Kaaba (about 27 May 12:18
  /// and 15 July 12:27 Makkah time); every shadow then points away from it.
  static DateTime nextKaabaOverhead(DateTime now) {
    final utcNow = now.toUtc();
    final candidates = <DateTime>[];
    for (final y in [utcNow.year, utcNow.year + 1]) {
      candidates.add(DateTime.utc(y, 5, 27, 9, 18));
      candidates.add(DateTime.utc(y, 7, 15, 9, 27));
    }
    return candidates.firstWhere((t) => t.add(const Duration(minutes: 5)).isAfter(utcNow)).toLocal();
  }
}
