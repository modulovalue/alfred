import 'dart:math' as math;

import '../math/math.dart';

/// The common shared result of a intersection test between shapes.
class BaseResult {
  /// Indicates if a intersection occurred.
  final bool intesects;

  /// Creates a new intersection result for intersection between shapes.
  BaseResult(this.intesects);

  /// Gets the string for this intersection.
  @override
  String toString() => intesects ? "intesection" : "noIntesection";
}

/// Determines there is an intersection between the given [triangle] and [plane].
BaseResult trianglePlane(
  final Triangle3 triangle,
  final Plane plane,
) {
  final side = plane.sideOfPointComponents(triangle.x1, triangle.y1, triangle.z1);
  if (side == Side.Inside) return BaseResult(true);
  Side other = plane.sideOfPointComponents(triangle.x2, triangle.y2, triangle.z2);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(triangle.x3, triangle.y3, triangle.z3);
  if (other == Side.Inside) return BaseResult(true);
  return BaseResult(side != other);
}

// Project the triangle's vertices onto the potential seperating axis
// and determine if this axis is seperating or not.
// Based on code from https://gdbooks.gitbooks.io/3dcollisions/content/Chapter4/aabb-triangle.html
bool _isSeparatingAxis(Vector3 regionSize, Vector3 axis, Vector3 v1, Vector3 v2, Vector3 v3) {
  final p0 = v1.dot(axis);
  final p1 = v2.dot(axis);
  final p2 = v3.dot(axis);
  // Project the AABB size onto the seperating axis, since the AABB will be centered on the origin.
  final r = regionSize.dx * Vector3.posX.dot(axis).abs() +
      regionSize.dy * Vector3.posY.dot(axis).abs() +
      regionSize.dz * Vector3.posZ.dot(axis).abs();
  // Check if the extreme points from the triangle intersect r.
  final max = math.max(math.max(p0, p1), p2);
  final min = math.min(math.min(p0, p1), p2);
  if (math.max(-max, min) <= r) {
    // This means the extreme points of the projected triangle is outside the
    // projected AABB size. Therefore the axis is seperating and we can exit.
    return true;
  }

  // Can not seperate along this axis.
  return false;
}

// Determine if there is a separating axis between the a triangle and an AABB.
bool _hasSeparatingAxis(Point3 regionCenter, Vector3 regionSize, Triangle3 tri) {
  final v1 = regionCenter.vectorTo(tri.point1);
  final v2 = regionCenter.vectorTo(tri.point2);
  final v3 = regionCenter.vectorTo(tri.point3);
  // Check the 3 AABB face normals.
  if (_isSeparatingAxis(regionSize, Vector3.posX, v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posY, v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posZ, v1, v2, v3)) return true;
  // Check the 9 axis for the edge vectors of the triangle cross with face normals.
  final f1 = v2 - v1;
  if (_isSeparatingAxis(regionSize, Vector3.posX.cross(f1), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posY.cross(f1), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posZ.cross(f1), v1, v2, v3)) return true;
  final f2 = v3 - v2;
  if (_isSeparatingAxis(regionSize, Vector3.posX.cross(f2), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posY.cross(f2), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posZ.cross(f2), v1, v2, v3)) return true;
  final f3 = v1 - v3;
  if (_isSeparatingAxis(regionSize, Vector3.posX.cross(f3), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posY.cross(f3), v1, v2, v3)) return true;
  if (_isSeparatingAxis(regionSize, Vector3.posZ.cross(f3), v1, v2, v3)) return true;
  // Check the triangle normal.
  if (_isSeparatingAxis(regionSize, f1.cross(f2), v1, v2, v3)) return true;
  // Checked all 13 separating axii and found no separation.
  return false;
}

/// Determines if the [region] intersects or contains given [triangle].
BaseResult regionTriangle(Region3 region, Triangle3 triangle) {
  final center = region.center;
  final size = center.vectorTo(region.maxCorner);
  final hasSep = _hasSeparatingAxis(center, size, triangle);
  return BaseResult(!hasSep);
}

/// Determines if the [cube] intersects or contains given [triangle].
BaseResult cubeTriangle(Cube cube, Triangle3 triangle) {
  final center = cube.center;
  final halfSize = cube.size * 0.5;
  final size = Vector3(halfSize, halfSize, halfSize);
  final hasSep = _hasSeparatingAxis(center, size, triangle);
  return BaseResult(!hasSep);
}

/// Determines there is an intersection between the given [range] and [plane].
BaseResult regionPlane(Region3 range, Plane plane) {
  final min = range.minCorner;
  final max = range.maxCorner;
  final side = plane.sideOfPointComponents(min.x, min.y, min.z);
  if (side == Side.Inside) return BaseResult(true);
  Side other = plane.sideOfPointComponents(min.x, min.y, max.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(min.x, max.y, min.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(min.x, max.y, max.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(max.x, min.y, min.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(max.x, min.y, max.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(max.x, max.y, min.z);
  if (other == Side.Inside) return BaseResult(true);
  if (side != other) return BaseResult(true);
  other = plane.sideOfPointComponents(max.x, max.y, max.z);
  if (other == Side.Inside) return BaseResult(true);
  return BaseResult(side != other);
}

/// Determines the intersection between the given [ray] and [sphere].
RaySphereResult raySphere(
  final Ray3 ray,
  final Sphere sphere,
) {
  final start = ray.start;
  final e = start.vectorTo(sphere.center);
  final e2 = e.length2();
  final r2 = sphere.radius * sphere.radius;
  if (e2 <= r2) return RaySphereResult(true, start, 0.0);
  final a = e.dot(ray.vector);
  final t = a - math.sqrt(r2 - e2 + a * a);
  if ((t < 0.0) || (t > 1.0)) return RaySphereResult(false, null, 0.0);
  final pnt = Point3(ray.x + ray.dx * t, ray.y + ray.dy * t, ray.z + ray.dz * t);
  return RaySphereResult(true, pnt, t);
}

/// Results from an intersection between a 3D ray and sphere.
class RaySphereResult extends BaseResult {
  /// The point in or on the surface of the sphere which the ray intersects.
  final Point3? point;

  /// The parametric value between 0 and 1 inclusively of the ray to the intersection point.
  final double parametric;

  /// Creates a new intersection result.
  RaySphereResult(bool intersects, this.point, this.parametric) : super(intersects);

  /// Gets the string for this intersection.
  @override
  String toString() => "${super.toString()} $point $parametric";
}

/// Determines the intersection between the given [ray] and [region].
RayRegion3Result rayRegion3(Ray3 ray, Region3 region) {
  final maxx = region.x + region.dx;
  final maxy = region.y + region.dy;
  final maxz = region.z + region.dz;
  // Check for point inside box, trivial reject, and determine
  // parametric distance to each front face
  bool inside = true;
  double xt = 0.0, xn = 0.0, xp = 0.0;
  HitRegion xregion = HitRegion.None;
  if (ray.x < region.x) {
    xt = region.x - ray.x;
    if (xt > ray.dx) return RayRegion3Result.none();
    xt /= ray.dx;
    inside = false;
    xn = -1.0;
    xp = region.x;
    xregion = HitRegion.XNeg;
  } else if (ray.x > maxx) {
    xt = maxx - ray.x;
    if (xt < ray.dx) return RayRegion3Result.none();
    xt /= ray.dx;
    inside = false;
    xn = 1.0;
    xp = maxx;
    xregion = HitRegion.XPos;
  } else {
    xt = -1.0;
  }
  double yt = 0.0, yn = 0.0, yp = 0.0;
  HitRegion yregion = HitRegion.None;
  if (ray.y < region.y) {
    yt = region.y - ray.y;
    if (yt > ray.dy) return RayRegion3Result.none();
    yt /= ray.dy;
    inside = false;
    yn = -1.0;
    yp = region.y;
    yregion = HitRegion.YNeg;
  } else if (ray.y > maxy) {
    yt = maxy - ray.y;
    if (yt < ray.dy) return RayRegion3Result.none();
    yt /= ray.dy;
    inside = false;
    yn = 1.0;
    yp = maxy;
    yregion = HitRegion.YPos;
  } else {
    yt = -1.0;
  }
  double zt = 0.0, zn = 0.0, zp = 0.0;
  HitRegion zregion = HitRegion.None;
  if (ray.z < region.z) {
    zt = region.z - ray.z;
    if (zt > ray.dz) return RayRegion3Result.none();
    zt /= ray.dz;
    inside = false;
    zn = -1.0;
    zp = region.z;
    zregion = HitRegion.ZNeg;
  } else if (ray.z > maxz) {
    zt = maxz - ray.z;
    if (zt < ray.dz) return RayRegion3Result.none();
    zt /= ray.dz;
    inside = false;
    zn = 1.0;
    zp = maxz;
    zregion = HitRegion.ZPos;
  } else {
    zt = -1.0;
  }
  if (inside) {
    return RayRegion3Result(ray.start, -ray.vector.normal(), 0.0, HitRegion.Inside);
  }
  // The farthest plane is the plane of intersection.
  final which = () {
    if (yt > xt) {
      if (zt > yt) {
        return 2;
      } else {
        return 1;
      }
    } else {
      if (zt > xt) {
        return 2;
      } else {
        return 0;
      }
    }
  }();
  switch (which) {
    case 0: // intersect with yz plane
      final y = ray.y + ray.dy * xt;
      if (!inRange(y, region.y, maxy)) return RayRegion3Result.none();
      final z = ray.z + ray.dz * xt;
      if (!inRange(z, region.z, maxz)) return RayRegion3Result.none();
      return RayRegion3Result(Point3(xp, y, z), Vector3(xn, 0.0, 0.0), xt, xregion);
    case 1: // intersect with xz plane
      final x = ray.x + ray.dx * yt;
      if (!inRange(x, region.x, maxx)) return RayRegion3Result.none();
      final z = ray.z + ray.dz * yt;
      if (!inRange(z, region.z, maxz)) return RayRegion3Result.none();
      return RayRegion3Result(Point3(x, yp, z), Vector3(0.0, yn, 0.0), yt, yregion);
    default: // 2, intersect with xy plane
      final x = ray.x + ray.dx * zt;
      if (!inRange(x, region.x, maxx)) return RayRegion3Result.none();
      final y = ray.y + ray.dy * zt;
      if (!inRange(y, region.y, maxy)) return RayRegion3Result.none();
      return RayRegion3Result(Point3(x, y, zp), Vector3(0.0, 0.0, zn), zt, zregion);
  }
}

/// Results from an intersection between a 3D ray and region.
class RayRegion3Result extends BaseResult {
  /// The point in or on the region which the ray intersects.
  final Point3? point;

  /// The normal of the surface on the region that the ray intersects.
  final Vector3? normal;

  /// The parametric value between 0 and 1 inclusively of the ray to the intersection point.
  final double parametric;

  /// The side of the region which was hit.
  final HitRegion region;

  /// Creates a new intersection result for an intersection.
  factory RayRegion3Result(Point3 point, Vector3 normal, double parametric, HitRegion region) =>
      RayRegion3Result._(true, point, normal, parametric, region);

  /// Creates a new intersection result.
  RayRegion3Result._(bool intesects, this.point, this.normal, this.parametric, this.region) : super(intesects);

  /// Creates a new intersection result for no intersection.
  factory RayRegion3Result.none() => RayRegion3Result._(false, null, null, 0.0, HitRegion.None);

  /// Gets the string for this intersection.
  @override
  String toString() => "${super.toString()} $point <$normal> $parametric $region";
}

/// Determines the intersection between the given [ray] and this region.
RayRegion2Result rayRegion2(Ray2 ray, Region2 region) {
  final maxx = region.x + region.dx;
  final maxy = region.y + region.dy;
  // Check for point inside box, trivial reject, and determine
  // parametric distance to each front face
  bool inside = true;
  double xt = 0.0, xn = 0.0, xp = 0.0;
  HitRegion xregion = HitRegion.None;
  if (ray.x < region.x) {
    xt = region.x - ray.x;
    if (xt > ray.dx) return RayRegion2Result.none();
    xt /= ray.dx;
    inside = false;
    xn = -1.0;
    xp = region.x;
    xregion = HitRegion.XNeg;
  } else {
    if (ray.x > maxx) {
      xt = maxx - ray.x;
      if (xt < ray.dx) return RayRegion2Result.none();
      xt /= ray.dx;
      inside = false;
      xn = 1.0;
      xp = maxx;
      xregion = HitRegion.XPos;
    } else {
      xt = -1.0;
    }
  }
  double yt = 0.0, yn = 0.0, yp = 0.0;
  HitRegion yregion = HitRegion.None;
  if (ray.y < region.y) {
    yt = region.y - ray.y;
    if (yt > ray.dy) return RayRegion2Result.none();
    yt /= ray.dy;
    inside = false;
    yn = -1.0;
    yp = region.y;
    yregion = HitRegion.YNeg;
  } else {
    if (ray.y > maxy) {
      yt = maxy - ray.y;
      if (yt < ray.dy) return RayRegion2Result.none();
      yt /= ray.dy;
      inside = false;
      yn = 1.0;
      yp = maxy;
      yregion = HitRegion.YPos;
    } else {
      yt = -1.0;
    }
  }

  if (inside) return RayRegion2Result(ray.start, -ray.vector.normal(), 0.0, HitRegion.Inside);

  // The farthest plane is the plane of intersection.
  if (yt > xt) {
    // intersect with xz plane
    final x = ray.x + ray.dx * yt;
    if (inRange(x, region.x, maxx)) {
      return RayRegion2Result(Point2(x, yp), Vector2(0.0, yn), yt, yregion);
    }
  } else {
    // intersect with yz plane
    final y = ray.y + ray.dy * xt;
    if (inRange(y, region.y, maxy)) {
      return RayRegion2Result(Point2(xp, y), Vector2(xn, 0.0), xt, xregion);
    }
  }

  return RayRegion2Result.none();
}

/// Results from an intersection between a 2D ray and region.
class RayRegion2Result extends BaseResult {
  /// The point in or on the region which the ray intersects.
  final Point2? point;

  /// The normal of the surface on the region that the ray intersects.
  final Vector2? normal;

  /// The parametric value between 0 and 1 inclusively of the ray to the intersection point.
  final double parametric;

  /// The side of the region which was hit.
  final HitRegion region;

  /// Creates a new intersection result for an intersection.
  factory RayRegion2Result(Point2 point, Vector2 normal, double parametric, HitRegion region) =>
      RayRegion2Result._(true, point, normal, parametric, region);

  /// Creates a new intersection result.
  RayRegion2Result._(bool intersets, this.point, this.normal, this.parametric, this.region) : super(intersets);

  /// Creates a new intersection result for no intersection.
  factory RayRegion2Result.none() => RayRegion2Result._(false, null, null, 0.0, HitRegion.None);

  /// Gets the string for this intersection.
  @override
  String toString() => "${super.toString()} $point <$normal> $parametric $region";
}

/// Determines the intersection between the given [ray] and [plane].
RayPlaneResult rayPlane(Ray3 ray, Plane plane) {
  final norm = plane.normal;
  final p0 = Vector3(ray.x, ray.y, ray.z);
  final vec = ray.vector;
  final dem = vec.dot(norm);
  if (dem == 0.0) return RayPlaneResult.none();
  final t = (plane.offset - p0.dot(norm)) / dem;
  if ((t < 0.0) || (t > 1.0)) return RayPlaneResult.none();
  return RayPlaneResult(Point3.fromVector3(p0 + norm * t), t);
}

/// Results from an intersection between a 3D ray and plane.
class RayPlaneResult extends BaseResult {
  /// The point in or on the plane which the ray intersects.
  final Point3? point;

  /// The parametric value between 0 and 1 inclusively of the ray to the intersection point.
  final double parametric;

  /// Creates a new intersection result.
  factory RayPlaneResult(Point3 point, double parametric) => RayPlaneResult._(true, point, parametric);

  /// Creates a new intersection result.
  RayPlaneResult._(bool intesects, this.point, this.parametric) : super(intesects);

  /// Creates a new intersection result.
  factory RayPlaneResult.none() => RayPlaneResult._(false, null, 0.0);

  /// Gets the string for this intersection.
  @override
  String toString() => "${super.toString()} $point $parametric";
}

/// Get the point intersection of three planes.
PlanesResult planes(Plane plane1, Plane plane2, Plane plane3) {
  final normal1 = plane1.normal;
  final normal2 = plane2.normal;
  final normal3 = plane3.normal;
  final cross12 = normal1.cross(normal2);
  final div = cross12.dot(normal3);
  if (Comparer.equals(div, 0.0)) return PlanesResult(false, null);
  final cross23 = normal2.cross(normal3);
  final cross31 = normal3.cross(normal1);
  final result = (cross23 * plane1.offset + cross31 * plane2.offset + cross12 * plane3.offset) / div;
  return PlanesResult(true, Point3.fromVector3(result));
}

/// Results from an intersection between 3 planes.
class PlanesResult extends BaseResult {
  /// The point where the 3 planes intersect at or null when not intersection.
  final Point3? point;

  /// Creates a new intersection result.
  PlanesResult(bool intesects, this.point) : super(intesects);

  /// Gets the string for this intersection.
  @override
  String toString() => "${super.toString()} $point";
}
