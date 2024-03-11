import 'package:bluetooth_sample/services/wifi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Frequency check test 1', () {
    const targetGHz = 2.4;
    const value = 2483;
    expect(Wifi.isValidFrequency(targetGHz, value), isTrue);
  });

  test('Frequency check test 2', () {
    const targetGHz = 2.4;
    const value = 3000;
    expect(Wifi.isValidFrequency(targetGHz, value), isFalse);
  });

  test('Frequency check test 3', () {
    const targetGHz = 2.4;
    const value = 2504;
    expect(Wifi.isValidFrequency(targetGHz, value), isFalse);
  });

  test('Frequency check test 4', () {
    const targetGHz = 5.0;
    const value = 3000;
    expect(Wifi.isValidFrequency(targetGHz, value), isFalse);
  });

  test('Frequency check test 5', () {
    const targetGHz = 5.0;
    const value = 5209;
    expect(Wifi.isValidFrequency(targetGHz, value), isTrue);
  });
}
