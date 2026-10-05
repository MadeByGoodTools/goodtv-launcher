import 'package:goodtv_launcher/widgets/category_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dock evenly fits five apps and scrolls from the sixth', () {
    expect(
      shouldEvenlyDistributeDockApps(evenlyDistribute: true, appCount: 5),
      isTrue,
    );
    expect(
      shouldEvenlyDistributeDockApps(evenlyDistribute: true, appCount: 6),
      isFalse,
    );
    expect(
      shouldEvenlyDistributeDockApps(evenlyDistribute: false, appCount: 5),
      isFalse,
    );
  });
}
