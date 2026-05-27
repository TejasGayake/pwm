import 'package:flutter_test/flutter_test.dart';
import 'package:pwm/utils/formatters.dart';

void main() {
  group('formatIndianCurrency', () {
    test('formats small amounts', () {
      expect(formatIndianCurrency(500), '₹500');
      expect(formatIndianCurrency(1000), '₹1,000');
    });

    test('formats lakhs', () {
      expect(formatIndianCurrency(100000), '₹1.00 L');
      expect(formatIndianCurrency(500000), '₹5.00 L');
    });

    test('formats crores', () {
      expect(formatIndianCurrency(10000000), '₹1.00 Cr');
      expect(formatIndianCurrency(25000000), '₹2.50 Cr');
    });
  });

  group('formatPercentage', () {
    test('formats correctly', () {
      expect(formatPercentage(50.0), '50.0%');
      expect(formatPercentage(33.33), '33.3%');
      expect(formatPercentage(100.0), '100.0%');
    });
  });

  group('formatCompactAmount', () {
    test('formats correctly', () {
      expect(formatCompactAmount(500), '500');
      expect(formatCompactAmount(5000), '5.0K');
      expect(formatCompactAmount(500000), '5.0L');
      expect(formatCompactAmount(50000000), '5.0Cr');
    });
  });
}
