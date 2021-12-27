/// Deserializes a previous serialized string of data.
class Deserializer {
  int _index = 0;
  final String _data;

  /// Creates a new deserializer with the given data.
  Deserializer(
    final this._data,
  );

  /// Gets the serialized string of data.
  @override
  String toString() => this._data.substring(0, this._index) + '•' + this._data.substring(this._index);

  /// Indicates if the deserializer has reached the end.
  bool get hasMore => this._index < this._data.length;

  /// Checks if the end of the data has been reached.
  void _eofException() {
    if (!this.hasMore) {
      throw Exception('Unexpected end of serialized data');
    }
  }

  /// Reads a Boolean from the data.
  bool readBool() {
    this._eofException();
    final c = this._data[this._index];
    this._index++;
    if (c == 'T') {
      return true;
    }
    if (c == 'F') {
      return false;
    }
    throw Exception('Expected T or F but got $c');
  }

  /// Reads an integer from the data.
  int readInt() {
    this._eofException();
    final int start = this._index;
    for (; this._index < this._data.length; this._index++) {
      if (this._data[this._index] == ' ') {
        break;
      }
    }
    this._index++;
    final value = this._data.substring(start, this._index - 1);
    return int.parse(value);
  }

  /// Reads a string from the data.
  String readStr() {
    final length = this.readInt();
    final start = this._index;
    this._index += length;
    return this._data.substring(start, start + length);
  }

  /// Reads a serialization from the data.
  Deserializer readSer() {
    final data = this.readStr();
    return Deserializer(data);
  }

  /// Reads a list of integers from the data.
  List<int> readIntList() {
    final count = this.readInt();
    final list = <int>[];
    for (int i = 0; i < count; i++) {
      list.add(this.readInt());
    }
    return list;
  }

  /// Reads a list of strings from the data.
  List<String> readStrList() {
    final count = this.readInt();
    final list = <String>[];
    for (int i = 0; i < count; i++) {
      list.add(this.readStr());
    }
    return list;
  }

  /// Reads a map of strings to strings from the data.
  Map<String, String> readStringStringMap() {
    final map = <String, String>{};
    final count = this.readInt();
    for (int i = 0; i < count; i++) {
      final key = this.readStr();
      final value = this.readStr();
      map[key] = value;
    }
    return map;
  }
}

/// This is a simple serializer designed for fast serialization and deserialization.
class Serializer {
  final StringBuffer _data = StringBuffer();

  /// Creates a new serializer.
  Serializer();

  /// Gets the serialized string of data.
  @override
  String toString() => this._data.toString();

  /// Writes a Boolean to the data.
  void writeBool(bool value) => this._data.write(value ? 'T' : 'F');

  /// Writes an integer to the data.
  void writeInt(int value) => this._data.write('$value ');

  /// Writes a string to the data.
  void writeStr(String value) => this._data.write('${value.length} $value');

  /// Writes another serializer to the data.
  void writeSer(Serializer? value) => this.writeStr(value?._data.toString() ?? '');

  /// Writes a list of integers to the data.
  void writeIntList(List<int> value) {
    this.writeInt(value.length);
    // ignore: prefer_foreach
    for (final intVal in value) {
      this.writeInt(intVal);
    }
  }

  /// Writes a list of strings to the data.
  void writeStrList(
    final List<String> value,
  ) {
    this.writeInt(value.length);
    // ignore: prefer_foreach
    for (final strVal in value) {
      this.writeStr(strVal);
    }
  }

  /// Writes a map of strings to strings to the data.
  void writeStringStringMap(
    final Map<String, String> value,
  ) {
    this.writeInt(value.length);
    for (final key in value.keys) {
      this.writeStr(key);
      this.writeStr(value[key] ?? '');
    }
  }
}
