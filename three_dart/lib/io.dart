// IO is a set or readers and writers for loading
// and saving graphical data.
import 'dart:async';
import 'dart:html';

import 'core.dart';
import 'events.dart';
import 'math.dart';
import 'shapes.dart';
import 'techniques.dart';
import 'textures.dart';

/// Gets the path without the file name from the given path with a file name.
String getPathTo(
  final String file,
) {
  final index = file.lastIndexOf('/');
  if (index <= 0) {
    return file;
  } else {
    return file.substring(0, index);
  }
}

/// Joins add a file name to a path.
String joinPath(
  final String path,
  final String file,
) =>
    '$path/$file';

/// The singleton for the regular expression for taking a single word.
RegExp? _slicerRegexSingleton;

/// The regular expression for taking a single word.
RegExp get _slicerRegex => _slicerRegexSingleton ??= RegExp(r'([^\s]+)');

/// Splits the given [line] into the first word and the rest of the line.
List<String> _stripFront(
  final String line,
) {
  final match = _slicerRegex.firstMatch(line);
  if (match == null) return [];
  final front = match.group(1);
  if (front == null) return [];
  final rest = line.substring(front.length).trim();
  return [front, rest];
}

/// Splits the given [line] into words.
List<String> _sliceLine(
  final String line,
) {
  final list = <String>[];
  for (final match in _slicerRegex.allMatches(line)) {
    final group = match.group(1);
    if (group != null) list.add(group);
  }
  return list;
}

/// Splits the given [line] into parsed numbers.
List<double> _getNumbers(
  final String line,
) {
  final parts = _sliceLine(line);
  final values = <double>[];
  final count = parts.length;
  for (int i = 0; i < count; ++i) {
    values.add(double.parse(parts[i]));
  }
  return values;
}

/// The event argument for event's with information about entities changing.
class ProgressEventArgs extends EventArgs {
  /// The list of entities which have been changed.
  /// Typically this will be entities added or removed.
  final double progress;

  /// This indicates the some progress has been finished.
  final bool done;

  /// Creates an entity event argument.
  ProgressEventArgs(
    final Object sender,
    this.progress,
    this.done,
  ) : super(sender);
}

/// Entity writer for writing *.obj files.
class _objWriter {
  final bool _normals;
  final bool _texture;
  final bool _txtCube;
  final List<String> _lines;
  int _totalVertices;
  final int _decimals;

  /// Creates a new object writer.
  _objWriter(
    this._normals,
    this._texture,
    this._txtCube,
    this._decimals,
  )   : this._lines = [],
        this._totalVertices = 1 {
    this._lines.add('# Generated by 3Dart');
  }

  /// Adds an entity to the object file.
  void addEntity(Entity entity) {
    // ignore: prefer_foreach
    for (final child in entity.children) {
      this.addEntity(child);
    }
    final shape = entity.shape;
    if (shape != null) {
      this._lines.add('o ${entity.name}');
      this.addShape(shape);
    }
  }

  /// Gets all the lines of the object file.
  List<String> get lines => this._lines;

  /// Stringifies the given double with the configured decimals.
  String _toStr(double value) => value.toStringAsFixed(this._decimals);

  /// Adds a shape to the object file.
  void addShape(Shape shape) {
    final offset = this._totalVertices;
    final vertexCount = shape.vertices.length;
    if (this._normals) shape.calculateNormals();
    if (this._texture && this._txtCube) shape.calculateCubeTextures();
    for (int i = 0; i < vertexCount; i++) {
      final vertex = shape.vertices[i];
      final loc = vertex.location;
      if (loc == null) throw Exception('May not write vertex $i because it has a null location.');
      this._lines.add('v ' + this._toStr(loc.x) + ' ' + this._toStr(loc.y) + ' ' + this._toStr(loc.z));
      if (this._texture) {
        if (this._txtCube) {
          final txt = vertex.textureCube;
          if (txt != null) {
            this._lines.add('vt ' + this._toStr(txt.dx) + ' ' + this._toStr(txt.dy) + ' ' + this._toStr(txt.dz));
          }
        } else {
          final txt = vertex.texture2D;
          if (txt != null) this._lines.add('vt ' + this._toStr(txt.x) + ' ' + this._toStr(txt.y));
        }
      }

      if (this._normals) {
        final norm = vertex.normal;
        if (norm != null) {
          this._lines.add('vn ' + this._toStr(norm.dx) + ' ' + this._toStr(norm.dy) + ' ' + this._toStr(norm.dz));
        }
      }
    }
    this._totalVertices += vertexCount;
    final faceCount = shape.faces.length;
    for (int i = 0; i < faceCount; i++) {
      final face = shape.faces[i];
      final v1 = (face.vertex1?.index ?? 0) + offset;
      final v2 = (face.vertex2?.index ?? 0) + offset;
      final v3 = (face.vertex3?.index ?? 0) + offset;
      if (this._texture) {
        if (this._normals) {
          this._lines.add('f ${v1}/${v1}/${v1} ${v2}/${v2}/${v2} ${v3}/${v3}/${v3}');
        } else {
          this._lines.add('f ${v1}/${v1} ${v2}/${v2} ${v3}/${v3}');
        }
      } else {
        if (this._normals) {
          this._lines.add('f ${v1}//${v1} ${v2}//${v2} ${v3}//${v3}');
        } else {
          this._lines.add('f ${v1} ${v2} ${v3}');
        }
      }
    }
  }
}

/// Entity reader and writer for *.obj files.
/// @see https://en.wikipedia.org/wiki/Wavefront_.obj_file
class ObjType {
  ObjType._();

  /// Loads a *.obj from the given [fileName].
  /// [txtLoader] is used to load any textures required by materials for this entity.
  /// [strict] is optional and will print errors for unknown line types.
  static Future<Entity> fromFile(String fileName, TextureLoader txtLoader,
      {bool strict = false, Map<String, MaterialLight>? mtls, Event? progress}) async {
    try {
      final dir = getPathTo(fileName);
      final reader = _objReader(txtLoader, mtls: mtls, progress: progress);
      final data = await HttpRequest.getString(fileName);
      await reader.processMultiline(data, strict: strict, dir: dir);
      progress?.emit(ProgressEventArgs(reader, 100.0, true));
      return reader.entity;
    } on Object catch (e) {
      print('$fileName: $e');
      throw Exception('$fileName: $e');
    }
  }

  /// Writes a *.obj lines as strings with the given entity.
  /// [normal] indicates normal vector is written.
  /// [txtCube] indicates the texture cube coordinates
  /// should be written instead of texture 2D coordinates.
  static List<String> toLines(Entity entity,
      {bool normal = true, bool texture = true, bool txtCube = false, int decimals = 16}) {
    final writer = _objWriter(normal, texture, txtCube, decimals);
    writer.addEntity(entity);
    return writer.lines;
  }
}

/// An object to store vertices in while loading objects.
class _objVertex {
  /// The location of the vertex.
  Point3 pos;

  /// All the vertices for this location.
  /// Vertices will have unique normal and texture coordinates.
  List<Vertex> verts;

  /// Creates a new vertex store for the given location, [pos].
  _objVertex(this.pos) : this.verts = [];
}

/// Entity loader for loading *.obj files.
class _objReader {
  /// The texture loader to load all required images with.
  final TextureLoader _txtLoader;

  /// The list of locations paired with created objects.
  final List<_objVertex> _posList;

  /// The list of 2D texture coordinates.
  final List<Point2> _texList;

  /// The list of normal vectors.
  final List<Vector3> _normList;

  /// The map of material names to loaded material techniques.
  final Map<String, MaterialLight> _mtls;

  /// The event to fire to update the progress with.
  final Event? _progress;

  /// The current name of the object part being loaded.
  String _name;

  /// The current material technique for the object being loaded.
  MaterialLight? _mat;

  /// The current shape being loaded for the current part of the object.
  Shape? _shape;

  /// The current entity for the shape being loaded.
  Entity? _entity;

  /// The root entity for the whole object containing other entities.
  final Entity _rootEntity;

  /// Creates a new object loader.
  _objReader(this._txtLoader, {Map<String, MaterialLight>? mtls, Event? progress})
      : this._posList = [],
        this._texList = [],
        this._normList = [],
        this._mtls = {},
        this._progress = progress,
        this._name = '',
        this._mat = null,
        this._shape = null,
        this._entity = null,
        this._rootEntity = Entity() {
    this._mat = MaterialLight()
      ..ambient.color = Color3.gray(0.35)
      ..diffuse.color = Color3.gray(0.65);
    if (mtls != null) this._mtls.addAll(mtls);
    this._startShape();
  }

  /// Gets the entity containing the object which was loaded.
  /// The entity may be on it's own or it may contain many entities.
  Entity get entity {
    if (this._rootEntity.children.length == 1) return this._rootEntity.children[0];
    return this._rootEntity;
  }

  /// Processes multiple lines of a *.obj file.
  Future<void> processMultiline(String data, {bool strict = false, String dir = ''}) async {
    await this.processLines(data.split('\n'), strict: strict, dir: dir);
  }

  /// Processes a list of lines of a *.obj file.
  Future<void> processLines(List<String> lines, {bool strict = false, String dir = ''}) async {
    for (int i = 0; i < lines.length; ++i) {
      final progress = this._progress;
      if ((progress != null) && ((i % 1000) == 0)) {
        progress.emit(ProgressEventArgs(this, i * 100.0 / lines.length, false));
      }
      try {
        await this.processLine(lines[i], strict: strict, dir: dir);
      } on Object catch (e) {
        throw Exception('Line ${i + 1}: $e');
      }
    }
  }

  /// Processes a single line of a *.obj file.
  Future<void> processLine(String line, {bool strict = false, String dir = ''}) async {
    try {
      // Trim off comments and whitespace.
      final index = line.indexOf('#');
      // ignore: parameter_assignments
      if (index >= 0) line = line.substring(0, index);
      // ignore: parameter_assignments
      line = line.trim();
      if (line.isEmpty) return;
      // Strip off first part of line.
      final parts = _stripFront(line);
      if (parts.isEmpty) return;

      // Determine line type.
      switch (parts[0]) {
        case 'v':
          this._processPos(parts[1]);
          return;
        case 'vt':
          this._processTxt(parts[1]);
          return;
        case 'vn':
          this._processNorm(parts[1]);
          return;
        case 'p':
          this._processPoint(parts[1]);
          return;
        case 'l':
          this._processLine(parts[1]);
          return;
        case 'f':
          this._processFace(parts[1]);
          return;
        case 'mtllib':
          await this._processLoadMtrl(parts[1], dir, strict);
          return;
        case 'usemtl':
          this._processUseMtrl(parts[1]);
          return;
        case 'g':
          this._processGroupName(parts[1]);
          return;
        case 'o':
          this._processObjName(parts[1]);
          return;
        default:
          if (!strict) return;
          throw Exception('Unknown or unsupported line type "${parts[0]}".');
      }
    } on Object catch (e) {
      throw Exception('Line: "$line": $e');
    }
  }

  /// Starts and prepares a new shape and entity if the current one isn't empty.
  void _startShape() {
    var entity = this._entity;
    var shape = this._shape;
    if (entity == null || shape == null || (!shape.vertices.isEmpty)) {
      this._shape = shape = Shape();
      this._entity = entity = Entity(shape: shape);
      this._rootEntity.children.add(entity);
      for (final vec in this._posList) {
        vec.verts.clear();
      }
    }
    entity.technique = this._mat;
    entity.name = this._name;
  }

  /// Process a new vertex position (v) line.
  void _processPos(String data) {
    final list = _getNumbers(data);
    if (list.length < 3) throw Exception('Positions must have at least 3 numbers.');
    if (list.length > 4) throw Exception('Positions must have at most than 4 numbers.');
    if (list.length == 4) {
      if (!Comparer.equals(list[3], 1.0)) {
        throw Exception('Currently, non-one w values in positions are not supported.');
      }
    }
    this._posList.add(_objVertex(Point3.fromList([list[0], list[1], list[2]])));
  }

  /// Process a new vertex texture (vt) line.
  void _processTxt(String data) {
    final list = _getNumbers(data);
    if (list.length < 2) throw Exception('Textures must have at least 2 numbers.');
    if (list.length > 3) throw Exception('Textures must have at most than 3 numbers.');
    if (list.length == 3) {
      if (!Comparer.equals(list[2], 0.0)) {
        throw Exception('Currently, non-zero z values in textures are not supported.');
      }
    }
    this._texList.add(Point2.fromList([list[0], list[1]]));
  }

  /// Process a new vertex normal (vn) line.
  void _processNorm(String data) {
    final list = _getNumbers(data);
    if (list.length != 3) throw Exception('Normals must have exactly 3 numbers.');
    this._normList.add(Vector3.fromList(list));
  }

  /// Adds a new vertex to the current shape.
  /// The [vertexStr] is in the vertex index/texture index/normal index form.
  Vertex _addVertex(String vertexStr) {
    final vertexParts = vertexStr.split('/');
    int posIndex = int.parse(vertexParts[0]);
    final count = this._posList.length;
    if ((posIndex < -count) || (posIndex > count) || (posIndex == 0)) {
      throw Exception('The position index, $posIndex, was out of range [-$count..$count] or 0.');
    }
    if (posIndex < 0) posIndex = count + posIndex + 1;
    posIndex--;
    Point2 txt2D = Point2.zero;
    if (vertexParts.length > 1) {
      final value = vertexParts[1];
      if (value.isNotEmpty) {
        int txtIndex = int.parse(value);
        final count = this._texList.length;
        if ((txtIndex < -count) || (txtIndex > count) || (txtIndex == 0)) {
          throw Exception('The texture index, $txtIndex, was out of range [-$count..$count] or 0.');
        }
        if (txtIndex < 0) txtIndex = count + txtIndex + 1;
        txt2D = this._texList[txtIndex - 1];
      }
    }
    Vector3 norm = Vector3.zero;
    if (vertexParts.length > 2) {
      final value = vertexParts[2];
      if (value.isNotEmpty) {
        int normIndex = int.parse(value);
        final count = this._normList.length;
        if ((normIndex < -count) || (normIndex > count) || (normIndex == 0)) {
          throw Exception('The normal index, $normIndex, was out of range [-$count..$count] or 0.');
        }
        if (normIndex < 0) normIndex = count + normIndex + 1;
        norm = this._normList[normIndex - 1];
      }
    }
    // TODO: Update once the Oct-tree is implements. Until the Oct-tree is implemented
    //       lookup vertex group by index in the list. This may cause repeat vertices.
    final vertGroup = this._posList[posIndex];
    for (final vertex in vertGroup.verts) {
      if ((vertex.texture2D == txt2D) && (vertex.normal == norm)) {
        return vertex;
      }
    }
    final vertex = Vertex();
    vertex.location = vertGroup.pos;
    vertex.texture2D = txt2D;
    vertex.normal = norm;
    this._shape?.vertices.add(vertex);
    vertGroup.verts.add(vertex);
    return vertex;
  }

  /// Process a new point list (p) line.
  void _processPoint(String data) {
    final parts = _sliceLine(data);
    final vertices = <Vertex>[];
    final count = parts.length;
    for (int i = 0; i < count; ++i) {
      vertices.add(this._addVertex(parts[i]));
    }
    this._shape?.points.addList(vertices);
  }

  /// Process a new line list (l) line.
  void _processLine(String data) {
    final parts = _sliceLine(data);
    final vertices = <Vertex>[];
    final count = parts.length;
    for (int i = 0; i < count; ++i) {
      vertices.add(this._addVertex(parts[i]));
    }
    this._shape?.lines.addLines(vertices);
  }

  /// Process a new face list (f) line.
  void _processFace(String data) {
    final parts = _sliceLine(data);
    final vertices = <Vertex>[];
    final count = parts.length;
    for (int i = 0; i < count; ++i) {
      vertices.add(this._addVertex(parts[i]));
    }
    this._shape?.faces.addFan(vertices);
  }

  /// Process a new material loading (mtllib) line.
  Future<void> _processLoadMtrl(String data, String dir, bool strict) async {
    final file = joinPath(dir, data);
    final mtls = await MtlType.fromFile(file, this._txtLoader, strict: strict);
    this._mtls.addAll(mtls);
  }

  /// Process a new use material (usemtl) line.
  void _processUseMtrl(String data) {
    this._mat = this._mtls[data];
    this._startShape();
  }

  /// Process a new object name (o) line.
  void _processObjName(String data) {
    this._name = data;
    this._startShape();
  }

  /// Process a new group name (g) line.
  void _processGroupName(String data) {
    this._name = data;
    this._startShape();
  }
}

/// MaterialLight technique reader and writer for *.mtl files.
/// @see https://en.wikipedia.org/wiki/Wavefront_.obj_file#Material_template_library
class MtlType {
  MtlType._();

  /// Loads a *.mtl from the given [fileName].
  /// [txtLoader] is used to load any textures required by this material.
  /// [strict] is optional and will print errors for unknown line types.
  static Future<Map<String, MaterialLight>> fromFile(String fileName, TextureLoader txtLoader,
      {bool strict = false}) async {
    try {
      final dir = getPathTo(fileName);
      final loader = _mtlReader(txtLoader);
      final data = await HttpRequest.getString(fileName);
      await loader.processMultiline(data, strict: strict, dir: dir);
      return loader.materials;
    } on Object catch (e) {
      print("$fileName: $e");
      throw Exception("$fileName: $e");
    }
  }
}

/// MaterialLight technique loader for loading *.mtl files.
/// @see https://en.wikipedia.org/wiki/Wavefront_.obj_file#Material_template_library
class _mtlReader {
  /// The texture loader to load all required images with.
  final TextureLoader? _txtLoader;

  /// The map of material names to materials which have been loaded.
  final Map<String, MaterialLight> _mtls;

  /// The material currently being loaded.
  MaterialLight? _cur;

  /// Creates a new material loader.
  _mtlReader(this._txtLoader)
      : this._mtls = {},
        this._cur = null;

  /// The map of material names to materials which have been loaded.
  Map<String, MaterialLight> get materials => this._mtls;

  /// Processes multiple lines of a *.mtl file.
  Future<void> processMultiline(String data, {bool strict = false, String dir = ''}) async {
    await this.processLines(data.split('\n'), strict: strict, dir: dir);
  }

  /// Processes a list of lines of a *.mtl file.
  Future<void> processLines(List<String> lines, {bool strict = false, String dir = ''}) async {
    for (int i = 0; i < lines.length; ++i) {
      try {
        await this.processLine(lines[i], strict: strict, dir: dir);
      } on Object catch (e) {
        throw Exception('Line ${i + 1}: $e');
      }
    }
  }

  /// Processes a single line of a *.mtl file.
  Future<void> processLine(String line, {bool strict = false, String dir = ''}) async {
    try {
      // Trim off comments and whitespace.
      final index = line.indexOf('#');
      // ignore: parameter_assignments
      if (index >= 0) line = line.substring(0, index);
      // ignore: parameter_assignments
      line = line.trim();
      if (line.isEmpty) return;
      // Strip off first part of line.
      final parts = _stripFront(line);
      if (parts.isEmpty) return;
      // Determine line type.
      switch (parts[0]) {
        case 'newmtl':
          this._processNewMaterial(parts[1]);
          return;
        case 'Ka':
          this._processAmbient(parts[1]);
          return;
        case 'Kd':
          this._processDiffuse(parts[1]);
          return;
        case 'Ks':
          this._processSpecular(parts[1]);
          return;
        case 'Ns':
          this._processShininess(parts[1]);
          return;
        case 'd':
          this._processAlpha(parts[1]);
          return;
        case 'Tr':
          this._processTransparency(parts[1]);
          return;
        case 'map_Ka':
          await this._processAmbientMap(parts[1], dir);
          return;
        case 'map_Kd':
          await this._processDiffuseMap(parts[1], dir);
          return;
        case 'map_Ks':
          await this._processSpecularMap(parts[1], dir);
          return;
        case 'map_d':
          await this._processAlphaMap(parts[1], dir);
          return;
        case 'map_bump':
          await this._processBumpMap(parts[1], dir);
          return;
        case 'bump':
          await this._processBumpMap(parts[1], dir);
          return;
        default:
          if (!strict) return;
          throw Exception('Unknown or unsupported line type \'${parts[0]}\'.');
      }
    } on Object catch (e) {
      throw Exception('Line: \'$line\': $e');
    }
  }

  /// processes a new material (newmtl) line of a *.mtl file.
  void _processNewMaterial(String data) => this._mtls[data] = this._cur = MaterialLight();

  /// processes a new ambient colors (Ka) line of a *.mtl file.
  void _processAmbient(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    cur.ambient.color = Color3.fromList(vals);
  }

  /// processes a new diffuse colors (Kd) line of a *.mtl file.
  void _processDiffuse(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    cur.diffuse.color = Color3.fromList(vals);
  }

  /// processes a new specular colors (Ks) line of a *.mtl file.
  void _processSpecular(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    cur.specular.color = Color3.fromList(vals);
  }

  /// processes a new shininess (Ns) line of a *.mtl file.
  void _processShininess(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    if (vals.length != 1) throw Exception('Shininess may only have 1 number.');
    cur.specular.shininess = vals[0];
  }

  /// processes a new alpha (d) line of a *.mtl file.
  void _processAlpha(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    if (vals.length != 1) throw Exception('Alpha may only have 1 number.');
    cur.alpha.value = vals[0];
  }

  /// processes a new transparency (Tr) line of a *.mtl file.
  void _processTransparency(String data) {
    final cur = this._cur;
    if (cur == null) return;
    final vals = _getNumbers(data);
    if (vals.length != 1) throw Exception('Alpha may only have 1 number.');
    cur.alpha.value = 1.0 - vals[0];
  }

  /// processes a new ambient map (map_Ka) line of a *.mtl file.
  Future<void> _processAmbientMap(String data, String dir) async {
    final cur = this._cur;
    final txtLoader = this._txtLoader;
    if (cur == null || txtLoader == null) return;
    final file = joinPath(dir, data);
    cur.ambient.texture2D = txtLoader.load2DFromFile(file);
  }

  /// processes a new diffuse map (map_Kd) line of a *.mtl file.
  Future<void> _processDiffuseMap(String data, String dir) async {
    final cur = this._cur;
    final txtLoader = this._txtLoader;
    if (cur == null || txtLoader == null) return;
    final file = joinPath(dir, data);
    this._cur?.diffuse.texture2D = txtLoader.load2DFromFile(file);
  }

  /// processes a new specular map (map_Ks) line of a *.mtl file.
  Future<void> _processSpecularMap(String data, String dir) async {
    final cur = this._cur;
    final txtLoader = this._txtLoader;
    if (cur == null || txtLoader == null) return;
    final file = joinPath(dir, data);
    this._cur?.specular.texture2D = txtLoader.load2DFromFile(file);
  }

  /// processes a new alpha map (map_d) line of a *.mtl file.
  Future<void> _processAlphaMap(String data, String dir) async {
    final cur = this._cur;
    final txtLoader = this._txtLoader;
    if (cur == null || txtLoader == null) return;
    final file = joinPath(dir, data);
    this._cur?.alpha.texture2D = txtLoader.load2DFromFile(file);
  }

  /// processes a new bump map (map_bump/bump) line of a *.mtl file.
  Future<void> _processBumpMap(String data, String dir) async {
    final cur = this._cur;
    final txtLoader = this._txtLoader;
    if (cur == null || txtLoader == null) return;
    final file = joinPath(dir, data);
    this._cur?.bump.texture2D = txtLoader.load2DFromFile(file);
  }
}
