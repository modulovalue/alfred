import 'package:alfred/crdt/cachapa_hlc.dart';
import 'package:test/test.dart';

void main() {
  group('Constructors', () {
    final hlc = HlcImpl(_millis, 0x42, 'abc');
    test('default', () {
      expect(hlc.millis, _millis);
      expect(hlc.counter, 0x42);
      expect(hlc.nodeId, 'abc');
    });
    test('default with microseconds', () {
      expect(HlcImpl(_millis * 1000, 0x42, 'abc'), hlc);
    });
    test('zero', () {
      expect(zeroHlc('abc'), hlc.apply(millis: 0, counter: 0));
    });
    test('from date', () {
      expect(
        fromDateHlc(DateTime.parse(_isoTime), 'abc'),
        hlc.apply(counter: 0),
      );
    });
    test('logical time', () {
      expect(fromLogicalTimeHlc(_logicalTime, 'abc'), hlc);
    });
    test('parse', () {
      expect(parseHlc('$_isoTime-0042-abc'), hlc);
    });
  });
  group('String operations', () {
    test('hlc to string', () {
      final hlc = parseHlc('$_isoTime-0042-abc');
      expect(hlc.toString(), '$_isoTime-0042-abc');
    });
    test('Parse hlc', () {
      expect(
        parseHlc('$_isoTime-0042-abc'),
        HlcImpl(_millis, 0x42, 'abc'),
      );
    });
  });
  group('Comparison', () {
    test('Equality', () {
      final hlc1 = parseHlc('$_isoTime-0042-abc');
      final hlc2 = parseHlc('$_isoTime-0042-abc');
      expect(hlc1, hlc2);
      expect(hlc1 <= hlc2, isTrue);
      expect(hlc1 >= hlc2, isTrue);
    });
    test('Different node ids', () {
      final hlc1 = parseHlc('$_isoTime-0042-abc');
      final hlc2 = parseHlc('$_isoTime-0042-abcd');
      expect(hlc1, isNot(hlc2));
    });
    test('Less than millis', () {
      final hlc1 = HlcImpl(_millis, 0x42, 'abc');
      final hlc2 = HlcImpl(_millis + 1, 0, 'abc');
      expect(hlc1 < hlc2, isTrue);
      expect(hlc1 <= hlc2, isTrue);
    });
    test('Less than counter', () {
      final hlc1 = parseHlc('$_isoTime-0042-abc');
      final hlc2 = parseHlc('$_isoTime-0043-abc');
      expect(hlc1 < hlc2, isTrue);
      expect(hlc1 <= hlc2, isTrue);
    });
    test('Less than node id', () {
      final hlc1 = parseHlc('$_isoTime-0042-abc');
      final hlc2 = parseHlc('$_isoTime-0042-abb');
      expect(hlc1 > hlc2, isTrue);
      expect(hlc1 >= hlc2, isTrue);
    });
    test('Fail less than if equals', () {
      final hlc1 = parseHlc('$_isoTime-0042-abc');
      final hlc2 = parseHlc('$_isoTime-0042-abc');
      expect(hlc1 < hlc2, isFalse);
    });
    test('Fail less than if millis and counter disagree', () {
      final hlc1 = HlcImpl(_millis + 1, 0, 'abc');
      final hlc2 = HlcImpl(_millis, 0x42, 'abc');
      expect(hlc1 < hlc2, isFalse);
    });
    test('More than millis', () {
      final hlc1 = HlcImpl(_millis + 1, 0x42, 'abc');
      final hlc2 = HlcImpl(_millis, 0, 'abc');
      expect(hlc1 > hlc2, isTrue);
      expect(hlc1 >= hlc2, isTrue);
    });
    test('More than counter', () {
      final hlc1 = HlcImpl(_millis + 1, 0x42, 'abc');
      final hlc2 = HlcImpl(_millis, 0, 'abc');
      expect(hlc1 > hlc2, isTrue);
      expect(hlc1 >= hlc2, isTrue);
    });
    test('More than node id', () {
      final hlc1 = HlcImpl(_millis, 0x42, 'abc');
      final hlc2 = HlcImpl(_millis, 0x42, 'abb');
      expect(hlc1 > hlc2, isTrue);
      expect(hlc1 >= hlc2, isTrue);
    });
    test('Compare', () {
      final hlc = HlcImpl(_millis, 0x42, 'abc');
      expect(hlc.compareTo(HlcImpl(_millis, 0x42, 'abc')), 0);
      expect(hlc.compareTo(HlcImpl(_millis + 1, 0x42, 'abc')), -1);
      expect(hlc.compareTo(HlcImpl(_millis, 0x43, 'abc')), -1);
      expect(hlc.compareTo(HlcImpl(_millis, 0x42, 'abd')), -1);
      expect(hlc.compareTo(HlcImpl(_millis - 1, 0x42, 'abc')), 1);
      expect(hlc.compareTo(HlcImpl(_millis, 0x41, 'abc')), 1);
      expect(hlc.compareTo(HlcImpl(_millis, 0x42, 'abb')), 1);
    });
  });
  group('Logical time representation', () {
    test('Logical time stability', () {
      final hlc = fromLogicalTimeHlc(_logicalTime, 'abc');
      expect(hlc.logicalTime, _logicalTime);
    });
    test('Hlc as logical time', () {
      final hlc = parseHlc('$_isoTime-0042-abc');
      expect(hlc.logicalTime, _logicalTime);
    });
    test('Hlc from logical time', () {
      final hlc = parseHlc('$_isoTime-0042-abc');
      expect(fromLogicalTimeHlc(_logicalTime, 'abc'), hlc);
    });
  });
  group('Send', () {
    test('Higher canonical time', () {
      final hlc = HlcImpl(_millis + 1, 0x42, 'abc');
      final _sendHlc = sendHlc(hlc, millis: _millis);
      expect(_sendHlc, isNot(hlc));
      expect(_sendHlc.millis, hlc.millis);
      expect(_sendHlc.counter, 0x43);
      expect(_sendHlc.nodeId, hlc.nodeId);
    });
    test('Equal canonical time', () {
      final hlc = HlcImpl(_millis, 0x42, 'abc');
      final _sendHlc = sendHlc(hlc, millis: _millis);
      expect(_sendHlc, isNot(hlc));
      expect(_sendHlc.millis, _millis);
      expect(_sendHlc.counter, 0x43);
      expect(_sendHlc.nodeId, hlc.nodeId);
    });
    test('Lower canonical time', () {
      final hlc = HlcImpl(_millis - 1, 0x42, 'abc');
      final _sendHlc = sendHlc(hlc, millis: _millis);
      expect(_sendHlc, isNot(hlc));
      expect(_sendHlc.millis, _millis);
      expect(_sendHlc.counter, 0);
      expect(_sendHlc.nodeId, hlc.nodeId);
    });
    test('Fail on clock drift', () {
      final hlc = HlcImpl(_millis + 60001, 0, 'abc');
      expect(() => sendHlc(hlc, millis: _millis), throwsA(isA<ClockDriftException>()));
    });
    test('Fail on counter overflow', () {
      final hlc = HlcImpl(_millis, 0xFFFF, 'abc');
      expect(() => sendHlc(hlc, millis: _millis), throwsA(isA<OverflowException>()));
    });
  });
  group('Receive', () {
    final canonical = parseHlc('$_isoTime-0042-abc');
    test('Higher canonical time', () {
      final remote = HlcImpl(_millis - 1, 0x42, 'abcd');
      final hlc = receiveHlc(canonical, remote, millis: _millis);
      expect(hlc, equals(canonical));
    });
    test('Same remote time', () {
      final remote = HlcImpl(_millis, 0x42, 'abcd');
      final hlc = receiveHlc(canonical, remote, millis: _millis);
      expect(hlc, HlcImpl(remote.millis, remote.counter, canonical.nodeId));
    });
    test('Higher remote time', () {
      final remote = HlcImpl(_millis + 1, 0, 'abcd');
      final hlc = receiveHlc(canonical, remote, millis: _millis);
      expect(hlc, HlcImpl(remote.millis, remote.counter, canonical.nodeId));
    });
    test('Higher wall clock time', () {
      final remote = parseHlc('$_isoTime-0000-abcd');
      final hlc = receiveHlc(canonical, remote, millis: _millis + 1);
      expect(hlc, canonical);
    });
    test('Skip node id check if time is lower', () {
      final remote = HlcImpl(_millis - 1, 0x42, 'abc');
      expect(receiveHlc(canonical, remote, millis: _millis), canonical);
    });
    test('Skip node id check if time is same', () {
      final remote = HlcImpl(_millis, 0x42, 'abc');
      expect(receiveHlc(canonical, remote, millis: _millis), canonical);
    });
    test('Fail on node id', () {
      final remote = HlcImpl(_millis + 1, 0, 'abc');
      expect(
        () => receiveHlc(canonical, remote, millis: _millis),
        throwsA(isA<DuplicateNodeException>()),
      );
    });
    test('Fail on clock drift', () {
      final remote = HlcImpl(_millis + 60001, 0x42, 'abcd');
      expect(
        () => receiveHlc(canonical, remote, millis: _millis),
        throwsA(isA<ClockDriftException>()),
      );
    });
  });
}

const int _millis = 1000000000000;
const String _isoTime = '2001-09-09T01:46:40.000Z';
// ignore: avoid_js_rounded_ints
const int _logicalTime = 65536000000000066;
