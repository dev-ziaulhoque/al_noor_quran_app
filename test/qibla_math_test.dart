import 'package:al_noor_app/core/prayer/qibla_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dhaka Qibla bearing and distance', () {
    final b = QiblaMath.bearing(23.8103, 90.4125);
    expect(b, closeTo(277.5, 1.0));
    expect(QiblaMath.cardinal(b), 'W');
    expect(QiblaMath.distanceKm(23.8103, 90.4125), closeTo(5100, 150));
  });

  test('London faces southeast-ish, New York northeast', () {
    expect(QiblaMath.bearing(51.5074, -0.1278), closeTo(119, 1.5));
    expect(QiblaMath.bearing(40.7128, -74.0060), closeTo(58.5, 1.5));
  });

  test('delta takes the short way round', () {
    expect(QiblaMath.delta(350, 10), closeTo(20, 1e-9));
    expect(QiblaMath.delta(10, 350), closeTo(-20, 1e-9));
  });

  test('sun is nearly overhead the Kaaba on the overhead date', () {
    final at = DateTime.utc(2026, 5, 27, 9, 18);
    expect(QiblaMath.sun(at, QiblaMath.kaabaLat, QiblaMath.kaabaLng).altitude, greaterThan(89));
    expect(QiblaMath.nextKaabaOverhead(DateTime.utc(2026, 6, 1)).toUtc(), DateTime.utc(2026, 7, 15, 9, 27));
  });

  test('sun alignments line up with the Qibla bearing', () {
    const lat = 23.8103, lng = 90.4125;
    final q = QiblaMath.bearing(lat, lng);
    final moments = QiblaMath.sunAlignments(DateTime(2026, 10, 13), lat, lng);
    for (final m in moments) {
      final az = QiblaMath.sun(m.at, lat, lng).azimuth;
      final target = m.kind == SunQiblaKind.faceSun ? q : QiblaMath.norm(q + 180);
      expect(QiblaMath.delta(target, az).abs(), lessThan(1.0));
    }
  });
}
