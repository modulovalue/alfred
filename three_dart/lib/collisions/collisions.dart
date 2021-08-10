import 'dart:math' as math;

import '../math/math.dart' as math;

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
  BaseResult(this.type, this.parametric);

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
  final math.Sphere sphere;

  /// The plane in this collision.
  final math.Plane plane;

  /// The vector for the sphere moving in the given time frame.
  final math.Vector3 vec;

  /// Indicates if the back of the plane should collide or not.
  final bool backside;

  /// The center point of the sphere when the collision occurred.
  /// This is null when no collision occurred.
  final math.Point3? center;

  /// The point on the surface of the sphere and plane the collision occurred at.
  /// This is null when no collision occurred or intersected.
  final math.Point3? hitPoint;

  /// Creates a new collision result for collision between a sphere and a plane.
  SpherePlaneResult(Type type, double parametric, this.sphere, this.plane, this.vec, this.backside,
      [this.center, this.hitPoint])
      : super(type, parametric);

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
SpherePlaneResult spherePlane(math.Sphere sphere, math.Plane plane, math.Vector3 vec, [bool backside = false]) {
  final math.Vector3 n = plane.normal.normal();
  final double div = vec.dot(n);
  if (div == 0.0) {
    return SpherePlaneResult(Type.NoCollision, 0.0, sphere, plane, vec, backside);
  }
  if ((div > 0.0) && !backside) {
    return SpherePlaneResult(Type.NoCollision, 0.0, sphere, plane, vec, backside);
  }

  final math.Vector3 c = math.Vector3(sphere.x, sphere.y, sphere.z);
  final double t = (plane.offset - c.dot(n) + sphere.radius) / div;
  if (t < 0.0) {
    return SpherePlaneResult(Type.NoCollision, t, sphere, plane, vec, backside);
  }
  if (t > 1.0) {
    return SpherePlaneResult(Type.OutOfRange, t, sphere, plane, vec, backside);
  }

  final math.Point3 c2 = math.Point3(sphere.x + vec.dx * t, sphere.y + vec.dy * t, sphere.z + vec.dz * t);
  final math.Point3 hit = plane.nearestPoint(c2);
  Type type = Type.Collision;
  if (c2.distance(hit) < sphere.radius) type = Type.Intesected;
  return SpherePlaneResult(type, t, sphere, plane, vec, backside, c2, hit);
}

/// Results from an collision between two moving AABB regions.
class TwoAABB2Result extends BaseResult {
  /// The first of the two regions in the collision.
  final math.Region2 regionA;

  /// The second of the two regions in the collision.
  final math.Region2 regionB;

  /// The vector for the first region moving in the given time frame.
  final math.Vector2 vecA;

  /// The vector for the second region moving in the given time frame.
  final math.Vector2 vecB;

  /// The sides for the first region can collide on.
  final math.HitRegion sidesA;

  /// The sides for the first region can collide on.
  final math.HitRegion sidesB;

  /// The side of the target region which was hit.
  final math.HitRegion region;

  /// Creates a new collision result for collision between AABB regions.
  TwoAABB2Result(Type type, double parametric, this.regionA, this.regionB, this.vecA, this.vecB, this.sidesA,
      this.sidesB, this.region)
      : super(type, parametric);

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
TwoAABB2Result twoAABB2(math.Region2 regionA, math.Region2 regionB, math.Vector2 vecA, math.Vector2 vecB,
    [math.HitRegion? sidesA, math.HitRegion? sidesB]) {
  sidesA ??= math.HitRegion.All;
  sidesB ??= math.HitRegion.All;
  final math.HitRegion sides = sidesB & sidesA.inverse();
  final math.Vector2 vector = vecA - vecB;

  double t = 100.0, d = 0.0;
  math.HitRegion region = math.HitRegion.None, edge = math.HitRegion.None;
  bool edgeTest;

  if (vector.dx != 0.0) {
    edgeTest = false;
    if (vector.dx > 0.0) {
      if (sides.has(math.HitRegion.XNeg)) {
        edge = math.HitRegion.XNeg;
        edgeTest = true;
        if (math.Comparer.equals(regionB.x, regionA.x + regionA.dx)) {
          d = 0.0;
        } else {
          d = (regionB.x - (regionA.x + regionA.dx)) / vector.dx;
        }
      }
    } else {
      if (sides.has(math.HitRegion.XPos)) {
        edge = math.HitRegion.XPos;
        edgeTest = true;
        if (math.Comparer.equals(regionB.x + regionB.dx, regionA.x)) {
          d = 0.0;
        } else {
          d = ((regionB.x + regionB.dx) - regionA.x) / vector.dx;
        }
      }
    }

    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final double y = regionA.y + vector.dy * d;
      if (math.rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
        t = d;
        region = edge;
      }
    }
  }

  if (vector.dy != 0.0) {
    edgeTest = false;
    if (vector.dy > 0.0) {
      if (sides.has(math.HitRegion.YNeg)) {
        edge = math.HitRegion.YNeg;
        edgeTest = true;
        if (math.Comparer.equals(regionB.y, regionA.y + regionA.dy)) {
          d = 0.0;
        } else {
          d = (regionB.y - (regionA.y + regionA.dy)) / vector.dy;
        }
      }
    } else {
      if (sides.has(math.HitRegion.YPos)) {
        edge = math.HitRegion.YPos;
        edgeTest = true;
        if (math.Comparer.equals(regionB.y + regionB.dy, regionA.y)) {
          d = 0.0;
        } else {
          d = ((regionB.y + regionB.dy) - regionA.y) / vector.dy;
        }
      }
    }

    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final double x = regionA.x + vector.dx * d;
      if (math.rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        t = d;
        region = edge;
      }
    }
  }

  if (region == math.HitRegion.None) {
    final bool overlap = regionA.overlaps(regionB);
    final Type type = () {
      if (overlap) {
        return Type.Intesected;
      } else {
        return Type.NoCollision;
      }
    }();
    return TwoAABB2Result(type, 0.0, regionA, regionB, vecA, vecB, sidesA, sidesB, math.HitRegion.None);
  }
  return TwoAABB2Result(Type.Collision, t, regionA, regionB, vecA, vecB, sidesA, sidesB, region);
}

/// Results from an collision between two moving AABB regions.
class TwoAABB3Result extends BaseResult {
  /// The first of the two regions in the collision.
  final math.Region3 regionA;

  /// The second of the two regions in the collision.
  final math.Region3 regionB;

  /// The vector for the first region moving in the given time frame.
  final math.Vector3 vecA;

  /// The vector for the second region moving in the given time frame.
  final math.Vector3 vecB;

  /// The sides for the first region can collide on.
  final math.HitRegion sidesA;

  /// The sides for the first region can collide on.
  final math.HitRegion sidesB;

  /// The side of the target region which was hit.
  final math.HitRegion region;

  /// Creates a new collision result for collision between AABB regions.
  TwoAABB3Result(Type type, double parametric, this.regionA, this.regionB, this.vecA, this.vecB, this.sidesA,
      this.sidesB, this.region)
      : super(type, parametric);

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
TwoAABB3Result twoAABB3(math.Region3 regionA, math.Region3 regionB, math.Vector3 vecA, math.Vector3 vecB,
    [math.HitRegion? sidesA, math.HitRegion? sidesB]) {
  // ignore: parameter_assignments
  sidesA ??= math.HitRegion.All;
  // ignore: parameter_assignments
  sidesB ??= math.HitRegion.All;
  final math.HitRegion sides = sidesB & sidesA.inverse();
  final math.Vector3 vector = vecA - vecB;

  double t = 100.0, d = 0.0;
  math.HitRegion region = math.HitRegion.None, edge = math.HitRegion.None;
  bool edgeTest;

  if (vector.dx != 0.0) {
    edgeTest = false;
    if (vector.dx > 0.0) {
      if (sides.has(math.HitRegion.XNeg)) {
        edge = math.HitRegion.XNeg;
        edgeTest = true;
        if (math.Comparer.equals(regionB.x, regionA.x + regionA.dx)) {
          d = 0.0;
        } else {
          d = (regionB.x - (regionA.x + regionA.dx)) / vector.dx;
        }
      }
    } else {
      if (sides.has(math.HitRegion.XPos)) {
        edge = math.HitRegion.XPos;
        edgeTest = true;
        if (math.Comparer.equals(regionB.x + regionB.dx, regionA.x)) {
          d = 0.0;
        } else {
          d = ((regionB.x + regionB.dx) - regionA.x) / vector.dx;
        }
      }
    }

    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final double y = regionA.y + vector.dy * d;
      if (math.rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
        final double z = regionA.z + vector.dz * d;
        if (math.rangeOverlap(regionB.z, regionB.z + regionB.dz, z, z + regionA.dz)) {
          t = d;
          region = edge;
        }
      }
    }
  }

  if (vector.dy != 0.0) {
    edgeTest = false;
    if (vector.dy > 0.0) {
      if (sides.has(math.HitRegion.YNeg)) {
        edge = math.HitRegion.YNeg;
        edgeTest = true;
        if (math.Comparer.equals(regionB.y, regionA.y + regionA.dy)) {
          d = 0.0;
        } else {
          d = (regionB.y - (regionA.y + regionA.dy)) / vector.dy;
        }
      }
    } else {
      if (sides.has(math.HitRegion.YPos)) {
        edge = math.HitRegion.YPos;
        edgeTest = true;
        if (math.Comparer.equals(regionB.y + regionB.dy, regionA.y)) {
          d = 0.0;
        } else {
          d = ((regionB.y + regionB.dy) - regionA.y) / vector.dy;
        }
      }
    }

    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final double x = regionA.x + vector.dx * d;
      if (math.rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        final double z = regionA.z + vector.dz * d;
        if (math.rangeOverlap(regionB.z, regionB.z + regionB.dz, z, z + regionA.dz)) {
          t = d;
          region = edge;
        }
      }
    }
  }

  if (vector.dz != 0.0) {
    edgeTest = false;
    if (vector.dz > 0.0) {
      if (sides.has(math.HitRegion.ZNeg)) {
        edge = math.HitRegion.ZNeg;
        edgeTest = true;
        if (math.Comparer.equals(regionB.z, regionA.z + regionA.dz)) {
          d = 0.0;
        } else {
          d = (regionB.z - (regionA.z + regionA.dz)) / vector.dz;
        }
      }
    } else {
      if (sides.has(math.HitRegion.ZPos)) {
        edge = math.HitRegion.ZPos;
        edgeTest = true;
        if (math.Comparer.equals(regionB.z + regionB.dz, regionA.z)) {
          d = 0.0;
        } else {
          d = ((regionB.z + regionB.dz) - regionA.z) / vector.dz;
        }
      }
    }

    if (edgeTest && (d < t) && (d >= 0.0) && (d <= 1.0)) {
      final double x = regionA.x + vector.dx * d;
      if (math.rangeOverlap(regionB.x, regionB.x + regionB.dx, x, x + regionA.dx)) {
        final double y = regionA.y + vector.dy * d;
        if (math.rangeOverlap(regionB.y, regionB.y + regionB.dy, y, y + regionA.dy)) {
          t = d;
          region = edge;
        }
      }
    }
  }

  if (region == math.HitRegion.None) {
    final overlap = regionA.overlaps(regionB);
    final type = () {
      if (overlap) {
        return Type.Intesected;
      } else {
        return Type.NoCollision;
      }
    }();
    return TwoAABB3Result(type, 0.0, regionA, regionB, vecA, vecB, sidesA, sidesB, math.HitRegion.None);
  }
  return TwoAABB3Result(Type.Collision, t, regionA, regionB, vecA, vecB, sidesA, sidesB, region);
}

/// The results of a collision test between two spheres.
class TwoSphereResult extends BaseResult {
  /// The first sphere in this collision.
  final math.Sphere sphereA;

  /// The second sphere in this collision.
  final math.Sphere sphereB;

  /// The vector for the first sphere moving in the given time frame.
  final math.Vector3 vecA;

  /// The vector for the second sphere moving in the given time frame.
  final math.Vector3 vecB;

  /// The center point of sphere A when the collision occurred.
  /// This is null when no collision occurred.
  final math.Point3? centerA;

  /// The center point of sphere B when the collision occurred.
  /// This is null when no collision occurred.
  final math.Point3? centerB;

  /// The point on the surface of sphere A and B the collision occurred at.
  /// This is null when no collision occurred or intersected.
  final math.Point3? hitPoint;

  /// Creates a new collision result for collision between spheres.
  TwoSphereResult(Type type, double parametric, this.sphereA, this.sphereB, this.vecA, this.vecB,
      [this.centerA, this.centerB, this.hitPoint])
      : super(type, parametric);

  /// Gets the string for this collision.
  @override
  String toString() => super.toString() + (this.collided ? " ${this.centerA} ${this.centerB} ${this.hitPoint}" : "");
}

/// Tests the collision between two moving spheres.
/// The given vectors represent the constant amount of distance moved in a time span.
TwoSphereResult twoSphere(math.Sphere sphereA, math.Sphere sphereB, math.Vector3 vecA, math.Vector3 vecB) {
  final math.Point3 cA = sphereA.center;
  final math.Point3 cB = sphereB.center;
  final math.Vector3 e = cB.vectorTo(cA);
  final double r = sphereA.radius + sphereB.radius;
  final double r2 = r * r;
  final double ee = e.dot(e);
  if (ee < r2) {
    return TwoSphereResult(Type.Intesected, 0.0, sphereA, sphereB, vecA, vecB, cA, cB);
  }
  final math.Vector3 d = vecB - vecA;
  final double len = d.length();
  final math.Vector3 d2 = d.normal();
  final double ed = e.dot(d2);
  if (math.Comparer.equals(ee, r2) && (ed < 0.0)) {
    return TwoSphereResult(Type.NoCollision, 0.0, sphereA, sphereB, vecA, vecB);
  }
  final double f = ed * ed + r2 - ee;
  if (f < 0.0) {
    return TwoSphereResult(Type.NoCollision, 0.0, sphereA, sphereB, vecA, vecB);
  }
  final double t = ed - math.sqrt(f);
  if (t < 0.0) {
    return TwoSphereResult(Type.NoCollision, t, sphereA, sphereB, vecA, vecB);
  }
  if (t > len) {
    return TwoSphereResult(Type.OutOfRange, t, sphereA, sphereB, vecA, vecB);
  }

  final double t2 = t / len;
  final math.Point3 cA2 = math.Point3(sphereA.x + vecA.dx * t2, sphereA.y + vecA.dy * t2, sphereA.z + vecA.dz * t2);
  final math.Point3 cB2 = math.Point3(sphereB.x + vecB.dx * t2, sphereB.y + vecB.dy * t2, sphereB.z + vecB.dz * t2);
  final double scalar = sphereA.radius / math.sqrt(ee);
  final math.Point3 hit =
      math.Point3((cB2.x - cA2.x) * scalar + cA2.x, (cB2.y - cA2.y) * scalar + cA2.y, (cB2.z - cA2.z) * scalar + cA2.z);
  return TwoSphereResult(Type.Collision, t, sphereA, sphereB, vecA, vecB, cA2, cB2, hit);
}
