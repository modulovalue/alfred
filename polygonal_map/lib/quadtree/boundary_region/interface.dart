/// The boundary regions are a set of values that can be used to
abstract class BoundaryRegion {
  int get value;

  /// Determines if the given [other] BoundaryRegion is partially contained in this BoundaryRegion.
  /// Typically used with North, South, East, and West. Will always return true for Inside.
  bool has(
    final BoundaryRegion other,
  );

  /// Gets the OR of the two boundary regions.
  BoundaryRegion operator |(
    final BoundaryRegion other,
  );

  /// Gets the AND of the two boundary regions.
  BoundaryRegion operator &(
    final BoundaryRegion other,
  );
}
