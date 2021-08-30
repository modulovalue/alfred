/// A Hybrid Logical Clock implementation.
/// This class trades time precision for a guaranteed monotonically increasing
/// clock in distributed systems.
/// Inspiration: https://cse.buffalo.edu/tech-reports/2014-04.pdf
abstract class Hlc implements Comparable<Hlc> {
  int get millis;

  int get counter;

  String get nodeId;

  int get logicalTime;

  Hlc apply({
    final int? millis,
    final int? counter,
    final String? nodeId,
  });

  bool operator <(
    final Hlc other,
  );

  bool operator <=(
    final Hlc other,
  );

  bool operator >(
    final Hlc other,
  );

  bool operator >=(
    final Hlc other,
  );

  @override
  int compareTo(
    final Hlc other,
  );

  String toJson();
}
