/// The boundary regions are a set of values that can be used to
class BoundaryRegionImpl implements BoundaryRegion {
  /// Indicates that the point is inside of the boundary.
  static final BoundaryRegion Inside = BoundaryRegionImpl._(0x00);

  /// Indicates that the point is south (-Y) of the boundary.
  static final BoundaryRegion South = BoundaryRegionImpl._(0x01);

  /// Indicates that the point is south (+Y) of the boundary.
  static final BoundaryRegion North = BoundaryRegionImpl._(0x02);

  /// Indicates that the point is either north, south, or inside the boundary.
  /// This is a combination of North and South.
  static final BoundaryRegion Vertical = BoundaryRegionImpl._(0x03);

  /// Indicates that the point is west (-X) of the boundary.
  static final BoundaryRegion West = BoundaryRegionImpl._(0x04);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and West.
  static final BoundaryRegion SouthWest = BoundaryRegionImpl._(0x05);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and West.
  static final BoundaryRegion NorthWest = BoundaryRegionImpl._(0x06);

  /// Indicates that the point is east (+X) of the boundary.
  static final BoundaryRegion East = BoundaryRegionImpl._(0x08);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and East.
  static final BoundaryRegion SouthEast = BoundaryRegionImpl._(0x09);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and East.
  static final BoundaryRegion NorthEast = BoundaryRegionImpl._(0x0A);

  /// Indicates that the point is either east, west, or inside the boundary.
  /// This is a combination of East and West.
  static final BoundaryRegion Horizontal = BoundaryRegionImpl._(0x0C);

  /// The value of the boundary region.
  @override
  int value;

  /// Creates a new boundary region.
  BoundaryRegionImpl._(this.value);

  /// Determines if the given [other] BoundaryRegion is partially contained in this BoundaryRegion.
  /// Typically used with North, South, East, and West. Will always return true for Inside.
  @override
  bool has(BoundaryRegion other) => (value & other.value) == other.value;

  /// Checks if this BoundaryRegion is equal to the given [other] BoundaryRegion.
  @override
  bool operator ==(Object other) {
    return other is BoundaryRegion && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  /// Gets the OR of the two boundary regions.
  @override
  BoundaryRegion operator |(BoundaryRegion other) => BoundaryRegionImpl._(value | other.value);

  /// Gets the AND of the two boundary regions.
  @override
  BoundaryRegion operator &(BoundaryRegion other) => BoundaryRegionImpl._(value & other.value);

  /// Gets the string for the given boundary region.
  @override
  String toString() {
    switch (value) {
      case 0x00:
        return "Inside";
      case 0x01:
        return "South";
      case 0x02:
        return "North";
      case 0x03:
        return "Vertical";
      case 0x04:
        return "West";
      case 0x05:
        return "SouthWest";
      case 0x06:
        return "NorthWest";
      case 0x08:
        return "East";
      case 0x09:
        return "SouthEast";
      case 0x0A:
        return "NorthEast";
      case 0x0C:
        return "Horizontal";
      default:
        return "Unknown(" + value.toString() + ")";
    }
  }
}
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
