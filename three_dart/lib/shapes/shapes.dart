// Shapes describes the geometry of an entity being rendered.
//
// The shape is defined as a set of vertices and renderable elements.
// The vertices are the location and additional rendering information such as
// the texture coordinates, normals, binormals, etc.. The renderable elements
// are points, lines, and faces. The point indicates that a vertex should be
// drawn. The line joins two vertices to draw a line. The face joins three
// points into a filled triangle. The face contains additional information
// such as the normals and binormals of a face. The order of the vertices
// also defines the winding, clockwise or counter-clockwise, of a face.
//
// ## Calculating Face Binormals
//
// ![Image of Location and Texture Coordinate Systems for Calculating Binormals](../../../resources/Binormal.png)
//
// Given:
//
// ```None
// P1 = <x1, y1, z1, u1, v1>
// P2 = <x2, y2, z2, u2, v2>
// P3 = <x3, y3, z3, u3, v3>
// ```
//
// Try to solve for:
//
// ```None
// P4 = <x4, y4, z4, u4, v4>
// ```
//
// Solving using the two-line intersection equation,
// Where the first line, `A`, is `<u2, v2, u3, v3>`,
// And the second line, `B`, is `<u1, v1, u1+1, v1>`:
//
// ```None
// dAu = u3 - u2
// dAv = v3 - v2
// dBu = u1+1 - u1 = 1
// dBv = v1 - v1 = 0
// det = (dAu * dBv) - (dAv * dBu)
//     = 0*(u3 - u2) - 1*(v3 - v2)
//     = v2 - v3
// ```
//
// if `det` is equal to zero then
// `Bn = |P3 - P2|` if `dAu > 0` or
// `Bn = |P2 - P3|` if `dAu < 0`
// else
//
// ```None
// dABu = u2 - u1`
// dABv = v2 - v1`
// num = (dABv * dBu) - (dABu * dBv)`
//     = 1*(v2 - v1) - 0*(u2 - u1)`
//     = v2 - v1`
// r = num / det`
//   = (v2 - v1) / (v2 - v3)
// ```
//
// Use the Bezier linear factor, `r`, to calculate all values of `P4`:
//
// ```None
// P4' = P2 + r*(P3-P2)
// ```
//
// The point of intersection may have been behind the initial point,
// therefore if `u4 - u1 < 0` then use `Bn = |P3 - P4|`
// else `Bn = |P4 - P3|`.
import 'dart:math';
import 'dart:typed_data' as typed;
import 'dart:web_gl' as webgl;

import '../data/data.dart';
import '../events/events.dart';
import '../math/math.dart';
import '../textures/textures.dart';

/// A function handler for processing a single value for a new value.
typedef func1Handle = double Function(double a);

/// A function handler for processing two values for a new value.
typedef func2Handle = double Function(double a, double b);

/// A function handler for processing a single value for a new 3D point.
typedef func1PntHandle = Point3 Function(double a);

/// A function handler for processing two values for a new 3D point.
typedef func2PntHandle = Point3 Function(double a, double b);

/// A function handler for processing two values for a new vertex.
typedef ver2Handle = void Function(Vertex ver, double a, double b);

/// Creates a simple line shape.
Shape line({VertexType? type}) {
  final Shape shape = Shape();
  final Vertex ver1 = shape.vertices.addNew(
      type: type,
      loc: Point3(-1.0, 0.0, 0.0),
      txt2D: Point2.zero,
      txtCube: Vector3(-1.0, -1.0, 0.0).normal(),
      clr: Colors.red,
      bending: Point4(1.0, 2.0, 4.0, 6.0));

  final Vertex ver2 = shape.vertices.addNew(
      type: type,
      loc: Point3(1.0, 0.0, 0.0),
      txt2D: Point2(1.0, 0.0),
      txtCube: Vector3(1.0, -1.0, 0.0).normal(),
      clr: Colors.blue,
      bending: Point4(0.0, 3.0, 4.0, 6.0));

  shape.lines.add(ver1, ver2);
  return shape;
}

/// Creates a square shape.
Shape square(
    {double width = 2.0, double height = 2.0, double zOffset = 0.0, VertexType? type, bool frameOnly = false}) {
  final Shape shape = Shape();
  final Vertex ver1 = shape.vertices.addNew(
      type: type,
      loc: Point3(-width * 0.5, -height * 0.5, zOffset),
      txt2D: Point2(0.0, 1.0),
      txtCube: Vector3(-1.0, -1.0, 1.0).normal(),
      clr: Colors.red,
      bending: Point4(1.0, 2.0, 4.0, 6.0));

  final Vertex ver2 = shape.vertices.addNew(
      type: type,
      loc: Point3(width * 0.5, -height * 0.5, zOffset),
      txt2D: Point2(1.0, 1.0),
      txtCube: Vector3(1.0, -1.0, 1.0).normal(),
      clr: Colors.blue,
      bending: Point4(0.0, 3.0, 4.0, 6.0));

  final Vertex ver3 = shape.vertices.addNew(
      type: type,
      loc: Point3(width * 0.5, height * 0.5, zOffset),
      txt2D: Point2(1.0, 0.0),
      txtCube: Vector3(1.0, 1.0, 1.0).normal(),
      clr: Colors.green,
      bending: Point4(0.0, 2.0, 5.0, 6.0));

  final Vertex ver4 = shape.vertices.addNew(
      type: type,
      loc: Point3(-width * 0.5, height * 0.5, zOffset),
      txt2D: Point2.zero,
      txtCube: Vector3(-1.0, 1.0, 1.0).normal(),
      clr: Colors.yellow,
      bending: Point4(0.0, 2.0, 4.0, 7.0));

  if (frameOnly) {
    shape.lines.addLoop([ver1, ver2, ver3, ver4]);
  } else {
    shape.faces.addFan([ver1, ver2, ver3, ver4]);
  }
  shape.calculateNormals();
  return shape;
}

/// Creates a cube shape.
Shape cube({VertexType? type}) => cuboid(type: type, widthDiv: 1, heightDiv: 1);

/// Creates a cuboid shape designed for cube texturing using six grids.
/// The [widthDiv] and [heightDiv] define the divisions of the grids used.
/// The [vertexHndl] added addition height to the sides.
Shape cuboid({VertexType? type, int widthDiv = 8, int heightDiv = 8, ver2Handle? vertexHndl}) {
  final Shape shape = Shape();
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, 1.0, 0.0, 0.0, 1);
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, 0.0, 1.0, 0.0, 3);
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, 0.0, 0.0, 1.0, 2);
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, -1.0, 0.0, 0.0, 0);
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, 0.0, -1.0, 0.0, 0);
  _addCuboidSide(shape, type, vertexHndl, widthDiv, heightDiv, 0.0, 0.0, -1.0, 3);
  shape.calculateNormals();
  return shape;
}

// Determines the bend index for the cuboid corner vector.
double _cornerBendIndex(Vector3 vec) {
  int index = 0;
  if (vec.dx > 0.0) index++;
  if (vec.dy > 0.0) index += 2;
  if (vec.dz > 0.0) index += 4;
  return index * 2.0;
}

/// Adds a cuboid side to a cube [shape] given the normal direction of the side's plain.
void _addCuboidSide(Shape shape, VertexType? type, ver2Handle? vertexHndl, int widthDiv, int heightDiv, double nx,
    double ny, double nz, int rotate) {
  Vector3 vec1 = Vector3(nx + ny + nz, ny + nz + nx, nz + nx + ny);
  Vector3 vec2 = Vector3(nx - ny + nz, ny - nz + nx, nz - nx + ny);
  Vector3 vec3 = Vector3(nx - ny - nz, ny - nz - nx, nz - nx - ny);
  Vector3 vec4 = Vector3(nx + ny - nz, ny + nz - nx, nz + nx - ny);
  if (nx + ny + nz > 0.0) {
    final Vector3 t = vec4;
    vec4 = vec2;
    vec2 = t;
  }
  for (int i = 0; i < rotate; i++) {
    final Vector3 t = vec1;
    vec1 = vec2;
    vec2 = vec3;
    vec3 = vec4;
    vec4 = t;
  }
  final double index1 = _cornerBendIndex(vec1);
  final double index2 = _cornerBendIndex(vec2);
  final double index3 = _cornerBendIndex(vec3);
  final double index4 = _cornerBendIndex(vec4);
  final Shape face = surface(widthDiv, heightDiv, (Vertex ver, double u, double v) {
    final Vector3 vec5 = vec1.lerp(vec2, u);
    final Vector3 vec6 = vec4.lerp(vec3, u);
    final Vector3 vec7 = vec5.lerp(vec6, v);
    ver.location = Point3.fromVector3(vec7);
    ver.textureCube = vec7.normal();
    ver.bending =
        Point4(index3 + u * v, index4 + (1.0 - u) * v, index2 + u * (1.0 - v), index1 + (1.0 - u) * (1.0 - v));
    if (vertexHndl != null) vertexHndl(ver, u, v);
  }, type);
  // ignore: unnecessary_null_comparison
  if (face != null) shape.merge(face);
}

/// Creates a disk shape.
/// [sides] is the number of division on the side, and [height] is the y offset of the disk.
/// [flip] will flip the disk over, and [radiusHndl] is a handle for custom variant radius.
Shape disk(
    {int sides = 8,
    double height = 0.0,
    bool flip = false,
    double bending = -1.0,
    func1Handle? radiusHndl,
    bool frameOnly = false}) {
  radiusHndl ??= (double a) => 1.0;
  if (sides < 3) throw Exception('Must have 3 or more sizes for a disk.');
  final Shape shape = Shape();
  final double sign = () {
    if (flip) {
      return -1.0;
    } else {
      return 1.0;
    }
  }();
  final double step = -2.0 * PI / sides.toDouble();
  final List<Vertex> vers = [];
  if (!frameOnly) {
    vers.add(shape.vertices.addNew(
        loc: Point3(0.0, 0.0, height),
        norm: Vector3(0.0, 0.0, sign),
        txt2D: Point2(0.5, 0.5),
        txtCube: Vector3(0.0, 0.0, sign).normal(),
        clr: Color4.white(),
        bending: Point4(bending, -1.0, -1.0, -1.0)));
  }
  for (int i = 0; i <= sides; i++) {
    final double angle = step * i.toDouble();
    final x = sign * sin(angle), y = cos(angle);
    final double radius = radiusHndl(i.toDouble() / sides.toDouble());
    vers.add(shape.vertices.addNew(
        loc: Point3(x * radius, y * radius, height),
        norm: Vector3(0.0, 0.0, sign),
        txt2D: Point2(x * 0.5 + 0.5, y * 0.5 + 0.5),
        txtCube: Vector3(x, y, sign).normal(),
        clr: Color4(x, y, y),
        bending: Point4(bending, -1.0, -1.0, -1.0)));
  }
  if (frameOnly) {
    shape.lines.addLoop(vers);
  } else {
    shape.faces.addFan(vers);
  }
  return shape;
}

/// Creates a cylinder shape.
/// [sides] is the number of division on the side, [div] is the number of
/// divisions to cut the cylinder. [capTop] and [capBottom] indicated if a
/// top or bottom respectively should be covered with a disk. The [topRadius]
/// and [bottomRadius] are the top and bottom radii respectively.
Shape cylinder(
    {double topRadius = 1.0,
    double bottomRadius = 1.0,
    int sides = 8,
    int div = 1,
    bool capTop = true,
    bool capBottom = true}) {
  return cylindrical(
      sides: sides,
      div: div,
      capTop: capTop,
      capBottom: capBottom,
      radiusHndl: (double _, double v) => lerpVal(bottomRadius, topRadius, v));
}

/// Creates a cylindrical shape.
/// [sides] is the number of division on the side, [div] is the number of
/// divisions to cut the cylinder. [capTop] and [capBottom] indicated if a
/// top or bottom respectively should be covered with a disk.
/// [radiusHndl] is the handle to specify the custom radius of the cylindrical shape.
Shape cylindrical({func2Handle? radiusHndl, int sides = 8, int div = 1, bool capTop = true, bool capBottom = true}) {
  if (sides < 3) throw Exception('Must have 3 or more sizes for a cylindrical shape.');
  if (div < 1) throw Exception('Must have 1 or more divisionss for a cylindrical shape.');
  final func2Handle hndl = radiusHndl ?? (double u, double v) => 1.0;
  final Shape shape = surface(div, sides, (Vertex ver, double u, double v) {
    final double angle = 2.0 * PI * u;
    final x = -sin(angle), y = cos(angle);
    final double z = lerpVal(-1.0, 1.0, v);
    final double radius = hndl(u, v);
    ver.location = Point3(x * radius, y * radius, z);
    ver.textureCube = Vector3(x * radius, y * radius, z).normal();
    ver.bending = Point4(1.0 - v, 2.0 + v, -1.0, -1.0);
  });
  shape.calculateNormals();
  shape.adjustNormals();
  if (capTop) {
    final Shape top =
        disk(sides: sides, height: 1.0, flip: false, bending: 3.0, radiusHndl: (double u) => hndl(u, 1.0));
    shape.merge(top);
  }
  if (capBottom) {
    final Shape bottom =
        disk(sides: sides, height: -1.0, flip: true, bending: 1.0, radiusHndl: (double u) => hndl(1.0 - u, 0.0));
    shape.merge(bottom);
  }
  return shape;
}

/// Creates a sphere shape constructed as from a latitude and longitude grid.
/// The [latitudeDiv] is the number of latitude divisions and
/// the [longitudeDiv] is the number of longitude divisions.
Shape latLonSphere([int latitudeDiv = 12, int longitudeDiv = 24]) {
  final Shape shape = surface(latitudeDiv, longitudeDiv, (Vertex ver, double u, double v) {
    final double r = sin(v * PI);
    final Vector3 vec = Vector3(cos(u * TAU) * r, cos(v * PI), sin(u * TAU) * r);
    ver.location = Point3.fromVector3(vec.normal());
  });
  shape.faces.removeCollapsed();
  shape.calculateNormals();
  shape.adjustNormals();
  return shape;
}

/// Creates a sphere shape fractally with the given number of [iterations].
Shape isosphere([int iterations = 3]) {
  final Shape shape = Shape();
  // Create 12 vertices of a icosahedron.
  final t = sqrt(5.0) / 2.0 + 0.5;
  final Vertex ver0 = _isosphereAdd(shape, Vector3(-1.0, t, 0.0));
  final Vertex ver1 = _isosphereAdd(shape, Vector3(1.0, t, 0.0));
  final Vertex ver2 = _isosphereAdd(shape, Vector3(-1.0, -t, 0.0));
  final Vertex ver3 = _isosphereAdd(shape, Vector3(1.0, -t, 0.0));

  final Vertex ver4 = _isosphereAdd(shape, Vector3(0.0, -1.0, -t));
  final Vertex ver5 = _isosphereAdd(shape, Vector3(0.0, 1.0, -t));
  final Vertex ver6 = _isosphereAdd(shape, Vector3(0.0, -1.0, t));
  final Vertex ver7 = _isosphereAdd(shape, Vector3(0.0, 1.0, t));

  final Vertex ver8 = _isosphereAdd(shape, Vector3(t, 0.0, 1.0));
  final Vertex ver9 = _isosphereAdd(shape, Vector3(t, 0.0, -1.0));
  final Vertex ver10 = _isosphereAdd(shape, Vector3(-t, 0.0, 1.0));
  final Vertex ver11 = _isosphereAdd(shape, Vector3(-t, 0.0, -1.0));

  _isoSphereDiv(shape, ver0, ver11, ver5, iterations);
  _isoSphereDiv(shape, ver0, ver5, ver1, iterations);
  _isoSphereDiv(shape, ver0, ver1, ver7, iterations);
  _isoSphereDiv(shape, ver0, ver7, ver10, iterations);
  _isoSphereDiv(shape, ver0, ver10, ver11, iterations);

  _isoSphereDiv(shape, ver1, ver5, ver9, iterations);
  _isoSphereDiv(shape, ver5, ver11, ver4, iterations);
  _isoSphereDiv(shape, ver11, ver10, ver2, iterations);
  _isoSphereDiv(shape, ver10, ver7, ver6, iterations);
  _isoSphereDiv(shape, ver7, ver1, ver8, iterations);

  _isoSphereDiv(shape, ver3, ver9, ver4, iterations);
  _isoSphereDiv(shape, ver3, ver4, ver2, iterations);
  _isoSphereDiv(shape, ver3, ver2, ver6, iterations);
  _isoSphereDiv(shape, ver3, ver6, ver8, iterations);
  _isoSphereDiv(shape, ver3, ver8, ver9, iterations);

  _isoSphereDiv(shape, ver4, ver9, ver5, iterations);
  _isoSphereDiv(shape, ver2, ver4, ver11, iterations);
  _isoSphereDiv(shape, ver6, ver2, ver10, iterations);
  _isoSphereDiv(shape, ver8, ver6, ver7, iterations);
  _isoSphereDiv(shape, ver9, ver8, ver1, iterations);

  shape.joinSeams();
  return shape;
}

/// Adds a vertex to the isophere [shape] with the normal towards the point.
Vertex _isosphereAdd(Shape shape, Vector3 norm) {
  // ignore: parameter_assignments
  norm = norm.normal();
  final Vertex ver = Vertex(loc: Point3.fromVector3(norm), norm: norm);
  final Vertex? last = shape.findFirst(ver, VertexLocationMatcher());
  if (last != null) return last;
  ver.color = Color4(norm.dx * 0.5 + 0.5, norm.dy * 0.5 + 0.5, norm.dz * 0.5 + 0.5);
  final double w = sqrt(norm.dx * norm.dx + norm.dy * norm.dy);
  double tu = atan2(norm.dy, norm.dx) / PI_2;
  if (tu < 0) tu = -tu;
  double tv = atan2(w, norm.dz) / PI;
  if (tv < 0) tv = -tv;
  ver.texture2D = Point2(tu, tv);
  shape.vertices.add(ver);
  return ver;
}

/// Iterates an isosphere side by fractally dividing the triangle.
void _isoSphereDiv(Shape shape, Vertex ver1, Vertex ver2, Vertex ver3, int iteration) {
  //         2                  2
  //         .                  .
  //        / \                / \
  //       /   \              /B  \
  //      /     \     =>   4 /_____\ 5
  //     /       \          /\ C  / \
  //    /         \        /A \  /D  \
  //   /___________\      /____\/_____\
  //  1             3    1      6      3
  if (iteration <= 0) {
    shape.faces.add(ver1, ver3, ver2);
  } else {
    final Vector3 norm1 = ver1.normal ?? Vector3.posZ;
    final Vector3 norm2 = ver2.normal ?? Vector3.posZ;
    final Vector3 norm3 = ver3.normal ?? Vector3.posZ;
    final Vertex ver4 = _isosphereAdd(shape, (norm1 + norm2) * 0.5);
    final Vertex ver5 = _isosphereAdd(shape, (norm2 + norm3) * 0.5);
    final Vertex ver6 = _isosphereAdd(shape, (norm3 + norm1) * 0.5);
    _isoSphereDiv(shape, ver1, ver4, ver6, iteration - 1); // A
    _isoSphereDiv(shape, ver4, ver2, ver5, iteration - 1); // B
    _isoSphereDiv(shape, ver5, ver6, ver4, iteration - 1); // C
    _isoSphereDiv(shape, ver6, ver5, ver3, iteration - 1); // D
  }
}

/// Creates a sphere shape designed for smooth cube texturing using six grids.
/// The [widthDiv] and [heightDiv] define the divisions of the grids used.
/// The [heightHndl] added addition height to the curved grid.
Shape sphere({double radius = 1.0, int widthDiv = 8, int heightDiv = 8, func2Handle? heightHndl}) {
  final func2Handle hndl = heightHndl ?? (double a, double b) => 0.0;
  final Shape shape = cuboid(
      widthDiv: widthDiv,
      heightDiv: heightDiv,
      vertexHndl: (Vertex ver, double u, double v) {
        final double height = radius + hndl(u, v);
        final Point3? loc = ver.location;
        final Vector3 vec = () {
          if (loc != null) {
            return Vector3.fromPoint3(loc);
          } else {
            return Vector3.posZ;
          }
        }();
        ver.location = Point3.fromVector3(vec.normal() * height);
      });
  shape.adjustNormals();
  return shape;
}

/// Creates a toroid shape.
/// The major values are the divisions and radius from the center of the shape.
/// The minor values are the divisions and radius of the outer ring.
Shape toroid({double minorRadius = 0.5, double majorRadius = 1.0, int minorCount = 15, int majorCount = 30}) {
  return cylindricalPath(minorCount, majorCount, minorRadius, majorRadius, (double t) {
    return Point3(cos(t), sin(t), 0.0);
  });
}

/// Creates a toroidal knot shape. This is similar to a toroid except
/// the number of full rotations in the major and minor angles may be modified.
Shape knot({
  final int minorCount = 12,
  final int majorCount = 120,
  final double minorRadius = 0.3,
  final double majorRadius = 1.0,
  final double minorTurns = 3.0,
  final double majorTurns = 2.0,
}) =>
    cylindricalPath(
      minorCount,
      majorCount,
      minorRadius,
      majorRadius,
      (double t) {
        final double scalar = 2.0 + cos(minorTurns * t);
        return Point3(
          scalar * cos(majorTurns * t) / 2.0,
          scalar * sin(majorTurns * t) / 2.0,
          sin(minorTurns * t) / 2.0,
        );
      },
    );

/// Creates a cylindrical path is a bendable cylinder with no caps.
Shape cylindricalPath(int minorCount, int majorCount, double minorRadius, double majorRadius, func1PntHandle pathHndl) {
  final Shape shape = surface(minorCount, majorCount, (Vertex ver, double u, double v) {
    final double majorAngle = u * TAU;
    final Point3 cur = pathHndl(majorAngle) * majorRadius;
    final Point3 next = pathHndl(majorAngle + PI / majorCount) * majorRadius;
    final Vector3 heading = Vector3.fromPoint3(next - cur).normal();
    Vector3 other = Vector3.posX;
    if (heading != other) {
      other = Vector3.posZ;
    }
    final Vector3 cross = heading.cross(other).normal();
    other = cross.cross(heading).normal();
    final minorAngle = v * TAU;
    final minorCos = cos(minorAngle) * minorRadius;
    final minorSin = sin(minorAngle) * minorRadius;
    ver.location = cur + Point3.fromVector3(other * minorCos - cross * minorSin);
  });
  shape.calculateNormals();
  shape.adjustNormals();
  return shape;
}

/// Creates a flat grid shape with an option custom [heightHndl].
Shape grid({int widthDiv = 4, int heightDiv = 4, func2Handle? heightHndl}) {
  final func2Handle hndl = heightHndl ?? (double u, double v) => 0.0;
  return surface(
    widthDiv,
    heightDiv,
    (Vertex ver, double u, double v) {
      final double x = u * 2.0 - 1.0;
      final double y = v * 2.0 - 1.0;
      ver.location = Point3(x, y, hndl(u, v));
      ver.textureCube = Vector3(x, y, 1.0).normal();
      ver.bending = Point4(u * v, 2.0 + (1.0 - u) * v, 4.0 + u * (1.0 - v), 6.0 + (1.0 - u) * (1.0 - v));
    },
  );
}

/// Creates a grid surface which can be bent and twisted with the given [vertexHndl].
Shape surface(int widthDiv, int heightDiv, ver2Handle vertexHndl, [VertexType? type]) {
  if (widthDiv < 1) throw Exception('Must have 1 or more divisions of the width for a surface.');
  if (heightDiv < 1) throw Exception('Must have 1 or more divisions of the height for a surface.');
  final Shape shape = Shape();
  final List<Vertex> vers = [];
  for (int i = 0; i <= heightDiv; i++) {
    final double u = i.toDouble() / heightDiv.toDouble();
    final Vertex ver = shape.vertices.addNew(txt2D: Point2(u, 1.0), clr: Color4(u, 0.0, 0.0));
    vertexHndl(ver, u, 0.0);
    vers.add(ver.copy(type));
  }
  for (int i = 1; i <= widthDiv; i++) {
    final double v = i.toDouble() / widthDiv.toDouble();
    for (int j = 0; j <= heightDiv; j++) {
      final double u = j.toDouble() / heightDiv.toDouble();
      final Vertex ver = shape.vertices.addNew(txt2D: Point2(u, 1.0 - v), clr: Color4(u, v, v));
      vertexHndl(ver, u, v);
      vers.add(ver.copy(type));
    }
  }
  shape.faces.addGrid(widthDiv + 1, heightDiv + 1, vers);
  return shape;
}

/// A face is a filled triangle defined by three vertices.
class Face {
  Vertex? _ver1;
  Vertex? _ver2;
  Vertex? _ver3;

  Vector3? _norm;
  Vector3? _binm;

  /// Creates a new face with the given vertices.
  Face(Vertex? ver1, Vertex? ver2, Vertex? ver3) {
    if (ver1 == null) throw Exception("May not create a face with a null first vertex.");
    if (ver2 == null) throw Exception("May not create a face with a null second vertex.");
    if (ver3 == null) throw Exception("May not create a face with a null third vertex.");
    if (ver1.shape == null) {
      throw Exception("May not create a face with a first vertex which is not attached to a shape.");
    }
    if ((ver1.shape != ver2.shape) || (ver1.shape != ver3.shape)) {
      throw Exception("May not create a face with vertices attached to different shapes.");
    }
    this._norm = null;
    this._binm = null;
    this._setVertex1(ver1);
    this._setVertex2(ver2);
    this._setVertex3(ver3);
    this._ver1?.shape?.faces._faces.add(this);
    this._ver1?.shape?.onFaceAdded(this);
  }

  /// Disposes this face.
  void dispose() {
    if (!this.disposed) {
      this._ver1?.shape?.faces._faces.remove(this);
      this._ver1?.shape?.onFaceRemoved(this);
    }
    this._removeVertex1();
    this._removeVertex2();
    this._removeVertex3();
  }

  /// Trims all the faces down have the true values,
  /// everything else is nulled out.
  void trim({bool norm = true, bool binm = true}) {
    if (!norm) this._norm = null;
    if (!binm) this._binm = null;
  }

  /// Sets the first vertex to the given value.
  void _setVertex1(Vertex? ver1) {
    this._ver1 = ver1;
    this._ver1?.faces._faces1.add(this);
  }

  /// Sets the second vertex to the given value.
  void _setVertex2(Vertex? ver2) {
    this._ver2 = ver2;
    this._ver2?.faces._faces2.add(this);
  }

  /// Sets the third vertex to the given value.
  void _setVertex3(Vertex? ver3) {
    this._ver3 = ver3;
    this._ver3?.faces._faces3.add(this);
  }

  /// Removes the first vertex.
  void _removeVertex1() {
    this._ver1?.faces._faces1.remove(this);
    this._ver1 = null;
  }

  /// Removes the second vertex.
  void _removeVertex2() {
    this._ver2?.faces._faces2.remove(this);
    this._ver2 = null;
  }

  /// Removes the third vertex.
  void _removeVertex3() {
    this._ver3?.faces._faces3.remove(this);
    this._ver3 = null;
  }

  /// Indicates if the face is disposed or not.
  bool get disposed => (this._ver1 == null) || (this._ver2 == null) || (this._ver3 == null);

  /// The first vertex of the face.
  Vertex? get vertex1 => this._ver1;

  /// The second vertex of the face.
  Vertex? get vertex2 => this._ver2;

  /// The third vertex of the face.
  Vertex? get vertex3 => this._ver3;

  /// The normal for this face or null if not specified yet.
  Vector3? get normal => this._norm;

  set normal(Vector3? norm) => this._norm = norm?.normal();

  /// The binormal for this face or null if not specified yet.
  Vector3? get binormal => this._binm;

  set binormal(Vector3? binm) => this._binm = binm?.normal();

  /// Calculates the normal vector from the average of the vertex normals.
  /// Returns null if not all vertices have normals.
  Vector3? _averageNormal() {
    final Vector3? norm1 = this._ver1?.normal;
    final Vector3? norm2 = this._ver2?.normal;
    final Vector3? norm3 = this._ver3?.normal;
    Vector3? sum = Vector3.zero;
    if (norm1 != null) sum += norm1;
    if (norm2 != null) sum += norm2;
    if (norm3 != null) sum += norm3;
    if (sum.isZero()) return null;
    return sum.normal();
  }

  /// Calculates the normal vector from the cross product of locations.
  /// Returns null if not all vertices have locations.
  Vector3? _calcNormal() {
    final Point3? loc1 = this._ver1?.location;
    final Point3? loc2 = this._ver2?.location;
    final Point3? loc3 = this._ver3?.location;
    if ((loc1 == null) || (loc2 == null) || (loc3 == null)) return null;

    final Vector3 vec1 = Vector3.fromPoint3(loc2 - loc1).normal();
    final Vector3 vec2 = Vector3.fromPoint3(loc3 - loc1).normal();
    return vec1.cross(vec2).normal();
  }

  /// Calculates the normal vector if not already set.
  /// This uses the locations of the vertices to determine the normal
  /// of the plane this face lays on.
  bool calculateNormal() {
    if (this._norm != null) return true;
    Vector3? norm = this._averageNormal();
    if (norm == null) {
      norm = this._calcNormal();
      if (norm == null) return false;
    }
    this._norm = norm;
    this._ver1?.shape?.onFaceModified(this);
    return true;
  }

  /// Calculates the binormal vector from the average of the vertex binormals.
  /// Returns null if not all vertices have binormals.
  Vector3? _averageBinormal() {
    final Vector3? binm1 = this._ver1?.binormal;
    final Vector3? binm2 = this._ver2?.binormal;
    final Vector3? binm3 = this._ver3?.binormal;
    Vector3? sum = Vector3.zero;
    if (binm1 != null) sum += binm1;
    if (binm2 != null) sum += binm2;
    if (binm3 != null) sum += binm3;
    if (sum.isZero()) return null;
    return sum.normal();
  }

  /// Calculates the binormal vector from the location and texture values.
  /// Returns null if not all vertices have location and texture values.
  Vector3? _calcBinormal() {
    final Point3? loc1 = this._ver1?.location;
    final Point3? loc2 = this._ver2?.location;
    final Point3? loc3 = this._ver3?.location;
    if ((loc1 == null) || (loc2 == null) || (loc3 == null)) return null;

    final Point2? txt1 = this._ver1?.texture2D;
    final Point2? txt2 = this._ver2?.texture2D;
    final Point2? txt3 = this._ver3?.texture2D;
    if ((txt1 == null) || (txt2 == null) || (txt3 == null)) return null;

    Vector3 binm;
    final double du = txt2.y - txt3.y;
    if (Comparer.equals(du, 0.0)) {
      binm = Vector3.fromPoint3(loc3 - loc2).normal();
      if (txt3.x - txt2.x < 0.0) binm = -binm;
    } else {
      final double r = (txt2.y - txt1.y) / du;
      final Point3 vD = (loc3 - loc2) * r + loc2;
      binm = Vector3.fromPoint3(vD - loc1).normal();
      final double u4 = (txt3.x - txt2.x) * r + txt2.x - txt1.x;
      if (u4 < 0.0) binm = -binm;
    }

    var norm = this._norm;
    if (norm != null) {
      norm = norm.normal();
      final Vector3 trnm = norm.cross(binm).normal();
      binm = trnm.cross(norm).normal();
    }
    return binm;
  }

  /// Calculates the binormal vector if not already set.
  /// This requires the normal and texture location.
  /// See Shapes/README.md for more information.
  bool calculateBinormal() {
    if (this._binm != null) return true;
    Vector3? binm = this._averageBinormal();
    if (binm == null) {
      binm = this._calcBinormal();
      if (binm == null) return false;
    }
    this._binm = binm;
    this._ver1?.shape?.onFaceModified(this);
    return true;
  }

  /// Checks if the given vertex can be replaced by the new given vertex.
  /// If there is any reason it can't and exception is thrown.
  void _checkReplaceVertex(Vertex? oldVer, Vertex? newVer) {
    if (newVer == null) throw Exception("May not replace a face's vertex with a null vertex.");
    if (newVer.shape == null) {
      throw Exception("May not replace a face's vertex with a vertex which is not attached to a shape.");
    }
    if (oldVer?.shape != newVer.shape) {
      throw Exception("May not replace a face's vertex with a vertex attached to a different shape.");
    }
  }

  /// Replaces the given old vertex with the given new vertex if this face contains
  /// the given old vertex. It returns the number of vertices which were replaced.
  int replaceVertex(Vertex? oldVer, Vertex? newVer) {
    if (this.disposed) throw Exception("May not replace a face's vertex when the point has been disposed.");
    int result = 0;
    if (this._ver1 == oldVer) {
      this._checkReplaceVertex(oldVer, newVer);
      this._removeVertex1();
      this._setVertex1(newVer);
      ++result;
    }
    if (this._ver2 == oldVer) {
      this._checkReplaceVertex(oldVer, newVer);
      this._removeVertex2();
      this._setVertex2(newVer);
      ++result;
    }
    if (this._ver3 == oldVer) {
      this._checkReplaceVertex(oldVer, newVer);
      this._removeVertex3();
      this._setVertex3(newVer);
      ++result;
    }
    if (result > 0) this._ver1?.shape?.onFaceModified(this);
    return result;
  }

  /// Swaps the second and third vertices so the face is wraps the other direction.
  /// Both the normal and binormal vectors are negated if the exist.
  void flip() {
    final Vertex? ver = this._ver2;
    this._ver2 = this._ver3;
    this._ver3 = ver;
    final norm = this._norm;
    if (norm != null) this._norm = -norm;
    final binm = this._binm;
    if (binm != null) this._binm = -binm;
    this._ver1?.shape?.onFaceModified(this);
  }

  /// Indicates if the face is collapsed meaning two or
  /// more of its vertices are the same.
  bool get collapsed {
    if (this._ver1 == this._ver2) return true;
    if (this._ver2 == this._ver3) return true;
    if (this._ver3 == this._ver1) return true;
    return false;
  }

  /// Determines if the given [other] is a face with the
  /// same vertices and vectors as this face.
  bool same(Object other) {
    if (identical(this, other)) return true;
    if (other is! Face) return false;
    if (this._ver1 != other._ver1) return false;
    if (this._ver2 != other._ver2) return false;
    if (this._ver3 != other._ver3) return false;
    if (this._norm != other._norm) return false;
    if (this._binm != other._binm) return false;
    return true;
  }

  /// Gets the string for this face.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this face.
  /// The [indent] is added to the front when provided.
  String format([String indent = ""]) {
    if (this.disposed) return "${indent}disposed";
    String result = indent +
        formatInt(this._ver1?.index ?? -1) +
        ', ' +
        formatInt(this._ver2?.index ?? -1) +
        ', ' +
        formatInt(this._ver3?.index ?? -1) +
        ' {';
    result += (this._norm?.toString() ?? '-') + ', ';
    result += (this._binm?.toString() ?? '-') + '}';
    return result;
  }
}

/// A matcher used to match faces.
abstract class FaceMatcher {
  /// Determines if the two given faces match, true, or not, false.
  bool matches(Face? f1, Face? f2);
}

/// A face matcher which matches only identical instances of faces.
class ExactFaceMatcher extends FaceMatcher {
  /// Returns true if [f1] is [f2], false otherwise.
  @override
  bool matches(Face? f1, Face? f2) => identical(f1, f2);
}

/// A face matcher which matches faces which have the same
/// three vertices and are wrapped the same direction.
class SimilarFaceMatcher extends FaceMatcher {
  /// Returns true if the faces share the same vertices and
  /// face the same direction, false otherwise.
  @override
  bool matches(Face? f1, Face? f2) {
    if (f1 == null) return false;
    if (f2 == null) return false;
    if (f1.vertex1?.index == f2.vertex1?.index) {
      return (f1.vertex2?.index == f2.vertex2?.index) && (f1.vertex3?.index == f2.vertex3?.index);
    } else if (f1.vertex1?.index == f2.vertex2?.index) {
      return (f1.vertex2?.index == f2.vertex3?.index) && (f1.vertex3?.index == f2.vertex1?.index);
    } else if (f1.vertex1?.index == f2.vertex3?.index) {
      return (f1.vertex2?.index == f2.vertex1?.index) && (f1.vertex3?.index == f2.vertex2?.index);
    } else {
      return false;
    }
  }
}

/// A face matcher which matches faces which have the same
/// three vertices but the wrapped direction doesn't matter.
class UnculledFaceMatcher extends FaceMatcher {
  /// Returns true if the faces share the same vertices, false otherwise.
  @override
  bool matches(Face? f1, Face? f2) {
    if (f1 == null) return false;
    if (f2 == null) return false;
    if (f1.vertex1?.index == f2.vertex1?.index) {
      if (f1.vertex2?.index == f2.vertex2?.index) {
        return f1.vertex3?.index == f2.vertex3?.index;
      } else if (f1.vertex2?.index == f2.vertex3?.index) {
        return f1.vertex3?.index == f2.vertex2?.index;
      } else {
        return false;
      }
    } else if (f1.vertex1?.index == f2.vertex2?.index) {
      if (f1.vertex2?.index == f2.vertex3?.index) {
        return f1.vertex3?.index == f2.vertex1?.index;
      } else if (f1.vertex2?.index == f2.vertex1?.index) {
        return f1.vertex3?.index == f2.vertex3?.index;
      } else {
        return false;
      }
    } else if (f1.vertex1?.index == f2.vertex3?.index) {
      if (f1.vertex2?.index == f2.vertex1?.index) {
        return f1.vertex3?.index == f2.vertex2?.index;
      } else if (f1.vertex2?.index == f2.vertex2?.index) {
        return f1.vertex3?.index == f2.vertex1?.index;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

/// A line is an render element between to two vertices.
class Line {
  Vertex? _ver1;
  Vertex? _ver2;

  /// Creates a new line between the two given vertices.
  Line(Vertex? ver1, Vertex? ver2) {
    if (ver1 == null) throw Exception("May not create a line with a null start vertex.");
    if (ver2 == null) throw Exception("May not create a line with a null end vertex.");
    if (ver1.shape == null) {
      throw Exception("May not create a line with a start vertex which is not attached to a shape.");
    }
    if (ver1.shape != ver2.shape) {
      throw Exception("May not create a line with vertices attached to different shapes.");
    }
    this._setVertex1(ver1);
    this._setVertex2(ver2);
    this._ver1?.shape?.lines._lines.add(this);
    this._ver1?.shape?.onLineAdded(this);
  }

  /// Disposes this line.
  void dispose() {
    if (!this.disposed) {
      this._ver1?.shape?.lines._lines.remove(this);
      this._ver1?.shape?.onLineRemoved(this);
    }
    this._removeVertex1();
    this._removeVertex2();
  }

  /// Sets the first vertex to the given value.
  void _setVertex1(Vertex? ver1) {
    this._ver1 = ver1;
    this._ver1?.lines._lines1.add(this);
  }

  /// Sets the second vertex to the given value.
  void _setVertex2(Vertex? ver2) {
    this._ver2 = ver2;
    this._ver2?.lines._lines2.add(this);
  }

  /// Removes the first vertex.
  void _removeVertex1() {
    this._ver1?.lines._lines1.remove(this);
    this._ver1 = null;
  }

  /// Removes the second vertex.
  void _removeVertex2() {
    this._ver2?.lines._lines2.remove(this);
    this._ver2 = null;
  }

  /// Indicates if the line is disposed or not.
  bool get disposed => (this._ver1 == null) || (this._ver2 == null);

  /// The first vertex of the line.
  Vertex? get vertex1 => this._ver1;

  /// The second vertex of the line.
  Vertex? get vertex2 => this._ver2;

  /// Checks if the given vertex can be replaced by the new given vertex.
  /// If there is any reason it can't and exception is thrown.
  void _checkReplaceVertex(Vertex? oldVer, Vertex? newVer) {
    if (newVer == null) throw Exception("May not replace a line's vertex with a null vertex.");
    if (newVer.shape == null) {
      throw Exception("May not replace a line's vertex with a vertex which is not attached to a shape.");
    }
    if (oldVer?.shape != newVer.shape) {
      throw Exception("May not replace a line's vertex with a vertex attached to a different shape.");
    }
  }

  /// Replaces the given old vertex with the given new vertex if this line contains
  /// the given old vertex. It returns the number of vertices which were replaced.
  int replaceVertex(Vertex? oldVer, Vertex? newVer) {
    if (this.disposed) throw Exception("May not replace a line's vertex when the point has been disposed.");
    int result = 0;
    if (this._ver1 == oldVer) {
      this._checkReplaceVertex(oldVer, newVer);
      this._removeVertex1();
      this._setVertex1(newVer);
      ++result;
    }
    if (this._ver2 == oldVer) {
      this._checkReplaceVertex(oldVer, newVer);
      this._removeVertex2();
      this._setVertex2(newVer);
      ++result;
    }
    if (result > 0) this._ver1?.shape?.onLineModified(this);
    return result;
  }

  /// Indicates if the line is collapsed meaning the two vertices are the same.
  bool get collapsed => this._ver1 == this._ver2;

  /// Determines if the given [other] is a line with the
  /// same vertices as this line.
  bool same(Line other) {
    if (identical(this, other)) return true;
    if (other is! Line) return false;
    if (this._ver1 != other._ver1) return false;
    if (this._ver2 != other._ver2) return false;
    return true;
  }

  /// Gets the string for this line.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this line.
  /// The [indent] is added to the front when provided.
  String format([String indent = ""]) {
    if (this.disposed) return "${indent}disposed";
    return indent + formatInt(this._ver1?.index ?? -1) + ", " + formatInt(this._ver2?.index ?? -1);
  }
}

/// A matcher used to match lines.
abstract class LineMatcher {
  /// Determines if the two given lines match, true, or not, false.
  bool matches(Line? line1, Line? line2);
}

/// A line matcher which matches only identical instances of lines.
class ExactLineMatcher extends LineMatcher {
  /// Returns true if [line1] is [line2], false otherwise.
  @override
  bool matches(Line? line1, Line? line2) => identical(line1, line2);
}

/// A line matcher which matches lines which have the same vertices.
class UndirectedLineMatcher extends LineMatcher {
  /// Returns true if [line1] and [line2] have the same two vertices
  /// in either order, false otherwise.
  @override
  bool matches(Line? line1, Line? line2) {
    if (line1 == null) return false;
    if (line2 == null) return false;
    if (line1.vertex1?.index == line2.vertex1?.index) {
      return line1.vertex2?.index == line2.vertex2?.index;
    } else if (line1.vertex1?.index == line2.vertex2?.index) {
      return line1.vertex2?.index == line2.vertex1?.index;
    } else {
      return false;
    }
  }
}

/// A Point for a rendering element with a single vertex.
class Point {
  Vertex? _ver;

  /// Creates a new point with the given vertex.
  Point(Vertex? ver) {
    if (ver == null) throw Exception("May not create a point with a null vertex.");
    if (ver.shape == null) {
      throw Exception("May not create a point with a vertex which is not attached to a shape.");
    }
    this._setVertex(ver);
    this._ver?.shape?.points._points.add(this);
    this._ver?.shape?.onPointAdded(this);
  }

  /// Disposes this point.
  void dispose() {
    if (!this.disposed) {
      this._ver?.shape?.points._points.remove(this);
      this._ver?.shape?.onPointRemoved(this);
    }
    this._removeVertex();
  }

  /// Sets the vertex to the given value.
  void _setVertex(Vertex? ver) {
    this._ver = ver;
    this._ver?.points._points.add(this);
  }

  /// Removes the vertex.
  void _removeVertex() {
    this._ver?.points._points.remove(this);
    this._ver = null;
  }

  /// Indicates if the point is disposed or not.
  bool get disposed => this._ver == null;

  /// The vertex for this point.
  Vertex? get vertex => this._ver;

  /// Replaces the given old vertex with the given new vertex if this line contains
  /// the given old vertex. It returns the number of vertices which were replaced.
  int replaceVertex(Vertex? oldVer, Vertex? newVer) {
    if (this.disposed) throw Exception("May not replace a point's vertex when the point has been disposed.");
    int result = 0;
    if (this._ver == oldVer) {
      if (newVer == null) throw Exception("May not replace a point's vertex with a null vertex.");
      if (newVer.shape == null) {
        throw Exception("May not replace a point's vertex with a vertex which is not attached to a shape.");
      }
      this._removeVertex();
      this._setVertex(newVer);
      ++result;
    }
    if (result > 0) this._ver?.shape?.onPointModified(this);
    return result;
  }

  /// Determines if the given [other] is a point with the
  /// same vertices as this point.
  bool same(Point other) {
    if (identical(this, other)) return true;
    if (other is! Point) return false;
    if (this._ver != other._ver) return false;
    return true;
  }

  /// Gets the string for this point.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this point.
  /// The [indent] is added to the front when provided.
  String format([String indent = ""]) {
    if (this.disposed) return "${indent}disposed";
    return "${indent}${formatInt(this._ver?.index ?? -1)}";
  }
}

/// A shape defining the renderable shape and collision detection.
class ReducedShape implements ShapeBuilder {
  /// The type of the vertex for this shape.
  final VertexType _type;

  /// The number of base vertex types in the vertex type.
  final int _typeCount;

  /// The stride between vertex data.
  final int _stride;

  /// The current number of vertices in this shape.
  int _vertexCount;

  /// The set of buffer attributes for setting up to render this shape.
  List<BufferAttr> _attrs;

  /// The set of vertex data for the shape.
  final List<double> _vertices;

  /// The set of indices for the points to render.
  final List<int> _points;

  /// The set of indices to vertices in sets of two for each line to render.
  final List<int> _lines;

  /// The set of indices to vertices in sets of three for each face to render.
  final List<int> _faces;

  /// The calculated axial aligned bounding box.
  Region3? _aabb;

  /// The event emitted when the shape has been changed.
  Event? _changed;

  /// Creates a new reduced shape with a specific vertex type.
  /// This isn't nearly as flexible as [Shape] and doesn't provides
  /// the ability to calculate values and change vertex types.
  /// The reduced shape uses much less memory and is faster.
  ReducedShape(VertexType type)
      : this._type = type,
        this._typeCount = type.count,
        this._stride = type.size,
        this._vertexCount = 0,
        this._attrs = [],
        this._vertices = [],
        this._points = [],
        this._lines = [],
        this._faces = [],
        this._aabb = null,
        this._changed = null;

  /// The changed event to signal when ever the shape is modified.
  @override
  Event get changed => this._changed ??= Event();

  /// The set of vertex data for the shape.
  List<double> get vertices => this._vertices;

  /// The set of indices for the points to render.
  List<int> get points => this._points;

  /// The set of indices to vertices in sets of two for each line to render.
  List<int> get lines => this._lines;

  /// The set of indices to vertices in sets of three for each face to render.
  List<int> get faces => this._faces;

  /// Adds the given vertices to the shape and returns the index
  /// to the first vertex added.
  int addVertices(List<Vertex> vertices) {
    final int length = vertices.length;
    final List<double> data = List<double>.filled(length * this._stride, 0.0);
    int offset = 0;
    for (int i = 0; i < this._typeCount; ++i) {
      final VertexType local = this._type.at(i);
      for (int j = 0; j < length; ++j) {
        final Vertex ver = vertices[j];
        final List<double> list = ver.listFor(local);
        int index = offset + j * this._stride;
        for (int k = 0; k < list.length; ++k) {
          data[index] = list[k];
          index++;
        }
      }
      offset += local.size;
    }

    if (this._type.has(VertexType.Pos)) {
      Region3? aabb = this._aabb;
      for (int i = length - 1; i >= 0; i--) {
        final Point3? loc = vertices[i].location;
        if (loc != null) {
          if (aabb == null) {
            aabb = Region3.fromPoint(loc);
          } else {
            aabb = aabb.expandWithPoint(loc);
          }
        }
      }
      this._aabb = aabb;
    }

    final int index = this._vertexCount;
    this._vertexCount += length;
    this._vertices.addAll(data);
    this.onChanged();
    return index;
  }

  /// Adds a new set of points with the given indices for vertices
  void addPoints(List<int> indices) {
    this._points.addAll(indices);
    this.onChanged();
  }

  /// Adds a new strip of lines to the given indices for vertices.
  void addLineStrip(List<int> indices) {
    final int count = indices.length;
    if (count >= 2) {
      final List<int> lines = List<int>.filled(count * 2 - 1, 0);
      for (int i = 1, j = 0; i < count; i++, j += 2) {
        lines[j] = indices[i - 1];
        lines[j + 1] = indices[i];
      }
      this._lines.addAll(lines);
      this.onChanged();
    }
  }

  /// Adds a new loop of lines to the given indices for vertices.
  void addLineLoop(List<int> indices) {
    final int count = indices.length;
    if (count >= 2) {
      final List<int> lines = List<int>.filled(count * 2, 0);
      lines[0] = indices[count - 1];
      lines[1] = indices[0];
      for (int i = 1, j = 2; i < count; i++, j += 2) {
        lines[j] = indices[i - 1];
        lines[j + 1] = indices[i];
      }
      this._lines.addAll(lines);
      this.onChanged();
    }
  }

  /// Adds a set of lines to the given indices for vertices.
  void addLines(List<int> indices) {
    this._lines.addAll(indices);
    this.onChanged();
  }

  /// Adds a fan of faces with the given indices for vertices.
  void addTriangleFan(List<int> indices) {
    final int count = indices.length;
    if (count >= 3) {
      final List<int> tris = List<int>.filled((count - 2) * 3, 0);
      final int ver0 = indices[0];
      for (int i = 2, j = 0; i < count; i++, j += 3) {
        tris[j] = ver0;
        tris[j + 1] = indices[i - 1];
        tris[j + 2] = indices[i];
      }
      this._faces.addAll(tris);
      this.onChanged();
    }
  }

  /// Adds a strip of faces with the given indices for vertices.
  void addTriangleStrip(List<int> indices) {
    final int count = indices.length;
    if (count >= 3) {
      final List<int> tris = List<int>.filled((count - 2) * 3, 0);
      bool flip = false;
      for (int i = 2, j = 0; i < count; i++, j += 3) {
        if (flip) {
          tris[j] = indices[i - 2];
          tris[j + 1] = indices[i - 1];
          tris[j + 2] = indices[i];
          flip = false;
        } else {
          tris[j] = indices[i - 1];
          tris[j + 1] = indices[i - 2];
          tris[j + 2] = indices[i];
          flip = true;
        }
      }
      this._faces.addAll(tris);
      this.onChanged();
    }
  }

  /// Adds a looped strip of faces with the given indices for vertices.
  void addTriangleLoop(List<int> indices) {
    final int count = indices.length;
    if (count >= 3) {
      final List<int> tris = List<int>.filled(count * 3, 0);
      bool flip = false;
      for (int i = 2, j = 0; i < count + 2; i++, j += 3) {
        final int k = i % count;
        if (flip) {
          tris[j] = indices[k - 2];
          tris[j + 1] = indices[k - 1];
          tris[j + 2] = indices[k];
          flip = false;
        } else {
          tris[j] = indices[k - 1];
          tris[j + 1] = indices[k - 2];
          tris[j + 2] = indices[k];
          flip = true;
        }
      }
      this._faces.addAll(tris);
      this.onChanged();
    }
  }

  /// Adds a set of separate faces with the given indices for vertices.
  void addTriangles(List<int> indices) => this._faces.addAll(indices);

  /// Handles any change to this shape.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Calculates the normals for the vertices and faces.
  /// True if successful, false on error.
  /// This always returns false because the reduces shape can't calculate normals.
  @override
  bool calculateNormals() => false;

  /// Calculates the binormals for the vertices and faces.
  /// Typically the normals should be calculated first.
  /// True if successful, false on error.
  /// This always returns false because the reduces shape can't calculate binormals.
  @override
  bool calculateBinormals() => false;

  /// Calculates the cube texture coordinate for the vertices and faces.
  /// The normals should be calculated first.
  /// True if successful, false on error.
  /// This always returns false because the reduces shape can't calculate cube textures.
  @override
  bool calculateCubeTextures() => false;

  /// Calculates the axial aligned bounding box of the shape.
  @override
  Region3 calculateAABB() => this._aabb ?? Region3.zero;

  /// Builds a buffer store for caching the shape for rendering.
  /// This requires the buffer [builder] for WebGL or testing,
  /// and the vertex [type] required for technique.
  @override
  BufferStore build(BufferBuilder builder, VertexType type) {
    if (type != this._type) throw Exception("Shape was reduced to ${this._type} so can not build for $type.");

    final int byteStride = this._stride * typed.Float32List.bytesPerElement;
    int offset = 0;
    this._attrs = List<BufferAttr>.generate(this._typeCount, (int i) {
      final VertexType local = this._type.at(i);
      final int size = local.size;
      final attr = BufferAttr(local, size, offset * typed.Float32List.bytesPerElement, byteStride);
      offset += size;
      return attr;
    });

    final Buffer vertexBuf = builder.fromDoubleList(webgl.WebGL.ARRAY_BUFFER, this._vertices);
    final BufferStore store = BufferStore(vertexBuf, this._attrs, this._type);

    if (this._points.isNotEmpty) {
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, this._points);
      store.indexObjects.add(IndexObject(webgl.WebGL.POINTS, this._points.length, indexBuf));
    }

    if (this._lines.isNotEmpty) {
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, this._lines);
      store.indexObjects.add(IndexObject(webgl.WebGL.LINES, this._lines.length, indexBuf));
    }

    if (this._faces.isNotEmpty) {
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, this._faces);
      store.indexObjects.add(IndexObject(webgl.WebGL.TRIANGLES, this._faces.length, indexBuf));
    }

    return store;
  }
}

/// A shape defining the renderable shape and collision detection.
class Shape implements ShapeBuilder {
  VertexCollection? _vertices;
  ShapePointCollection? _points;
  ShapeLineCollection? _lines;
  ShapeFaceCollection? _faces;
  Event? _changed;

  /// Creates a new shape.
  Shape()
      : this._vertices = null,
        this._points = null,
        this._lines = null,
        this._faces = null,
        this._changed = null;

  /// Creates a copy of the given [other] shape.
  factory Shape.copy(Shape other) => Shape()..merge(other);

  /// The collection of vertices for the shape.
  VertexCollection get vertices => this._vertices ??= VertexCollection._(this);

  /// The collection of renderable points for the shape.
  ShapePointCollection get points => this._points ??= ShapePointCollection._(this);

  /// The collection of renderable lines for the shape.
  ShapeLineCollection get lines => this._lines ??= ShapeLineCollection._(this);

  /// The collection of renderable faces for the shape.
  ShapeFaceCollection get faces => this._faces ??= ShapeFaceCollection._(this);

  /// The changed event to signal when ever the shape is modified.
  @override
  Event get changed => this._changed ??= Event();

  /// Merges the given shape into this shape.
  /// No vertices nor seams are joined, this is a simple copy
  /// of all the given shape's information into this shape.
  void merge(Shape other) {
    this._changed?.suspend();
    other.vertices._updateIndices();

    final int offset = this.vertices.length;
    for (final Vertex vertex in other.vertices._vertices) {
      this.vertices.add(vertex.copy());
    }

    this.vertices._updateIndices();
    for (final Point point in other.points._points) {
      final Vertex ver = this.vertices[(point.vertex?.index ?? 0) + offset];
      this.points.add(ver);
    }

    for (final Line line in other.lines._lines) {
      final Vertex ver1 = this.vertices[(line.vertex1?.index ?? 0) + offset];
      final Vertex ver2 = this.vertices[(line.vertex2?.index ?? 0) + offset];
      this.lines.add(ver1, ver2);
    }

    for (final Face face in other.faces._faces) {
      final Vertex ver1 = this.vertices[(face.vertex1?.index ?? 0) + offset];
      final Vertex ver2 = this.vertices[(face.vertex2?.index ?? 0) + offset];
      final Vertex ver3 = this.vertices[(face.vertex3?.index ?? 0) + offset];
      this.faces.add(ver1, ver2, ver3);
    }
    this._changed?.resume();
  }

  /// Calculates the normals for the vertices and faces.
  /// True if successful, false on error.
  @override
  bool calculateNormals() {
    bool success = true;
    this._changed?.suspend();
    if (!this.faces.calculateNormals()) success = false;
    if (!this.vertices.calculateNormals()) success = false;
    this._changed?.resume();
    return success;
  }

  /// Calculates the binormals for the vertices and faces.
  /// Typically the normals should be calculated first.
  /// True if successful, false on error.
  @override
  bool calculateBinormals() {
    bool success = true;
    this._changed?.suspend();
    if (!this.faces.calculateBinormals()) success = false;
    if (!this.vertices.calculateBinormals()) success = false;
    this._changed?.resume();
    return success;
  }

  /// Calculates the cube texture coordinate for the vertices and faces.
  /// The normals should be calculated first.
  /// True if successful, false on error.
  @override
  bool calculateCubeTextures() {
    bool success = true;
    this._changed?.suspend();
    if (!this.vertices.calculateCubeTextures()) success = false;
    this._changed?.resume();
    return success;
  }

  /// Calculate the weight using a vertex measuring tool.
  void calculateWeights([VertexMeasure? measure]) {
    if (measure == null) {
      final Region3 aabb = calculateAABB();
      double length = Vector3(aabb.dx, aabb.dy, aabb.dz).length();
      if (length <= 0.0) length = 1.0;
      // ignore: parameter_assignments
      measure = RadialVertexMeasure(center: Point3(aabb.x, aabb.y, aabb.z), scalar: 1.0 / length);
    }
    final int count = this.vertices.length;
    for (int i = count - 1; i >= 0; i--) {
      final Vertex ver = this.vertices[i];
      ver.weight = measure.measure(ver);
    }
  }

  /// Calculates the axial aligned bounding box of the shape.
  @override
  Region3 calculateAABB() {
    final int count = this.vertices.length;
    if (count <= 0) return Region3.zero;
    Region3? result;
    for (int i = count - 1; i >= 0; i--) {
      final Point3? loc = this.vertices[i].location;
      if (loc != null) {
        if (result == null) {
          result = Region3.fromPoint(loc);
        } else {
          result = result.expandWithPoint(loc);
        }
      }
    }
    return result ?? Region3.zero;
  }

  /// Apply the given [height] map to offset the vertices of the shape.
  /// Use the [scalar] to adjust the amount of offset the height moves the vertices.
  /// The height is pulled from the map using the texture 2D values of the vertices and
  /// the offset is applied in the direction of the normal vector.
  void applyHeightMap(TextureReader height, [double scalar = 1.0]) {
    this._changed?.suspend();
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Point3? loc = ver.location;
      final Vector3? norm = ver.normal;
      final Point2? txt2D = ver.texture2D;
      if ((loc != null) && (norm != null) && (txt2D != null)) {
        final Color4 clr = height.atLoc(txt2D);
        final double length = (clr.red + clr.green + clr.blue) * scalar / 3.0;
        ver.location = loc + Point3.fromVector3(norm * length);
      }
    }
    this._changed?.resume();
  }

  /// Trims all the vertices down to the given vertex types,
  /// everything else is nulled out.
  void trimVertices(VertexType type) {
    this._changed?.suspend();
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      this.vertices[i].trim(type);
    }
    this._changed?.resume();
  }

  /// Trims all the faces down to have the given true values,
  /// everything else is nulled out.
  void trimFaces({bool norm = true, bool binm = true}) {
    this._changed?.suspend();
    for (int i = this.faces.length - 1; i >= 0; --i) {
      this.faces[i].trim(norm: norm, binm: binm);
    }
    this._changed?.resume();
  }

  /// Finds the first index of the vertex which matches the given vertex.
  /// If no match is found then -1 is returned.
  int findFirstIndex(Vertex ver, [VertexMatcher? matcher, int startIndex = 0]) {
    matcher ??= FullVertexMatcher();
    final int count = this.vertices.length;
    for (int i = startIndex; i < count; ++i) {
      final Vertex ver2 = this.vertices[i];
      if (matcher.matches(ver, ver2)) return i;
    }
    return -1;
  }

  /// Gets the first vertex in this shape which matches the given vertex.
  /// If no match is found then null is returned.
  Vertex? findFirst(Vertex ver, [VertexMatcher? matcher, int startIndex = 0]) {
    matcher ??= FullVertexMatcher();
    final int count = this.vertices.length;
    for (int i = startIndex; i < count; ++i) {
      final Vertex ver2 = this.vertices[i];
      if (matcher.matches(ver, ver2)) return ver2;
    }
    return null;
  }

  /// Finds all vertices in this shape which matches the given vertex.
  List<Vertex> findAll(Vertex ver, [VertexMatcher? matcher, int startIndex = 0]) {
    matcher ??= FullVertexMatcher();
    final List<Vertex> results = [];
    final int count = this.vertices.length;
    for (int i = startIndex; i < count; ++i) {
      final Vertex ver2 = this.vertices[i];
      if (matcher.matches(ver, ver2)) results.add(ver2);
    }
    return results;
  }

  /// Replaces the vertices at the given indices with the given new vertex.
  void _replaceVertices(Vertex newVer, List<Vertex> replacedVers) {
    this.vertices.add(newVer);
    for (final Vertex ver in replacedVers) {
      while (ver.faces.length > 0) {
        ver.faces[0].replaceVertex(ver, newVer);
      }
      while (ver.lines.length > 0) {
        ver.lines[0].replaceVertex(ver, newVer);
      }
      while (ver.points.length > 0) {
        ver.points[0].replaceVertex(ver, newVer);
      }
      this.vertices.remove(ver);
    }
  }

  /// Merges with the given merger all the vertices which match with the given matcher.
  /// This may also be used to process vertices without replacing them if the
  /// merger returns null for a merge.
  /// After merger collapsed lines and faces are removed and
  /// repeat points, lines, and faces are removed.
  void mergeVertices(VertexMatcher matcher, VertexMerger merger) {
    this._changed?.suspend();
    final List<Vertex> vertices = this.vertices.copyToList();
    while (vertices.isNotEmpty) {
      final Vertex ver = vertices.first;
      vertices.removeAt(0);

      // Find all matches
      final List<Vertex> matches = [];
      matches.add(ver);
      for (int i = vertices.length - 1; i >= 0; i--) {
        final Vertex otherVer = vertices[i];
        if (matcher.matches(ver, otherVer)) {
          matches.add(otherVer);
          vertices.removeAt(i);
        }
      }

      // If there are any matches, merge them.
      if (matches.length > 1) {
        final Vertex? newVer = merger.merge(matches);
        if (newVer != null) {
          this._replaceVertices(newVer, matches);
          vertices.add(newVer);
        }
      }
    }

    this.vertices._updateIndices();
    this.lines.removeCollapsed();
    this.faces.removeCollapsed();
    this.points.removeRepeats();
    this.lines.removeVertexRepeats(UndirectedLineMatcher());
    this.faces.removeVertexRepeats(SimilarFaceMatcher());
    this._changed?.resume();
  }

  /// Joins seams in the shape by joining vertices.
  /// By joining vertices the edges will be smoothed hiding seams.
  /// This is useful if you wrap a flat grid into a cylinder and want
  /// to smooth where the opposite edges touch.
  void joinSeams([VertexMatcher? matcher]) {
    matcher ??= VertexLocationMatcher();
    this.mergeVertices(matcher, VertexJoiner());
  }

  /// Adjust normals by summing all the normals for matching vertices.
  /// This is similar to joining seams because it will smooth out edges
  /// however the edges will still have separate vertices meaning the surface
  /// can have texturing without a texture seam.
  void adjustNormals([VertexMatcher? matcher]) {
    matcher ??= VertexLocationMatcher();
    this.mergeVertices(matcher, NormalAdjuster());
  }

  /// Adjust binormals by summing all the binormals for matching vertices.
  /// This is similar to joining seams because it will smooth out edges
  /// however the edges will still have separate vertices meaning the surface
  /// can have texturing without a texture seam.
  void adjustBinormals([VertexMatcher? matcher]) {
    matcher ??= VertexLocationMatcher();
    this.mergeVertices(matcher, BinormalAdjuster());
  }

  /// Flips the shape inside out.
  void flip() {
    this._changed?.suspend();
    this.faces.flip();
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Vector3? norm = ver.normal;
      if (norm != null) ver.normal = -norm;
      final Vector3? binm = ver.binormal;
      if (binm != null) ver.binormal = -binm;
    }
    this._changed?.resume();
  }

  /// Scales the AABB so that the longest size the given [size],
  /// and the shape is centered then offset by the given [offset].
  void resizeCenter([double size = 2.0, Point3? offset]) {
    final Region3 aabb = this.calculateAABB();
    offset ??= Point3.zero;
    // ignore: parameter_assignments
    offset = offset - aabb.center;
    double maxSize = aabb.dx;
    if (aabb.dy > maxSize) maxSize = aabb.dy;
    if (aabb.dz > maxSize) maxSize = aabb.dz;
    if (maxSize == 0.0) return;
    final double invSize = size / maxSize;
    this.applyPositionMatrix(
        Matrix4.scale(invSize, invSize, invSize) * Matrix4.translate(offset.x, offset.y, offset.z));
  }

  /// Modifies the position, normal, and binormal
  /// by translating it with the given [mat].
  void applyPositionMatrix(Matrix4 mat) {
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Point3? loc = ver.location;
      if (loc != null) ver.location = mat.transPnt3(loc);
      final Vector3? norm = ver.normal;
      if (norm != null) ver.normal = mat.transVec3(norm);
      final Vector3? binm = ver.binormal;
      if (binm != null) ver.binormal = mat.transVec3(binm);
    }
  }

  /// Modifies the color by translating it with the given [mat].
  void applyColorMatrix(Matrix3 mat) {
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Color4? clr = ver.color;
      if (clr != null) ver.color = mat.transClr4(clr);
    }
  }

  /// Modifies the 2D texture by translating it with the given [mat].
  void applyTexture2DMatrix(Matrix3 mat) {
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Point2? txt2D = ver.texture2D;
      if (txt2D != null) ver.texture2D = mat.transPnt2(txt2D);
    }
  }

  /// Modifies the cube texture by translating it with the given [mat].
  void applyTextureCubeMatrix(Matrix4 mat) {
    for (int i = this.vertices.length - 1; i >= 0; --i) {
      final Vertex ver = this.vertices[i];
      final Vector3? txtCube = ver.textureCube;
      if (txtCube != null) ver.textureCube = mat.transVec3(txtCube);
    }
  }

  /// Builds a buffer store for caching the shape for rendering.
  /// This requires the buffer [builder] for WebGL or testing,
  /// and the vertex [type] required for technique.
  @override
  BufferStore build(BufferBuilder builder, VertexType type) {
    final int length = this.vertices.length;
    final int count = type.count;
    final int stride = type.size;
    final int byteStride = stride * typed.Float32List.bytesPerElement;
    final List<double> vertices = List<double>.filled(length * stride, 0.0);
    int offset = 0;
    final List<BufferAttr> attrs = List<BufferAttr>.generate(count, (int i) {
      final VertexType local = type.at(i);
      final int size = local.size;
      final attr = BufferAttr(local, size, offset * typed.Float32List.bytesPerElement, byteStride);
      for (int j = 0; j < length; ++j) {
        final Vertex ver = this.vertices[j];
        final List<double> list = ver.listFor(local);
        int index = offset + j * stride;
        for (int k = 0; k < list.length; ++k) {
          vertices[index] = list[k];
          index++;
        }
      }
      offset += size;
      return attr;
    });

    final Buffer vertexBuf = builder.fromDoubleList(webgl.WebGL.ARRAY_BUFFER, vertices);
    final BufferStore store = BufferStore(vertexBuf, attrs, type);
    if (!this.points.isEmpty) {
      final List<int> indices = [];
      for (int i = 0; i < this.points.length; ++i) {
        indices.add(this.points[i].vertex?.index ?? 0);
      }
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, indices);
      store.indexObjects.add(IndexObject(webgl.WebGL.POINTS, indices.length, indexBuf));
    }

    if (!this.lines.isEmpty) {
      final List<int> indices = [];
      for (int i = 0; i < this.lines.length; ++i) {
        final line = this.lines[i];
        indices.add(line.vertex1?.index ?? 0);
        indices.add(line.vertex2?.index ?? 0);
      }
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, indices);
      store.indexObjects.add(IndexObject(webgl.WebGL.LINES, indices.length, indexBuf));
    }

    if (!this.faces.isEmpty) {
      final List<int> indices = [];
      for (int i = 0; i < this.faces.length; i++) {
        final face = this.faces[i];
        indices.add(face.vertex1?.index ?? 0);
        indices.add(face.vertex2?.index ?? 0);
        indices.add(face.vertex3?.index ?? 0);
      }
      final Buffer indexBuf = builder.fromIntList(webgl.WebGL.ELEMENT_ARRAY_BUFFER, indices);
      store.indexObjects.add(IndexObject(webgl.WebGL.TRIANGLES, indices.length, indexBuf));
    }

    return store;
  }

  /// Gets the string for the shape
  @override
  String toString() => this.format();

  /// Gets the formatted string for this shape with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    if (!this.vertices.isEmpty) {
      parts.add("${indent}Vertices:");
      parts.add(this.vertices.format("${indent}   "));
    }
    if (!this.points.isEmpty) {
      parts.add('${indent}Points:');
      parts.add(this.points.format("${indent}   "));
    }
    if (!this.lines.isEmpty) {
      parts.add('${indent}Lines:');
      parts.add(this.lines.format("${indent}   "));
    }
    if (!this.faces.isEmpty) {
      parts.add('${indent}Faces:');
      parts.add(this.faces.format("${indent}   "));
    }
    return parts.join('\n');
  }

  /// Handles any change to this shape.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onChanged([EventArgs? args]) => this._changed?.emit(args);

  /// Called when the given [vertex] has been added.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onVertexAdded(Vertex vertex) => this.onChanged();

  /// Called when the given [vertex] has been modified.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onVertexModified(Vertex vertex) => this.onChanged();

  /// Called when the given [vertex] has been removed.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onVertexRemoved(Vertex vertex) => this.onChanged();

  /// Called when the given [face] has been added.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onFaceAdded(Face face) => this.onChanged();

  /// Called when the given [face] has been modified.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onFaceModified(Face face) => this.onChanged();

  /// Called when the given [face] has been removed.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onFaceRemoved(Face face) => this.onChanged();

  /// Called when the given [line] has been added.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onLineAdded(Line line) => this.onChanged();

  /// Called when the given [line] has been modified.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onLineModified(Line line) => this.onChanged();

  /// Called when the given [line] has been removed.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onLineRemoved(Line line) => this.onChanged();

  /// Called when the given [point] has been added.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onPointAdded(Point point) => this.onChanged();

  /// Called when the given [point] has been modified.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onPointModified(Point point) => this.onChanged();

  /// Called when the given [point] has been removed.
  /// This calls the [onChanged] method.
  /// This isn't meant to be called from outside the entity, in other languages this would
  /// be a protected method. This method is exposed to that the shape is extended and
  /// these methods can be overwritten. If overwritten call this super method to still emit events.
  void onPointRemoved(Point point) => this.onChanged();
}

/// A builder for filling out a for a shape buffer.
abstract class ShapeBuilder extends Changeable {
  /// Calculates the normals for the vertices and faces.
  /// True if successful, false on error.
  bool calculateNormals();

  /// Calculates the binormals for the vertices and faces.
  /// Typically the normals should be calculated first.
  /// True if successful, false on error.
  bool calculateBinormals();

  /// Calculates the cube texture coordinate for the vertices and faces.
  /// The normals should be calculated first.
  /// True if successful, false on error.
  bool calculateCubeTextures();

  /// Calculates the axial aligned bounding box of the shape.
  Region3 calculateAABB();

  /// Builds a buffer store for caching the shape for rendering.
  /// This requires the buffer [builder] for WebGL or testing,
  /// and the vertex [type] required for technique.
  BufferStore build(BufferBuilder builder, VertexType type);
}

/// A collection of faces for a shape.
class ShapeFaceCollection {
  final Shape _shape;
  final List<Face> _faces;

  /// Creates a new shape's face collection for the given shape.
  ShapeFaceCollection._(this._shape) : this._faces = [];

  /// The shape which owns this collection.
  Shape get shape => this._shape;

  /// Adds a single new face with the given vertices to the shape.
  Face add(Vertex ver1, Vertex ver2, Vertex ver3) {
    this._shape.vertices.add(ver1);
    this._shape.vertices.add(ver2);
    this._shape.vertices.add(ver3);
    final Face face = Face(ver1, ver2, ver3);
    return face;
  }

  /// Adds a fan of faces with the given vertices to the shape.
  List<Face> addFan(List<Vertex> vertices) {
    final List<Face> faces = [];
    final int count = vertices.length;
    if (count > 0) {
      final Vertex ver0 = vertices[0];
      for (int i = 2; i < count; i++) {
        faces.add(this.add(ver0, vertices[i - 1], vertices[i]));
      }
    }
    return faces;
  }

  /// Adds a strip of faces with the given vertices to the shape.
  List<Face> addStrip(List<Vertex> vertices) {
    final List<Face> faces = [];
    final int count = vertices.length;
    bool flip = false;
    for (int i = 2; i < count; i++) {
      if (flip) {
        faces.add(this.add(vertices[i - 2], vertices[i - 1], vertices[i]));
        flip = false;
      } else {
        faces.add(this.add(vertices[i - 1], vertices[i - 2], vertices[i]));
        flip = true;
      }
    }
    return faces;
  }

  /// Adds a looped strip of faces with the given vertices to the shape.
  List<Face> addLoop(List<Vertex> vertices) {
    final List<Face> faces = [];
    final int count = vertices.length;
    bool flip = false;
    for (int i = 2; i < count + 2; i++) {
      final int j = i % count;
      if (flip) {
        faces.add(this.add(vertices[j - 2], vertices[j - 1], vertices[j]));
        flip = false;
      } else {
        faces.add(this.add(vertices[j - 1], vertices[j - 2], vertices[j]));
        flip = true;
      }
    }
    return faces;
  }

  /// Adds a set of separate faces with the given vertices to the shape.
  List<Face> addTriangles(List<Vertex> vertices) {
    final List<Face> faces = [];
    final int count = vertices.length;
    for (int i = 2; i < count; i += 3) {
      faces.add(this.add(vertices[i - 2], vertices[i - 1], vertices[i]));
    }
    return faces;
  }

  /// Adds a grid to the of faces with the given rows and columns of vertices to the shape.
  List<Face> addGrid(int rows, int columns, List<Vertex> vertices) {
    final List<Face> faces = [];
    int k0 = 0, k1 = columns;
    bool flipA = false;
    for (int i = 1; i < rows; ++i, ++k0, ++k1) {
      bool flipB = flipA;
      for (int j = 1; j < columns; ++j, ++k0, ++k1) {
        final Vertex ver0 = vertices[k0];
        final Vertex ver1 = vertices[k0 + 1];
        final Vertex ver2 = vertices[k1 + 1];
        final Vertex ver3 = vertices[k1];
        if (flipB) {
          faces.add(this.add(ver0, ver1, ver2));
          faces.add(this.add(ver0, ver2, ver3));
        } else {
          faces.add(this.add(ver1, ver2, ver3));
          faces.add(this.add(ver1, ver3, ver0));
        }
        flipB = !flipB;
      }
      flipA = !flipA;
    }
    return faces;
  }

  /// Determines if the shape contains any faces or not.
  bool get isEmpty => this._faces.isEmpty;

  /// The number of faces in the shape.
  int get length => this._faces.length;

  /// Gets the face at the at given [index].
  Face operator [](int index) => this._faces[index];

  /// Gets the index of the given [face] or -1 if not found.
  int indexOf(Face face) => this._faces.indexOf(face);

  /// Runs the given function handler for every face in the shape.
  void forEach(void Function(Face face) funcHndl) => this._faces.forEach(funcHndl);

  /// Removes the face with at the given index.
  /// The removed face is disposed and returned or null if none removed.
  Face removeAt(int index) {
    final Face face = this[index];
    face.dispose();
    return face;
  }

  /// Removes the given [face].
  /// Returns true if face was removed, false otherwise.
  bool remove(Face? face) {
    if (face == null) return false;
    if (face._ver1?.shape != this.shape) return false;
    face.dispose();
    return true;
  }

  /// Removes all faces which match each other based on the given matcher.
  void removeRepeats([FaceMatcher? matcher]) {
    matcher ??= ExactFaceMatcher();
    for (int i = this._faces.length - 1; i >= 0; --i) {
      final Face faceA = this._faces[i];
      for (int j = i - 1; j >= 0; --j) {
        final Face faceB = this._faces[j];
        if (matcher.matches(faceA, faceB)) {
          faceA.dispose();
          break;
        }
      }
    }
  }

  /// Removes all faces which match each other based
  /// on the given matcher and share a vertex.
  void removeVertexRepeats([FaceMatcher? matcher]) {
    matcher ??= ExactFaceMatcher();
    for (int k = this._shape.vertices.length - 1; k >= 0; --k) {
      final Vertex ver = this._shape.vertices[k];
      for (int i = ver.faces.length - 1; i >= 0; --i) {
        final Face faceA = ver.faces[i];
        for (int j = i - 1; j >= 0; --j) {
          final Face faceB = ver.faces[j];
          if (matcher.matches(faceA, faceB)) {
            faceA.dispose();
            break;
          }
        }
      }
    }
  }

  /// Removes all the collapsed faces.
  void removeCollapsed() {
    for (int i = this._faces.length - 1; i >= 0; --i) {
      final Face face = this._faces[i];
      if (face.collapsed) face.dispose();
    }
  }

  /// Removes all faces.
  void removeAll() {
    for (int i = this._faces.length - 1; i >= 0; --i) {
      this._faces[i].dispose();
    }
    this._faces.clear();
  }

  /// Calculates the normals for all the faces in the shape.
  /// Returns true if faces' normals are calculated, false on error.
  bool calculateNormals() {
    bool success = true;
    for (final Face face in this._faces) {
      if (!face.calculateNormal()) success = false;
    }
    return success;
  }

  /// Calculates the binormals for all the faces in the shape.
  /// Returns true if faces' binormals are calculated, false on error.
  bool calculateBinormals() {
    bool success = true;
    for (final Face face in this._faces) {
      if (!face.calculateBinormal()) success = false;
    }
    return success;
  }

  /// Flips all the faces in the shape.
  void flip() {
    for (final Face face in this._faces) {
      face.flip();
    }
  }

  /// Gets to string for all the faces.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this faces with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    for (final Face face in this._faces) {
      parts.add(face.format(indent));
    }
    return parts.join('\n');
  }
}

/// A collection of lines for a shape.
class ShapeLineCollection {
  final Shape _shape;
  final List<Line> _lines;

  /// Creates a new shape's line collection for the given shape.
  ShapeLineCollection._(this._shape) : this._lines = [];

  /// The shape which owns this collection.
  Shape get shape => this._shape;

  /// Adds a new line with the given vertices to the shape.
  Line add(Vertex ver1, Vertex ver2) {
    this._shape.vertices.add(ver1);
    this._shape.vertices.add(ver2);
    return Line(ver1, ver2);
  }

  /// Adds a new strip of lines to the given vertices to the shape.
  List<Line> addStrip(List<Vertex> vertices) {
    final List<Line> lines = [];
    final int count = vertices.length;
    for (int i = 1; i < count; i++) {
      lines.add(this.add(vertices[i - 1], vertices[i]));
    }
    return lines;
  }

  /// Adds a new loop of lines to the given vertices to the shape.
  List<Line> addLoop(List<Vertex> vertices) {
    final List<Line> lines = [];
    final int count = vertices.length;
    if (count > 0) {
      for (int i = 1; i < count; i++) {
        lines.add(this.add(vertices[i - 1], vertices[i]));
      }
      lines.add(this.add(vertices[count - 1], vertices[0]));
    }
    return lines;
  }

  /// Adds a set of lines to the given vertices to the shape.
  List<Line> addLines(List<Vertex> vertices) {
    final List<Line> lines = [];
    final int count = vertices.length;
    for (int i = 1; i < count; i += 2) {
      lines.add(this.add(vertices[i - 1], vertices[i]));
    }
    return lines;
  }

  /// Determines if the shape contains any lines or not.
  bool get isEmpty => this._lines.isEmpty;

  /// The number of lines in the shape.
  int get length => this._lines.length;

  /// Gets the line at the at given index.
  Line operator [](int index) => this._lines[index];

  /// Gets the index of the given [line] or -1 if not found.
  int indexOf(Line line) => this._lines.indexOf(line);

  /// Runs the given function handler for every line in the shape.
  void forEach(void Function(Line line) funcHndl) => this._lines.forEach(funcHndl);

  /// Removes the line with at the given index.
  /// The removed line is disposed and returned or null if none removed.
  Line removeAt(int index) {
    final Line line = this[index];
    line.dispose();
    return line;
  }

  /// Removes the given [line].
  /// Returns true if line was removed, false otherwise.
  bool remove(Line? line) {
    if (line == null) return false;
    if (line._ver1?.shape != this.shape) return false;
    line.dispose();
    return true;
  }

  /// Removes all lines which match each other based on the given matcher.
  void removeRepeats([LineMatcher? matcher]) {
    matcher ??= ExactLineMatcher();
    for (int i = this._lines.length - 1; i >= 0; --i) {
      final Line lineA = this._lines[i];
      for (int j = i - 1; j >= 0; --j) {
        final Line lineB = this._lines[j];
        if (matcher.matches(lineA, lineB)) {
          lineA.dispose();
          break;
        }
      }
    }
  }

  /// Removes all lines which match each other based
  /// on the given matcher and share a vertex.
  void removeVertexRepeats([LineMatcher? matcher]) {
    matcher ??= ExactLineMatcher();
    for (int k = this._shape.vertices.length - 1; k >= 0; --k) {
      final Vertex ver = this._shape.vertices[k];
      for (int i = ver.lines.length - 1; i >= 0; --i) {
        final Line lineA = ver.lines[i];
        for (int j = i - 1; j >= 0; --j) {
          final Line lineB = ver.lines[j];
          if (matcher.matches(lineA, lineB)) {
            lineA.dispose();
            break;
          }
        }
      }
    }
  }

  /// Removes all the collapsed lines.
  void removeCollapsed() {
    for (int i = this._lines.length - 1; i >= 0; --i) {
      final Line line = this._lines[i];
      if (line.collapsed) line.dispose();
    }
  }

  /// Gets to string for all the lines.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this lines with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    final int count = this._lines.length;
    for (int i = 0; i < count; ++i) {
      final Line line = this._lines[i];
      parts.add(line.format(indent + "$i. "));
    }
    return parts.join('\n');
  }
}

/// A collection of points for a shape.
class ShapePointCollection {
  final Shape _shape;
  final List<Point> _points;

  /// Creates a new shape's point collection for the given shape.
  ShapePointCollection._(this._shape) : this._points = [];

  /// The shape which owns this collection.
  Shape get shape => this._shape;

  /// Adds a new point with the given vertex to shape.
  Point add(Vertex vertex) {
    this._shape.vertices.add(vertex);
    return Point(vertex);
  }

  /// Adds a set of new points with the given vertices to shape.
  List<Point> addList(List<Vertex> vertices) {
    final List<Point> points = [];
    final int count = vertices.length;
    for (int i = 0; i < count; ++i) {
      points.add(this.add(vertices[i]));
    }
    return points;
  }

  /// Determines if the shape contains any points or not.
  bool get isEmpty => this._points.isEmpty;

  /// The number of points in the shape.
  int get length => this._points.length;

  /// Gets the point at the at given [index].
  Point operator [](int index) => this._points[index];

  /// Gets the index of the given [point] or -1 if not found.
  int indexOf(Point point) => this._points.indexOf(point);

  /// Runs the given function handler for every point in the shape.
  void forEach(void Function(Point point) funcHndl) => this._points.forEach(funcHndl);

  /// Removes the point with at the given [index].
  /// The removed point is disposed and returned or null if none removed.
  Point removeAt(int index) {
    final Point pnt = this._points[index];
    pnt.dispose();
    return pnt;
  }

  /// Removes the given [point].
  /// Returns true if point was removed, false otherwise.
  bool remove(Point? point) {
    if (point == null) return false;
    if (point._ver?.shape != this.shape) return false;
    point.dispose();
    return true;
  }

  /// Removes all points which share the same vertex.
  void removeRepeats() {
    for (int i = this._points.length - 1; i >= 0; --i) {
      final int length = this._points[i].vertex?.points.length ?? 0;
      if (length > 1) this.removeAt(i);
    }
  }

  /// Gets to string for all the points.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this points with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    for (final Point pnt in this._points) {
      parts.add(pnt.format(indent));
    }
    return parts.join('\n');
  }
}

/// A vertex of a shape with all of the renderable elements it is used.
class Vertex {
  Shape? _shape;

  VertexPointCollection? _points;
  VertexLineCollection? _lines;
  VertexFaceCollection? _faces;

  int _index;
  Point3? _loc;
  Vector3? _norm;
  Vector3? _binm;
  Point2? _txt2D;
  Vector3? _txtCube;
  Color4? _clr;
  double _weight;
  Point4? _bending;

  /// Creates a new vertex with the default values.
  Vertex({
    VertexType? type,
    Point3? loc,
    Vector3? norm,
    Vector3? binm,
    Point2? txt2D,
    Vector3? txtCube,
    Color4? clr,
    double weight = 0.0,
    Point4? bending,
  })  : this._shape = null,
        this._points = null,
        this._lines = null,
        this._faces = null,
        this._index = 0,
        this._loc = null,
        this._norm = null,
        this._binm = null,
        this._txt2D = null,
        this._txtCube = null,
        this._clr = null,
        this._weight = 0.0,
        this._bending = null {
    type ??= VertexType.All;
    if (type.has(VertexType.Pos)) this._loc = loc;
    if (type.has(VertexType.Norm)) this._norm = norm;
    if (type.has(VertexType.Binm)) this._binm = binm;
    if (type.has(VertexType.Txt2D)) this._txt2D = txt2D;
    if (type.has(VertexType.TxtCube)) this._txtCube = txtCube;
    if (type.has(VertexType.Color)) this._clr = clr;
    if (type.has(VertexType.Weight)) this._weight = weight;
    if (type.has(VertexType.Bending)) this._bending = bending;
  }

  /// Creates a copy of the vertex values.
  Vertex copy([VertexType? type]) {
    return Vertex(
        type: type,
        loc: this._loc,
        norm: this._norm,
        binm: this._binm,
        txt2D: this._txt2D,
        txtCube: this._txtCube,
        clr: this._clr,
        weight: this._weight,
        bending: this._bending);
  }

  /// Trims the vertex to have just the given vertex type,
  /// everything else is nulled out.
  void trim(VertexType type) {
    if (!type.has(VertexType.Pos)) this._loc = null;
    if (!type.has(VertexType.Norm)) this._norm = null;
    if (!type.has(VertexType.Binm)) this._binm = null;
    if (!type.has(VertexType.Txt2D)) this._txt2D = null;
    if (!type.has(VertexType.TxtCube)) this._txtCube = null;
    if (!type.has(VertexType.Color)) this._clr = null;
    if (!type.has(VertexType.Weight)) this._weight = 0.0;
    if (!type.has(VertexType.Bending)) this._bending = null;
  }

  /// The shape the vertex belongs to.
  Shape? get shape => this._shape;

  /// The points which use this vertex.
  VertexPointCollection get points => this._points ??= VertexPointCollection._(this);

  /// The lines which use this vertex.
  VertexLineCollection get lines => this._lines ??= VertexLineCollection._(this);

  /// The faces which use this vertex.
  VertexFaceCollection get faces => this._faces ??= VertexFaceCollection._(this);

  /// The index of this vertex in the shape.
  int get index {
    this._shape?.vertices._updateIndices();
    return this._index;
  }

  /// Indicates if this vertex has any attached renderable elements, true if not.
  bool get isEmpty => points.isEmpty && lines.isEmpty && faces.isEmpty;

  /// The 3D location of the vertex.
  Point3? get location => this._loc;

  set location(Point3? loc) {
    if (this._loc != loc) {
      this._loc = loc;
      this._shape?.onVertexModified(this);
    }
  }

  /// The 3D normal vector of the vertex.
  Vector3? get normal => this._norm;

  set normal(Vector3? norm) {
    // ignore: parameter_assignments
    norm = norm?.normal();
    if (this._norm != norm) {
      this._norm = norm;
      this._shape?.onVertexModified(this);
    }
  }

  /// The 3D binormal vector of the vertex.
  Vector3? get binormal => this._binm;

  set binormal(Vector3? binm) {
    // ignore: parameter_assignments
    binm = binm?.normal();
    if (this._binm != binm) {
      this._binm = binm;
      this._shape?.onVertexModified(this);
    }
  }

  /// The 2D texture coordinate of the vertex.
  Point2? get texture2D => this._txt2D;

  set texture2D(Point2? txt2D) {
    if (this._txt2D != txt2D) {
      this._txt2D = txt2D;
      this._shape?.onVertexModified(this);
    }
  }

  /// The cube texture coordinate of the vertex.
  Vector3? get textureCube => this._txtCube;

  set textureCube(Vector3? txtCube) {
    if (this._txtCube != txtCube) {
      this._txtCube = txtCube;
      this._shape?.onVertexModified(this);
    }
  }

  /// The RGBA color of the vertex.
  Color4? get color => this._clr;

  set color(Color4? clr) {
    if (this._clr != clr) {
      this._clr = clr;
      this._shape?.onVertexModified(this);
    }
  }

  /// The weight value of the vertex.
  double get weight => this._weight;

  set weight(double weight) {
    if (this._weight != weight) {
      this._weight = weight;
      if (this._shape != null) this._shape?.onVertexModified(this);
    }
  }

  /// The bending values of the vertex.
  Point4? get bending => this._bending;

  set bending(Point4? bending) {
    if (this._bending != bending) {
      this._bending = bending;
      this._shape?.onVertexModified(this);
    }
  }

  /// Gets the list of doubles for the vertex component for the given [type].
  List<double> listFor(VertexType type) {
    if (type == VertexType.Pos) {
      return this._loc?.toList() ?? [0.0, 0.0, 0.0];
    } else if (type == VertexType.Norm) {
      return this._norm?.toList() ?? [0.0, 1.0, 0.0];
    } else if (type == VertexType.Binm) {
      return this._binm?.toList() ?? [0.0, 0.0, 1.0];
    } else if (type == VertexType.Txt2D) {
      return this._txt2D?.toList() ?? [0.0, 0.0];
    } else if (type == VertexType.TxtCube) {
      return this._txtCube?.toList() ?? [0.0, 0.0, 0.0];
    } else if (type == VertexType.Clr3) {
      return [this._clr?.red ?? 1.0, this._clr?.green ?? 1.0, this._clr?.blue ?? 1.0];
    } else if (type == VertexType.Clr4) {
      return this._clr?.toList() ?? [1.0, 1.0, 1.0, 1.0];
    } else if (type == VertexType.Weight) {
      return [this._weight];
    } else if (type == VertexType.Bending) {
      return this._bending?.toList() ?? [-1.0, -1.0, -1.0, -1.0];
    } else {
      return [];
    }
  }

  /// Calculates the normal vector for this vertex based off of the
  /// faces attached to this vertex. If the normal has already been
  /// set then this will have no effect.
  bool calculateNormal() {
    if (this._norm != null) return true;
    final shape = this._shape;
    if (shape != null) shape._changed?.suspend();
    Vector3 normSum = Vector3.zero;
    this.faces.forEach((Face face) {
      final Vector3? norm = face.normal;
      if (norm != null) normSum += norm;
    });
    this._norm = normSum.normal();
    if (shape != null) {
      shape.onVertexModified(this);
      shape._changed?.resume();
    }
    return true;
  }

  /// Calculates the binormal vector for this vertex based off of the
  /// faces attached to this vertex. If the binormal has already been
  /// set then this will have no effect.
  bool calculateBinormal() {
    if (this._binm != null) return true;
    final shape = this._shape;
    if (shape != null) shape._changed?.suspend();
    Vector3 binmSum = Vector3.zero;
    this.faces.forEach((Face face) {
      final Vector3? binm = face.binormal;
      if (binm != null) binmSum += binm;
    });
    this._binm = binmSum.normal();
    if (shape != null) {
      shape.onVertexModified(this);
      shape._changed?.resume();
    }
    return true;
  }

  /// Finds the first line which starts at this vertex
  /// and ends at the given [ver].
  Line? firstLineTo(Vertex ver) {
    final int count = this.lines.length1;
    for (int i = 0; i < count; ++i) {
      final Line line = this.lines.at1(i);
      if (line.vertex2?.index == ver.index) return line;
    }
    return null;
  }

  /// Finds the first line which goes between this vertex
  /// and the given [ver] in either direction.
  Line? firstLineBetween(Vertex ver) {
    final Line? line = this.firstLineTo(ver);
    if (line != null) return line;
    return ver.firstLineTo(this);
  }

  /// Determines if the given [other] value is a vertex with the
  /// same values as this vertex.
  /// Does not compare the shape, indices, points, lines, or faces.
  bool same(Vertex? other) {
    if (identical(this, other)) return true;
    if (other is! Vertex) return false;
    if (this._loc != other._loc) return false;
    if (this._norm != other._norm) return false;
    if (this._binm != other._binm) return false;
    if (this._txt2D != other._txt2D) return false;
    if (this._txtCube != other._txtCube) return false;
    if (this._clr != other._clr) return false;
    if (Comparer.equals(this._weight, other._weight)) return false;
    if (this._bending != other._bending) return false;
    return true;
  }

  /// Gets the string for this vertex.
  @override
  String toString() => this.format();

  /// Gets the formatted string for this vertex with and optional [indent].
  String format([String indent = '']) {
    final List<String> parts = [];
    parts.add(formatInt(this._index));
    parts.add(this._loc?.toString() ?? '-');
    parts.add(this._norm?.toString() ?? '-');
    parts.add(this._binm?.toString() ?? '-');
    parts.add(this._txt2D?.toString() ?? '-');
    parts.add(this._txtCube?.toString() ?? '-');
    parts.add(this._clr?.toString() ?? '-');
    parts.add(formatDouble(this._weight));
    parts.add(this._bending?.toString() ?? '-');
    final String result = parts.join(', ');
    return '$indent{$result}';
  }
}

/// A collection of vertices for the shapes.
class VertexCollection {
  final Shape _shape;
  bool _indicesNeedUpdate;
  final List<Vertex> _vertices;

  /// Creates a new vertex collection of a shape.
  VertexCollection._(this._shape)
      : this._indicesNeedUpdate = false,
        this._vertices = [];

  /// Updates the indices of all vertices.
  void _updateIndices() {
    if (this._indicesNeedUpdate) {
      final int count = this._vertices.length;
      for (int i = 0; i < count; ++i) {
        this._vertices[i]._index = i;
      }
      this._indicesNeedUpdate = false;
    }
  }

  /// Adds a new [vertex] to this collection.
  /// True if it was added, false otherwise.
  bool add(Vertex vertex) {
    if (vertex.shape != null) {
      if (vertex.shape == this._shape) return false;
      throw Exception('May not add a vertex already attached to another shape to this shape.');
    }
    vertex._index = this._vertices.length;
    vertex._shape = this._shape;
    this._vertices.add(vertex);
    this._shape.onVertexAdded(vertex);
    return true;
  }

  /// Creates and adds a new vertex to this collection with the default values.
  Vertex addNew(
      {VertexType? type,
      Point3? loc,
      Vector3? norm,
      Vector3? binm,
      Point2? txt2D,
      Vector3? txtCube,
      Color4? clr,
      double weight = 0.0,
      Point4? bending}) {
    final Vertex ver = Vertex(
        type: type,
        loc: loc,
        norm: norm,
        binm: binm,
        txt2D: txt2D,
        txtCube: txtCube,
        clr: clr,
        weight: weight,
        bending: bending);
    this.add(ver);
    return ver;
  }

  /// Creates and adds a new vertex with the given location values.
  Vertex addNewLoc(double locX, double locY, double locZ) {
    final Vertex ver = Vertex(loc: Point3(locX, locY, locZ));
    this.add(ver);
    return ver;
  }

  /// Adds a list of vertices to the collection.
  void addList(List<Vertex> verList) {
    // ignore: prefer_foreach
    for (final Vertex ver in verList) {
      this.add(ver);
    }
  }

  /// Determines if the collection has any vertices in it.
  bool get isEmpty => this._vertices.isEmpty;

  /// Determines the number of vertices in the collection.
  int get length => this._vertices.length;

  /// Gets the vertex at the given [index].
  Vertex operator [](int index) => this._vertices[index];

  /// Gets the index of the [vertex], or -1 if not found.
  int indexOf(Vertex vertex) => this._vertices.indexOf(vertex);

  /// Runs the given function handler for every vertex in the shape.
  void forEach(void Function(Vertex vertex) funcHndl) => this._vertices.forEach(funcHndl);

  /// Removes the vertex with at the given index.
  /// The removed vertex is disposed and returned or null if none removed.
  Vertex removeAt(int index) {
    final Vertex vertex = this._vertices[index];
    if (!vertex.isEmpty) throw Exception('May not remove a vertex without first making it empty.');
    vertex._shape = null;
    this._vertices.removeAt(index);
    this._shape.onVertexRemoved(vertex);
    this._indicesNeedUpdate = true;
    return vertex;
  }

  /// Removes the given [vertex].
  /// Returns true if vertex was removed, false otherwise.
  bool remove(Vertex? vertex) {
    if (vertex == null) return false;
    if (vertex._shape != this._shape) return false;
    if (!vertex.isEmpty) throw Exception('May not remove a vertex without first making it empty.');
    vertex._shape = null;
    this._vertices.remove(vertex);
    this._shape.onVertexRemoved(vertex);
    this._indicesNeedUpdate = true;
    return true;
  }

  /// Calculates the normals for all the faces in the shape.
  /// Returns true if faces' normals are calculated, false on error.
  bool calculateNormals() {
    bool success = true;
    for (final Vertex vertex in this._vertices) {
      if (!vertex.calculateNormal()) success = false;
    }
    return success;
  }

  /// Calculates the binormals for all the vertices in the shape.
  /// Returns true if vertices' binormals are calculated, false on error.
  bool calculateBinormals() {
    bool success = true;
    for (final Vertex vertex in this._vertices) {
      if (!vertex.calculateBinormal()) success = false;
    }
    return success;
  }

  /// Calculates the cube texture coordinate for the vertices and faces.
  /// True if successful, false on error.
  bool calculateCubeTextures() {
    for (final Vertex vertex in this._vertices) {
      if (vertex.textureCube == null) {
        final norm = vertex.normal;
        if (norm != null) vertex.textureCube = norm.normal();
      }
    }
    return true;
  }

  /// Gets a copy of the vertices as a list.
  List<Vertex> copyToList() => this._vertices.toList();

  /// Gets to string for all the vertices.
  @override
  String toString() => this.format();

  /// Gets the formatted string for all the vertices with and optional [indent].
  String format([String indent = '']) {
    this._updateIndices();
    final List<String> parts = [];
    for (final Vertex vertex in this._vertices) {
      parts.add(vertex.format(indent));
    }
    return parts.join('\n');
  }
}

/// A collection of faces for a vertex.
class VertexFaceCollection {
  final Vertex _vertex;
  final List<Face> _faces1;
  final List<Face> _faces2;
  final List<Face> _faces3;

  /// Creates a new vertex's face collection for the given vertex.
  VertexFaceCollection._(this._vertex)
      : this._faces1 = [],
        this._faces2 = [],
        this._faces3 = [];

  /// The vertex which owns this collection.
  Vertex get vertex => this._vertex;

  /// The shape which owns the vertex which owns this collection.
  Shape? get shape => this._vertex.shape;

  /// Determines if the vertex contains any faces or not.
  bool get isEmpty => this._faces1.isEmpty && this._faces2.isEmpty && this._faces3.isEmpty;

  /// The number of faces in the vertex.
  int get length => this._faces1.length + this._faces2.length + this._faces3.length;

  /// The number of faces which use this vertex as the faces' first vertex.
  int get length1 => this._faces1.length;

  /// The number of faces which use this vertex as the faces' second vertex.
  int get length2 => this._faces2.length;

  /// The number of faces which use this vertex as the faces' third vertex.
  int get length3 => this._faces3.length;

  /// Gets the face at the given [index].
  Face operator [](int index) {
    final int len1 = this._faces1.length;
    if (index < len1) return this._faces1[index];
    // ignore: parameter_assignments
    index -= len1;
    final int len2 = this._faces2.length;
    if (index < len2) return this._faces2[index];
    // ignore: parameter_assignments
    index -= len2;
    return this._faces3[index];
  }

  /// Gets face with the given [index] from list
  /// of the faces with this vertex as their first vertex.
  Face at1(int index) => this._faces1[index];

  /// Gets face with the given [index] from list
  /// of the faces with this vertex as their second vertex.
  Face at2(int index) => this._faces2[index];

  /// Gets face with the given [index] from list
  /// of the faces with this vertex as their third vertex.
  Face at3(int index) => this._faces3[index];

  /// Gets the index of the given [face].
  int indexOf(Face face) {
    int index = this._faces1.indexOf(face);
    if (index >= 0) return index;
    index = this._faces2.indexOf(face);
    if (index >= 0) return index + this._faces1.length;
    index = this._faces3.indexOf(face);
    if (index >= 0) return index + this._faces1.length + this._faces2.length;
    return -1;
  }

  /// Gets the index of the given [face] in the list
  /// of the faces with this vertex as their first vertex.
  /// -1 is returned if the face isn't found.
  int indexOf1(Face face) => this._faces1.indexOf(face);

  /// Gets the index of the given [face] in the list
  /// of the faces with this vertex as their second vertex.
  /// -1 is returned if the face isn't found.
  int indexOf2(Face face) => this._faces2.indexOf(face);

  /// Gets the index of the given [face] in the list
  /// of the faces with this vertex as their third vertex.
  /// -1 is returned if the face isn't found.
  int indexOf3(Face face) => this._faces3.indexOf(face);

  /// Runs the given function handler for every face in the vertex.
  void forEach(
    final void Function(Face face) funcHndl,
  ) {
    this._faces1.forEach(funcHndl);
    this._faces2.forEach(
      (final face) {
        // TODO fix this
        // ignore: unrelated_type_equality_checks
        if (face.vertex1 != this) {
          funcHndl(face);
        }
      },
    );
    this._faces3.forEach(
      (final face) {
        // TODO fix this
        // ignore: unrelated_type_equality_checks
        if ((face.vertex1 != this) && (face.vertex2 != this)) {
          funcHndl(face);
        }
      },
    );
  }

  /// Runs the given function handler for every face in the vertex
  /// which has this vertex as their first vertex.
  void forEach1(void Function(Face face) funcHndl) => this._faces1.forEach(funcHndl);

  /// Runs the given function handler for every face in the vertex
  /// which has this vertex as their second vertex.
  void forEach2(void Function(Face face) funcHndl) => this._faces2.forEach(funcHndl);

  /// Runs the given function handler for every face in the vertex
  /// which has this vertex as their third vertex.
  void forEach3(void Function(Face face) funcHndl) => this._faces3.forEach(funcHndl);

  /// Removes the face with at the given index.
  /// The removed face is disposed and returned or null if none removed.
  Face removeAt(int index) {
    final Face face = this[index];
    face.dispose();
    return face;
  }

  /// Removes the face with at the given index of the face from
  /// the list of the faces with this vertex as their first vertex.
  /// The removed face is disposed and returned or null if none removed.
  Face removeAt1(int index) {
    final Face face = this._faces1[index];
    face.dispose();
    return face;
  }

  /// Removes the face with at the given index of the face from
  /// the list of the faces with this vertex as their second vertex.
  /// The removed face is disposed and returned or null if none removed.
  Face removeAt2(int index) {
    final Face face = this._faces2[index];
    face.dispose();
    return face;
  }

  /// Removes the face with at the given index of the face from
  /// the list of the faces with this vertex as their third vertex.
  /// The removed face is disposed and returned or null if none removed.
  Face removeAt3(int index) {
    final Face face = this._faces3[index];
    face.dispose();
    return face;
  }

  /// Removes the given [face].
  /// Returns true if face was removed, false otherwise.
  bool remove(Face? face) {
    if (face == null) return false;
    if (face._ver1?.shape != this.shape) return false;
    face.dispose();
    return true;
  }

  /// Removes all faces which match each other based on the given matcher.
  void removeRepeats(FaceMatcher matcher) {
    for (int i = this._faces1.length - 1; i >= 0; --i) {
      final Face faceA = this._faces1[i];
      for (int j = i - 1; j >= 0; --j) {
        final Face faceB = this._faces1[j];
        if (matcher.matches(faceA, faceB)) {
          faceA.dispose();
          break;
        }
      }
    }
  }

  /// Removes all the collapsed faces.
  void removeCollapsed() {
    for (int i = this._faces1.length - 1; i >= 0; --i) {
      final Face face = this._faces1[i];
      if (face.collapsed) face.dispose();
    }
    for (int i = this._faces2.length - 1; i >= 0; --i) {
      final Face face = this._faces2[i];
      if (face.collapsed) face.dispose();
    }
    // No need to do [_faces3] because two be collapsed
    // it must have more than one point in the same vertex.
  }

  /// Removes all faces using this vertex.
  void removeAll() {
    for (int i = this._faces1.length - 1; i >= 0; --i) {
      this._faces1[i].dispose();
    }
    this._faces1.clear();
    for (int i = this._faces2.length - 1; i >= 0; --i) {
      this._faces2[i].dispose();
    }
    this._faces2.clear();
    for (int i = this._faces3.length - 1; i >= 0; --i) {
      this._faces3[i].dispose();
    }
    this._faces3.clear();
  }

  /// Calculates the normals for all the faces in the vertex.
  /// Returns true if faces' normals are calculated, false on error.
  bool calculateNormals() {
    bool success = true;
    for (final Face face in this._faces1) {
      if (!face.calculateNormal()) success = false;
    }
    for (final Face face in this._faces2) {
      if (!face.calculateNormal()) success = false;
    }
    for (final Face face in this._faces3) {
      if (!face.calculateNormal()) success = false;
    }
    return success;
  }

  /// Calculates the binormals for all the faces in the vertex.
  /// Returns true if faces' binormals are calculated, false on error.
  bool calculateBinormals() {
    bool success = true;
    for (final Face face in this._faces1) {
      if (!face.calculateBinormal()) success = false;
    }
    for (final Face face in this._faces2) {
      if (!face.calculateBinormal()) success = false;
    }
    for (final Face face in this._faces3) {
      if (!face.calculateBinormal()) success = false;
    }
    return success;
  }

  /// Flips all the faces in the vertex.
  void flip() {
    this.forEach((Face face) {
      face.flip();
    });
  }

  /// Gets to string for all the faces.
  @override
  String toString() => this.format();

  /// Gets the formatted string for all the faces with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    for (final Face face in this._faces1) {
      parts.add(face.format(indent));
    }
    for (final Face face in this._faces2) {
      parts.add(face.format(indent));
    }
    for (final Face face in this._faces3) {
      parts.add(face.format(indent));
    }
    return parts.join('\n');
  }
}

/// A collection of lines for a vertex.
class VertexLineCollection {
  final Vertex _vertex;
  final List<Line> _lines1;
  final List<Line> _lines2;

  /// Creates a new vertex's line collection for the given vertex.
  VertexLineCollection._(this._vertex)
      : this._lines1 = [],
        this._lines2 = [];

  /// The vertex which owns this collection.
  Vertex get vertex => this._vertex;

  /// The shape which owns the vertex which owns this collection.
  Shape? get shape => this._vertex.shape;

  /// Adds a line from this vertex to the given vertex.
  Line addLineTo(Vertex vertex) {
    if (this._vertex.shape == null) {
      throw Exception('May not add a line to a vertex which has not been added to a shape.');
    }
    this._vertex.shape?.vertices.add(vertex);
    return Line(this._vertex, vertex);
  }

  /// Adds lines from this vertex to the given vertices.
  List<Line> addLinesTo(List<Vertex> vertices) {
    if (this._vertex.shape == null) {
      throw Exception('May not add lines to a vertex which has not been added to a shape.');
    }
    final int count = vertices.length;
    final List<Line> lines = List<Line>.generate(count, (int i) {
      final Vertex vertex = vertices[i];
      this._vertex.shape?.vertices.add(vertex);
      return Line(this._vertex, vertex);
    });
    return lines;
  }

  /// Determines if the vertex contains any lines or not.
  bool get isEmpty => this._lines1.isEmpty && this._lines2.isEmpty;

  /// The number of lines in the vertex.
  int get length => this._lines1.length + this._lines2.length;

  /// The number of lines which use this vertex as the lines' first vertex.
  int get length1 => this._lines1.length;

  /// The number of lines which use this vertex as the lines' second vertex.
  int get length2 => this._lines2.length;

  /// Gets the line at the at given index.
  Line operator [](int index) {
    final int len1 = this._lines1.length;
    if (index >= len1) {
      return this._lines2[index - len1];
    } else {
      return this._lines1[index];
    }
  }

  /// Gets line with the given [index] from list
  /// of the lines with this vertex as their first vertex.
  Line at1(int index) => this._lines1[index];

  /// Gets line with the given [index] from list
  /// of the lines with this vertex as their second vertex.
  Line at2(int index) => this._lines2[index];

  /// Gets the index of the given [line].
  int indexOf(Line line) {
    int index = this._lines1.indexOf(line);
    if (index >= 0) return index;
    index = this._lines2.indexOf(line);
    if (index >= 0) return index + this._lines1.length;
    return -1;
  }

  /// Gets the index of the given [line] in the list
  /// of the lines with this vertex as their first vertex.
  /// -1 is returned if the line isn't found.
  int indexOf1(Line line) => this._lines1.indexOf(line);

  /// Gets the index of the given [line] in the list
  /// of the lines with this vertex as their second vertex.
  /// -1 is returned if the line isn't found.
  int indexOf2(Line line) => this._lines2.indexOf(line);

  /// Runs the given function handler for every line in the vertex.
  void forEach(
    final void Function(Line line) funcHndl,
  ) {
    this._lines1.forEach(funcHndl);
    this._lines2.forEach(
      (final line) {
        // TODO fix this
        // ignore: unrelated_type_equality_checks
        if (line.vertex1 != this) {
          funcHndl(line);
        }
      },
    );
  }

  /// Runs the given function handler for every line in the vertex
  /// which has this vertex as their first vertex.
  void forEach1(void Function(Line line) funcHndl) => this._lines1.forEach(funcHndl);

  /// Runs the given function handler for every line in the vertex
  /// which has this vertex as their first vertex.
  void forEach2(void Function(Line line) funcHndl) => this._lines2.forEach(funcHndl);

  /// Removes the line with at the given index.
  /// The removed line is disposed and returned or null if none removed.
  Line removeAt(int index) {
    final Line line = this[index];
    line.dispose();
    return line;
  }

  /// Removes the line with at the given index of the face from
  /// the list of the lines with this vertex as their first vertex.
  /// The removed line is disposed and returned or null if none removed.
  Line removeAt1(int index) {
    final Line line = this._lines1[index];
    line.dispose();
    return line;
  }

  /// Removes the line with at the given index of the face from
  /// the list of the lines with this vertex as their second vertex.
  /// The removed line is disposed and returned or null if none removed.
  Line removeAt2(int index) {
    final Line line = this._lines2[index];
    line.dispose();
    return line;
  }

  /// Removes the given [line].
  /// Returns true if line was removed, false otherwise.
  bool remove(Line? line) {
    if (line == null) return false;
    if (line._ver1?.shape != this.shape) return false;
    line.dispose();
    return true;
  }

  /// Removes all lines which match each other based on the given matcher.
  void removeRepeats(LineMatcher matcher) {
    for (int i = this._lines1.length - 1; i >= 0; --i) {
      final Line lineA = this._lines1[i];
      for (int j = i - 1; j >= 0; --j) {
        final Line lineB = this._lines1[j];
        if (matcher.matches(lineA, lineB)) {
          lineA.dispose();
          break;
        }
      }
    }
  }

  /// Removes all the collapsed lines.
  void removeCollapsed() {
    for (int i = this._lines1.length - 1; i >= 0; --i) {
      final Line line = this._lines1[i];
      if (line.collapsed) line.dispose();
    }
  }

  /// Gets to string for all the lines.
  @override
  String toString() => this.format();

  /// Gets the formatted string for all the lines with and optional [indent].
  String format([String indent = '']) {
    final List<String> parts = [];
    for (final Line line in this._lines1) {
      parts.add(line.format(indent));
    }
    for (final Line line in this._lines2) {
      parts.add(line.format(indent));
    }
    return parts.join('\n');
  }
}

/// A matcher used to match vertices.
abstract class VertexMatcher {
  /// Determines if the two given vertices match, true, or not, false.
  bool matches(Vertex? v1, Vertex? v2);
}

/// A vertex matcher which matches only identical instances of vertices.
class ExactVertexMatcher extends VertexMatcher {
  /// Returns true if [v1] is [v2], false otherwise.
  @override
  bool matches(Vertex? v1, Vertex? v2) => identical(v1, v2);
}

/// A vertex matcher which matches vertices which have the same values.
class FullVertexMatcher extends VertexMatcher {
  /// Returns true if [v1] has the same values as [v2], false otherwise.
  @override
  bool matches(Vertex? v1, Vertex? v2) {
    if (v1 == null) return false;
    return v1.same(v2);
  }
}

/// A vertex matcher which matches vertices which have the same location.
class VertexLocationMatcher extends VertexMatcher {
  /// Returns true if [v1] has the same location as [v2], false otherwise.
  @override
  bool matches(Vertex? v1, Vertex? v2) {
    if (v1 == null) return false;
    if (v2 == null) return false;
    return v1.location == v2.location;
  }
}

/// A vertex matcher which matches vertices which have are a less than or equal to a specific distance away.
class NearVertexLocationMatcher extends VertexMatcher {
  /// The maximum distance away two vertices can be, beyond which two vertices will not be merged.
  final double epsilon;

  /// The square of the epsilon value.
  final double epsilon2;

  /// Creates a new near vertex location matcher for the given epsilon.
  factory NearVertexLocationMatcher(double epsilon) => NearVertexLocationMatcher._(epsilon, epsilon * epsilon);

  /// Creates a new near vertex location matcher.
  NearVertexLocationMatcher._(this.epsilon, this.epsilon2);

  /// Returns true if [v1] has a near location to [v2], false otherwise.
  @override
  bool matches(Vertex? v1, Vertex? v2) {
    if (v1 == null) return false;
    if (v2 == null) return false;
    final loc1 = v1.location;
    final loc2 = v2.location;
    if (loc1 == null) return false;
    if (loc2 == null) return false;
    return loc1.distance2(loc2) <= epsilon2;
  }
}

/// A tool for measuring a distance to a vertex.
abstract class VertexMeasure {
  /// Determines the distance of the given vertex.
  double measure(Vertex? ver);
}

/// A vector measure which measures the distance from a point.
/// Not recommended for getting a maximum distance or minimum distance
/// from a point since this performs a square root for each measurement.
class RadialVertexMeasure extends VertexMeasure {
  /// The scalar to apply to the distance.
  final double _scalar;

  /// The center point to get this distance from.
  final Point3 _center;

  /// Creates a new radial measure tool with optional [center] and [scalar].
  RadialVertexMeasure({double scalar = 1.0, Point3? center})
      : this._scalar = scalar,
        this._center = center ?? Point3.zero;

  /// Determines the distance from the center point to the given vertex scaled.
  @override
  double measure(Vertex? ver) {
    if (ver == null) return 0.0;
    final loc = ver.location;
    if (loc == null) return 0.0;
    return this._center.distance(loc) * this._scalar;
  }
}

/// A vector measure which measures the distance squared from a point.
class Radial2VertexMeasure extends VertexMeasure {
  /// The scalar to apply to the distance.
  final double _scalar;

  /// The center point to get this distance squared from.
  final Point3 _center;

  /// Creates a new radial 2 measure tool with optional [center] and [scalar].
  Radial2VertexMeasure({double scalar = 1.0, Point3? center})
      : this._scalar = scalar,
        this._center = center ?? Point3.zero;

  /// Determines the distance  squared from the center point to the given vertex scaled.
  @override
  double measure(Vertex? ver) {
    if (ver == null) return 0.0;
    final loc = ver.location;
    if (loc == null) return 0.0;
    return this._center.distance2(loc) * this._scalar;
  }
}

/// A vector measure which measures as a projection of the vertex onto
/// a ray defined by a common center point and vector.
class DirectionalVertexMeasure extends VertexMeasure {
  /// The vector for the direction and magnitude of projection measurement.
  final Vector3 _vector;

  /// The length of the vector doubled.
  double _idist2;

  /// The center point for the measurements and start of the vector's ray.
  final Point3 _center;

  /// Creates a new directional measure tool with optional [center] and [vector].
  DirectionalVertexMeasure({Point3? center, Vector3? vector})
      : this._center = center ?? Point3.zero,
        this._idist2 = 0.0,
        this._vector = vector ?? Vector3.posZ {
    final double dist2 = this._vector.length2();
    this._idist2 = () {
      if (dist2 == 0.0) {
        return 1.0;
      } else {
        return 1.0 / dist2;
      }
    }();
  }

  /// Determines the distance from the center point of the given vertex
  /// projected on the vector.
  @override
  double measure(Vertex? ver) {
    if (ver == null) return 0.0;
    final loc = ver.location;
    if (loc == null) return 0.0;
    final Vector3 diff = Vector3.fromPoint3(loc - this._center);
    return this._vector.dot(diff) * this._idist2;
  }
}

/// An exponential measurement adjustment.
class ExpVertexMeasure extends VertexMeasure {
  /// The measuring tool to adjust.
  final VertexMeasure _measure;

  /// The high power to shift measurement with.
  final double _power;

  /// The number of divisions to split the exponential shape into.
  final double _divs;

  /// Creates an exponential measurement adjustment.
  /// [_measure] is adjusted by the given [exponent].
  ExpVertexMeasure(this._measure, double exponent, double divs)
      : this._power = pow(2.0, exponent).toDouble(),
        this._divs = ((){
          if (divs <= 0.0) {
            return 1.0;
          } else {
            return divs;
          }
        }());

  /// Determines the distance from the center point
  /// of the given vertex projected on the vector.
  @override
  double measure(Vertex? ver) {
    final double dist = clampVal(this._measure.measure(ver));
    final double offset = (dist * this._divs).floorToDouble() / this._divs;
    final double iter = ((dist * this._divs) % 1.0) * 2.0;
    double value;
    if (iter >= 1.0) {
      value = (2.0 - pow(2.0 - iter, this._power)) * 0.5 / this._divs + offset;
    } else {
      value = pow(iter, this._power) * 0.5 / this._divs + offset;
    }
    return clampVal(value);
  }
}

class VertexPointCollection {
  final Vertex _vertex;
  final List<Point> _points;

  VertexPointCollection._(this._vertex) : this._points = [];

  /// The vertex which owns this collection.
  Vertex get vertex => this._vertex;

  /// The shape which owns the vertex which owns this collection.
  Shape? get shape => this._vertex._shape;

  /// Adds a point to this vertex.
  Point add() {
    if (this._vertex.shape == null) {
      throw Exception("May not add a point to a vertex which has not been added to a shape.");
    }
    return Point(this._vertex);
  }

  /// Determines if the vertex contains any points or not.
  bool get isEmpty => this._points.isEmpty;

  /// The number of points in the vertex.
  int get length => this._points.length;

  /// Gets the point at the at given [index].
  Point operator [](int index) => this._points[index];

  /// Gets the index of the given [point] or -1 if not found.
  int indexOf(Point point) => this._points.indexOf(point);

  /// Runs the given function handler for every point in the vertex.
  void forEach(void Function(Point point) funcHndl) => this._points.forEach(funcHndl);

  /// Removes the point with at the given [index].
  /// The removed point is disposed and returned or null if none removed.
  Point removeAt(int index) {
    final Point pnt = this._points[index];
    pnt.dispose();
    return pnt;
  }

  /// Removes the given [point].
  /// Returns true if point was removed, false otherwise.
  bool remove(Point? point) {
    if (point == null) return false;
    if (point.vertex?.shape != this.shape) return false;
    point.dispose();
    return true;
  }

  /// Removes all points which share this vertex.
  /// This will remove all but the first point attached to this vector.
  void removeRepeats() {
    for (int i = this._points.length - 1; i >= 1; --i) {
      this.removeAt(i);
    }
  }

  /// Gets to string for all the points.
  @override
  String toString() => this.format();

  /// Gets the formatted string for all the points with and optional [indent].
  String format([String indent = ""]) {
    final List<String> parts = [];
    for (final Point pnt in this._points) {
      parts.add(pnt.format(indent));
    }
    return parts.join('\n');
  }
}

/// A merger for joining or manipulating vertices.
abstract class VertexMerger {
  /// Merges the given vertices into one vertex and returns it.
  /// Or null can be returned and the list of vertices can have their values updated.
  Vertex? merge(List<Vertex> vertices);
}

/// Vertex joiner constructs a single vertex which is the average
/// of the values in all the given vertices.
class VertexJoiner extends VertexMerger {
  /// Merges all the given vertices into an average vertices.
  @override
  Vertex? merge(List<Vertex> vertices) {
    int divLoc = 0;
    Point3? avgLoc;
    Vector3? avgNorm;
    Vector3? avgBinm;
    int divClr = 0;
    Vector4? avgClr;
    int divTxt2D = 0;
    Point2? avgTxt2D;
    int divTxtCube = 0;
    Vector3? avgTxtCube;
    int divWeight = 0;
    double avgWeight = 0.0;

    for (final Vertex ver in vertices) {
      final Point3? loc = ver.location;
      if (loc != null) {
        if (avgLoc == null) {
          avgLoc = loc;
        } else {
          avgLoc += loc;
        }
        divLoc++;
      }

      final Vector3? norm = ver.normal;
      if (norm != null) {
        if (avgNorm == null) {
          avgNorm = norm;
        } else {
          avgNorm += norm;
        }
      }

      final Vector3? binm = ver.binormal;
      if (binm != null) {
        if (avgBinm == null) {
          avgBinm = binm;
        } else {
          avgBinm += binm;
        }
      }

      final Point2? txt2D = ver.texture2D;
      if (txt2D != null) {
        if (avgTxt2D == null) {
          avgTxt2D = txt2D;
        } else {
          avgTxt2D += txt2D;
        }
        divTxt2D++;
      }

      final Vector3? txtCube = ver.textureCube;
      if (txtCube != null) {
        if (avgTxtCube == null) {
          avgTxtCube = txtCube;
        } else {
          avgTxtCube += txtCube;
        }
        divTxtCube++;
      }

      final Color4? clr = ver.color;
      if (clr != null) {
        if (avgClr == null) {
          avgClr = Vector4.fromList(clr.toList());
        } else {
          avgClr += Vector4.fromList(clr.toList());
        }
        divClr++;
      }
      avgWeight += ver.weight;
      divWeight++;
    }

    final Vertex argVer = Vertex();
    if ((divLoc <= 0) || (avgLoc == null)) {
      argVer.location = null;
    } else {
      argVer.location = avgLoc / divLoc.toDouble();
    }

    if (avgNorm == null) {
      argVer.normal = null;
    } else {
      argVer.normal = avgNorm.normal();
    }

    if (avgBinm == null) {
      argVer.binormal = null;
    } else {
      argVer.binormal = avgBinm.normal();
    }

    if ((divTxt2D <= 0) || (avgTxt2D == null)) {
      argVer.texture2D = null;
    } else {
      argVer.texture2D = avgTxt2D / divTxt2D.toDouble();
    }

    if ((divTxtCube <= 0) || (avgTxtCube == null)) {
      argVer.textureCube = null;
    } else {
      argVer.textureCube = avgTxtCube / divTxtCube.toDouble();
    }

    if ((divClr <= 0) || (avgClr == null)) {
      argVer.color = null;
    } else {
      argVer.color = Color4.fromList((avgClr / divClr.toDouble()).toList());
    }

    if (divWeight <= 0) {
      argVer.weight = 0.0;
    } else {
      argVer.weight = avgWeight / divWeight.toDouble();
    }

    return argVer;
  }
}

/// Adjusts all the vertices so they have the same averaged normal.
class NormalAdjuster extends VertexMerger {
  /// Returns null and updates the normal of all
  /// the [vertices] to the average of all the normals.
  @override
  Vertex? merge(List<Vertex> vertices) {
    Vector3 avgNorm = Vector3.zero;
    for (final Vertex ver in vertices) {
      final Vector3? norm = ver.normal;
      if (norm != null) avgNorm += norm;
    }
    avgNorm = avgNorm.normal();
    for (final Vertex ver in vertices) {
      ver.normal = avgNorm;
    }
    return null;
  }
}

/// Adjusts all the vertices so they have the same averaged binormal.
class BinormalAdjuster extends VertexMerger {
  /// Returns null and updates the binormal of all
  /// the [vertices] to the average of all the binormals.
  @override
  Vertex? merge(List<Vertex> vertices) {
    Vector3 avgBinorm = Vector3.zero;
    for (final Vertex ver in vertices) {
      final Vector3? binm = ver.binormal;
      if (binm != null) avgBinorm += binm;
    }
    avgBinorm = avgBinorm.normal();
    for (final Vertex ver in vertices) {
      ver.binormal = avgBinorm;
    }
    return null;
  }
}
