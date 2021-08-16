import 'dart:math';

import '../math/math.dart';

// FUTURE: Add the following:
// - TwoRegion2
// - TwoRegion3
// - RegionSphere
// - AABBSphere
// - RegionPlane
// - AABBPlane
// - SpherePlane
// - TriangleRegion
// - TriangleAABB
// - TriangleSphere
// - TrianglePlane
// - TwoTriangle

/// Indicates the result type of the collision.
enum Type {
  /// Indicates there was no collision because the two shapes were already intesected at t = 0.
  Intesected,

  /// Indicates that no collision is possible, meaning the shapes are not moving relative
  /// to eachother, they are moving parrallel to eachother, or they are moving away from eachother.
  NoCollision,

  /// Indicates that a collision would happen in the future if the shapes doen't change direction,
  /// but didn't happen within the length of the given vector(s).
  ///
  /// Although additional information such as the hit location can be determined for
  /// out-of-range collisions, they are not calculated to save computation time since normally
  /// out-of-range collisions are treated the same as no collision.
  OutOfRange,

  /// Indicaates the shape collide within the given vector(s).
  Collision,
}

/// The common shared result of a collision test between two shapes.
abstract class BaseResult {
  /// The type of collision which occurred.
  final Type type;

  /// The amount of time based on the vector(s) before the collision.
  /// A collision within the vector will have a parametric between 0 and 1 inclusively.
  final double parametric;

  /// Indicates if a collision occurred with the given vector(s).
  bool get collided => type == Type.Collision;

  /// Creates a new collision result for collision between shapes.
  BaseResult(
    final this.type,
    final this.parametric,
  );

  /// Gets the string for this collision.
  @override
  String toString() {
    switch (this.type) {
      case Type.Intesected:
        return "intesected";
      case Type.NoCollision:
        return "noCollision";
      case Type.OutOfRange:
        return "outOfRange at ${this.parametric}";
      case Type.Collision:
        return "collision at ${this.parametric}";
    }
  }
}

/// The results of a collision test between a sphere and a plane.
class SpherePlaneResult extends BaseResult {
  /// The sphere in this collision.
  final Sphere sphere;

  /// The plane in this collision.
  final Plane plane;

  /// The vector for the sphere moving in the given time frame.
  final Vector3 vec;

  /// Indicates if the back of the plane should collide or not.
  final bool backside;

  /// The center point of the sphere when the collision occurred.
  /// This is null when no collision occurred.
  final Point3? center;

  /// The point on the surface of the sphere and plane the collision occurred at.
  /// This is null when no collision occurred or intersected.
  final Point3? hitPoint;

  /// Creates a new collision result for collision between a sphere and a plane.
  SpherePlaneResult(
    final Type type,
    final double parametric,
    final this.sphere,
    final this.plane,
    final this.vec,
    final this.backside, [
    final this.center,
    final this.hitPoint,
  ]) : super(
          type,
          parametric,
        );

  /// Gets the string for this collision.
  @override
  String toString() =>
      super.toString() +
      (() {
        if (this.collided) {
          return ' ${this.center} ${this.hitPoint}';
        } else {
          return '';
        }
      }());
}

/// Tests the collision between two moving spheres.
/// The given vector represent the constant amount of distance moved in a time span.
/// The optional [backside] parameter indicates if the back of the plane should collide or not.
SpherePlaneResult spherePlane(
  final Sphere sphere,
  final Plane plane,
  final Vector3 vec, [
  final bool backside = false,
]) {
  final n = plane.normal.normal();
  final div = vec.dot(n);
  if (div == 0.0) {
    return SpherePlaneResult(Type.NoCollision, 0.0, sphere, plane, vec, backside);
  } else if ((div > 0.0) && !backside) {
    return SpherePlaneResult(Type.NoCollision, 0.0, sphere, plane, vec, backside);
  } else {
    final c = Vector3(sphere.x, sphere.y, sphere.z);
    final t = (plane.offset - c.dot(n) + sphere.radius) / div;
    if (t < 0.0) {
      return SpherePlaneResult(Type.NoCollision, t, sphere, plane, vec, backside);
    } else if (t > 1.0) {
      return SpherePlaneResult(Type.OutOfRange, t, sphere, plane, vec, backside);
    } else {
      final c2 = Point3(sphere.x + vec.dx * t, sphere.y + vec.dy * t, sphere.z + vec.dz * t);
      final hit = plane.nearestPoint(c2);
      Type type = Type.Collision;
      if (c2.distance(hit) < sphere.radius) {
        type = Type.Intesected;
      }
      return SpherePlaneResult(type, t, sphere, plane, vec, backside, c2, hit);
    }
  }
}

/// Results from an collision between two moving AABB regions.
class TwoAABB2Result extends BaseResult {
  /// The first of the two regions in the collision.
  final Region2 regionA;

  /// The second of the two regions in the collision.
  final Region2 regionB;

  /// The vector for the first region moving in the given time frame.
  final Vector2 vecA;

  /// The vector for the second region moving in the given time frame.
  final Vector2 vecB;

  /// The sides for the first region can collide on.
  final HitRegion sidesA;

  /// The sides for the first region can collide on.
  final HitRegion sidesB;

  /// The side of the target region which was hit.
  final HitRegion region;

  /// Creates a new collision result for collision between AABB regions.
  TwoAABB2Result(
    final Type type,
    final double parametric,
    final this.regionA,
    final this.regionB,
    final this.vecA,
    final this.vecB,
    final this.sidesA,
    final this.sidesB,
    final this.region,
  ) : super(type, parametric);

  /// Gets the string for this collision.
  @override
  String toString() =>
      super.toString() +
      (() {
        if (this.collided) {
          return " ${this.region}";
        } else {
          return "";
        }
      }());
}

/// Determines the collision between two moving axial aligned bounding box (AABB).
/// The given vectors represent the constant amount of distance moved in a time span.
/// Optionally sides of the AABBs can be disabled to provide single sided collision.
TwoAABB2Result twoAABB2(
  final Region2 regionA,
  final Region2 regionB,
  final Vector2 vecA,
  final Vector2 vecB, [
  HitRegion? sidesA,
  HitRegion? sidesB,
]) {
  sidesA ??= HitRegion.All;
  sidesB ??= HitRegion.All;
  final sides = sidesB & sidesA.inverse();
  final vector = vecA - vecB;
  double t = 100.0, d = 0.0;
  HitRegion region = HitRegion.None, edge = HitRegion.None;
  bool edgeTest;
  if (vector.dx != 0.0) {
    edgeTest = false;
    if (vector.dx > 0.0) {
      if (sides.has(HitRegion.XNeg)) {
        edge = HitRegion.XNeg;
        edgeTest = true;
        if (Comparer.equals(regionB.x, regionA.x + regionA.dx)) {
          d = 0.0;
        } else {
          d = (regionB.x - (regionA.x + regionA.dx)) / vector.dx;
        }
      }
    } else {
      if (sides.has(HitRegion.XPos)) {
        edge = HitRegion.XPos;
        edgeTest = true;
        if (Comparer.equals(regionB.x + regionB.dx, regionA.x)) {
          d = 0.0;
        } else {
          d = ((regionB.x + regionB.dx) - regionA.x) / vector.dx;
        }
      }
    }
    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final y = regionA.y + vector.dy * d;
      if (rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
        t = d;
        region = edge;
      }
    }
  }
  if (vector.dy != 0.0) {
    edgeTest = false;
    if (vector.dy > 0.0) {
      if (sides.has(HitRegion.YNeg)) {
        edge = HitRegion.YNeg;
        edgeTest = true;
        if (Comparer.equals(regionB.y, regionA.y + regionA.dy)) {
          d = 0.0;
        } else {
          d = (regionB.y - (regionA.y + regionA.dy)) / vector.dy;
        }
      }
    } else {
      if (sides.has(HitRegion.YPos)) {
        edge = HitRegion.YPos;
        edgeTest = true;
        if (Comparer.equals(regionB.y + regionB.dy, regionA.y)) {
          d = 0.0;
        } else {
          d = ((regionB.y + regionB.dy) - regionA.y) / vector.dy;
        }
      }
    }
    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final x = regionA.x + vector.dx * d;
      if (rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        t = d;
        region = edge;
      }
    }
  }
  if (region == HitRegion.None) {
    final overlap = regionA.overlaps(regionB);
    final type = () {
      if (overlap) {
        return Type.Intesected;
      } else {
        return Type.NoCollision;
      }
    }();
    return TwoAABB2Result(type, 0.0, regionA, regionB, vecA, vecB, sidesA, sidesB, HitRegion.None);
  } else {
    return TwoAABB2Result(Type.Collision, t, regionA, regionB, vecA, vecB, sidesA, sidesB, region);
  }
}

/// Results from an collision between two moving AABB regions.
class TwoAABB3Result extends BaseResult {
  /// The first of the two regions in the collision.
  final Region3 regionA;

  /// The second of the two regions in the collision.
  final Region3 regionB;

  /// The vector for the first region moving in the given time frame.
  final Vector3 vecA;

  /// The vector for the second region moving in the given time frame.
  final Vector3 vecB;

  /// The sides for the first region can collide on.
  final HitRegion sidesA;

  /// The sides for the first region can collide on.
  final HitRegion sidesB;

  /// The side of the target region which was hit.
  final HitRegion region;

  /// Creates a new collision result for collision between AABB regions.
  TwoAABB3Result(
    final Type type,
    final double parametric,
    final this.regionA,
    final this.regionB,
    final this.vecA,
    final this.vecB,
    final this.sidesA,
    final this.sidesB,
    final this.region,
  ) : super(type, parametric);

  /// Gets the string for this collision.
  @override
  String toString() =>
      super.toString() +
      (() {
        if (this.collided) {
          return " " + this.region.toString();
        } else {
          return "";
        }
      }());
}

/// Determines the collision between two moving axial aligned bounding box (AABB).
/// The given vectors represent the constant amount of distance moved in a time span.
/// Optionally sides of the AABBs can be disabled to provide single sided collision.
TwoAABB3Result twoAABB3(
  final Region3 regionA,
  final Region3 regionB,
  final Vector3 vecA,
  final Vector3 vecB, [
  HitRegion? sidesA,
  HitRegion? sidesB,
]) {
  // ignore: parameter_assignments
  sidesA ??= HitRegion.All;
  // ignore: parameter_assignments
  sidesB ??= HitRegion.All;
  final sides = sidesB & sidesA.inverse();
  final vector = vecA - vecB;
  double t = 100.0, d = 0.0;
  HitRegion region = HitRegion.None, edge = HitRegion.None;
  bool edgeTest;
  if (vector.dx != 0.0) {
    edgeTest = false;
    if (vector.dx > 0.0) {
      if (sides.has(HitRegion.XNeg)) {
        edge = HitRegion.XNeg;
        edgeTest = true;
        if (Comparer.equals(regionB.x, regionA.x + regionA.dx)) {
          d = 0.0;
        } else {
          d = (regionB.x - (regionA.x + regionA.dx)) / vector.dx;
        }
      }
    } else {
      if (sides.has(HitRegion.XPos)) {
        edge = HitRegion.XPos;
        edgeTest = true;
        if (Comparer.equals(regionB.x + regionB.dx, regionA.x)) {
          d = 0.0;
        } else {
          d = ((regionB.x + regionB.dx) - regionA.x) / vector.dx;
        }
      }
    }
    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final y = regionA.y + vector.dy * d;
      if (rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
        final z = regionA.z + vector.dz * d;
        if (rangeOverlap(regionB.z, regionB.z + regionB.dz, z, z + regionA.dz)) {
          t = d;
          region = edge;
        }
      }
    }
  }
  if (vector.dy != 0.0) {
    edgeTest = false;
    if (vector.dy > 0.0) {
      if (sides.has(HitRegion.YNeg)) {
        edge = HitRegion.YNeg;
        edgeTest = true;
        if (Comparer.equals(regionB.y, regionA.y + regionA.dy)) {
          d = 0.0;
        } else {
          d = (regionB.y - (regionA.y + regionA.dy)) / vector.dy;
        }
      }
    } else {
      if (sides.has(HitRegion.YPos)) {
        edge = HitRegion.YPos;
        edgeTest = true;
        if (Comparer.equals(regionB.y + regionB.dy, regionA.y)) {
          d = 0.0;
        } else {
          d = ((regionB.y + regionB.dy) - regionA.y) / vector.dy;
        }
      }
    }
    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final x = regionA.x + vector.dx * d;
      if (rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        final z = regionA.z + vector.dz * d;
        if (rangeOverlap(regionB.z, regionB.z + regionB.dz, z, z + regionA.dz)) {
          t = d;
          region = edge;
        }
      }
    }
  }
  if (vector.dz != 0.0) {
    edgeTest = false;
    if (vector.dz > 0.0) {
      if (sides.has(HitRegion.ZNeg)) {
        edge = HitRegion.ZNeg;
        edgeTest = true;
        if (Comparer.equals(regionB.z, regionA.z + regionA.dz)) {
          d = 0.0;
        } else {
          d = (regionB.z - (regionA.z + regionA.dz)) / vector.dz;
        }
      }
    } else {
      if (sides.has(HitRegion.ZPos)) {
        edge = HitRegion.ZPos;
        edgeTest = true;
        if (Comparer.equals(regionB.z + regionB.dz, regionA.z)) {
          d = 0.0;
        } else {
          d = ((regionB.z + regionB.dz) - regionA.z) / vector.dz;
        }
      }
    }
    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final x = regionA.x + vector.dx * d;
      if (rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        final y = regionA.y + vector.dy * d;
        if (rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
          t = d;
          region = edge;
        }
      }
    }
  }
  if (region == HitRegion.None) {
    final overlap = regionA.overlaps(regionB);
    final type = () {
      if (overlap) {
        return Type.Intesected;
      } else {
        return Type.NoCollision;
      }
    }();
    return TwoAABB3Result(type, 0.0, regionA, regionB, vecA, vecB, sidesA, sidesB, HitRegion.None);
  } else {
    return TwoAABB3Result(Type.Collision, t, regionA, regionB, vecA, vecB, sidesA, sidesB, region);
  }
}

/// The results of a collision test between two spheres.
class TwoSphereResult extends BaseResult {
  /// The first sphere in this collision.
  final Sphere sphereA;

  /// The second sphere in this collision.
  final Sphere sphereB;

  /// The vector for the first sphere moving in the given time frame.
  final Vector3 vecA;

  /// The vector for the second sphere moving in the given time frame.
  final Vector3 vecB;

  /// The center point of sphere A when the collision occurred.
  /// This is null when no collision occurred.
  final Point3? centerA;

  /// The center point of sphere B when the collision occurred.
  /// This is null when no collision occurred.
  final Point3? centerB;

  /// The point on the surface of sphere A and B the collision occurred at.
  /// This is null when no collision occurred or intersected.
  final Point3? hitPoint;

  /// Creates a new collision result for collision between spheres.
  TwoSphereResult(
    final Type type,
    final double parametric,
    final this.sphereA,
    final this.sphereB,
    final this.vecA,
    final this.vecB, [
    final this.centerA,
    final this.centerB,
    final this.hitPoint,
  ]) : super(type, parametric);

  /// Gets the string for this collision.
  @override
  String toString() => super.toString() + (this.collided ? " ${this.centerA} ${this.centerB} ${this.hitPoint}" : "");
}

/// Tests the collision between two moving spheres.
/// The given vectors represent the constant amount of distance moved in a time span.
TwoSphereResult twoSphere(
  final Sphere sphereA,
  final Sphere sphereB,
  final Vector3 vecA,
  final Vector3 vecB,
) {
  final cA = sphereA.center;
  final cB = sphereB.center;
  final e = cB.vectorTo(cA);
  final r = sphereA.radius + sphereB.radius;
  final r2 = r * r;
  final ee = e.dot(e);
  if (ee < r2) {
    return TwoSphereResult(Type.Intesected, 0.0, sphereA, sphereB, vecA, vecB, cA, cB);
  } else {
    final d = vecB - vecA;
    final len = d.length();
    final d2 = d.normal();
    final ed = e.dot(d2);
    if (Comparer.equals(ee, r2) && (ed < 0.0)) {
      return TwoSphereResult(Type.NoCollision, 0.0, sphereA, sphereB, vecA, vecB);
    } else {
      final f = ed * ed + r2 - ee;
      if (f < 0.0) {
        return TwoSphereResult(Type.NoCollision, 0.0, sphereA, sphereB, vecA, vecB);
      } else {
        final t = ed - sqrt(f);
        if (t < 0.0) {
          return TwoSphereResult(Type.NoCollision, t, sphereA, sphereB, vecA, vecB);
        } else {
          if (t > len) {
            return TwoSphereResult(Type.OutOfRange, t, sphereA, sphereB, vecA, vecB);
          } else {
            final t2 = t / len;
            final cA2 = Point3(sphereA.x + vecA.dx * t2, sphereA.y + vecA.dy * t2, sphereA.z + vecA.dz * t2);
            final cB2 = Point3(sphereB.x + vecB.dx * t2, sphereB.y + vecB.dy * t2, sphereB.z + vecB.dz * t2);
            final scalar = sphereA.radius / sqrt(ee);
            final hit = Point3(
                (cB2.x - cA2.x) * scalar + cA2.x, (cB2.y - cA2.y) * scalar + cA2.y, (cB2.z - cA2.z) * scalar + cA2.z);
            return TwoSphereResult(Type.Collision, t, sphereA, sphereB, vecA, vecB, cA2, cB2, hit);
          }
        }
      }
    }
  }
}
