import 'dart:html' as html;

import '../events/events.dart';
import '../math/math.dart';

/// A loader for loading sounds.
class AudioLoader {
  int _soundCount;
  int _loadedCount;

  /// Creates a new audio loader.
  AudioLoader()
      : this._soundCount = 0,
        this._loadedCount = 0;

  /// The number of sounds being loaded.
  int get loading => this._soundCount - this._loadedCount;

  /// The percentage of sounds loaded.
  double get percentage {
    if (this._soundCount == 0) return 100.0;
    return this._loadedCount * 100.0 / this._soundCount;
  }

  /// Resets the loading counters.
  void resetCounter() {
    this._soundCount = 0;
    this._loadedCount = 0;
  }

  /// Handles loading a new audio player with the audio from the given file path.
  Player loadFromFile(
    final String path,
  ) {
    final elem = html.AudioElement(path)
      ..autoplay = false
      ..preload = "auto";
    this._incLoading();
    final player = Player._(elem);
    elem.onLoad.listen((_) {
      player._setLoaded();
      this._decLoading();
    });
    return player;
  }

  /// Increments the loading count.
  void _incLoading() => this._soundCount++;

  /// Decrement the loading count.
  void _decLoading() => this._loadedCount--;
}

/// A multi-player is an audio player which can play the same sound
/// multiple times overlapping each other.
class MultiPlayer {
  final Player _original;
  final List<Player> _players;
  final int _limit;

  /// Creates a player which can play the same sound overlapping each other.
  MultiPlayer(
    final Player player, [
    final int limit = 10,
  ])  : this._original = player,
        this._players = [],
        this._limit = (() {
          if (limit < 1) {
            return 1;
          } else {
            return limit;
          }
        }()) {
    this._players.add(player);
  }

  /// Gets the next player which is currently not playing,
  /// or null if no more players are allowed.
  Player? _getNextPlayer() {
    for (final player in this._players) {
      if (!player.playing) return player;
    }
    if (this._players.length < this._limit) {
      final player = this._original.copy();
      this._players.add(player);
      return player;
    }
    return null;
  }

  /// Plays one of these audios. Returns true if played,
  /// false if all instances are already playing.
  bool play({
    final double? volume,
    final double? rate,
    final bool? loop,
  }) {
    final player = this._getNextPlayer();
    if (player != null && !player.playing) {
      player.play(volume: volume, rate: rate, loop: loop);
      return true;
    } else {
      return false;
    }
  }

  /// Pauses all the audio.
  void pauseAll() {
    for (final player in this._players) {
      if (player.playing) player.pause();
    }
  }
}

/// A player for starting and stopping a sound, music, or any audio.
class Player {
  final html.AudioElement _elem;
  bool _loaded;
  Event? _changed;
  Event? _onPlaying;
  Event? _onPause;

  /// Creates a new audio player.
  Player._(
    final this._elem,
  )   : this._loaded = false,
        this._changed = null,
        this._onPlaying = null,
        this._onPause = null {
    this._elem.onPlaying.listen(this._onElemPlaying);
    this._elem.onPause.listen(this._onElemPause);
  }

  /// Create a copy of this audio player.
  Player copy() => Player._(
        _elem.clone(true) as html.AudioElement,
      );

  /// Sets the loaded state for this audio.
  void _setLoaded() {
    if (!this._loaded) {
      this._loaded = true;
      this._changed?.emit();
    }
  }

  /// Handles the audio element playing.
  void _onElemPlaying(
    final html.Event _,
  ) =>
      this._onPlaying?.emit();

  /// Handles the audio element pausing.
  void _onElemPause(
    final html.Event _,
  ) =>
      this._onPause?.emit();

  /// The loaded state of the audio.
  bool get loaded => this._loaded;

  /// Indicates if this audio is currently playing or not.
  bool get playing => !this._elem.paused;

  /// Indicates if this audio should automatically start playing
  /// again once it is done, the audio will loop.
  bool get loop => this._elem.loop;

  set loop(
    final bool loop,
  ) {
    if (this.loop != loop) {
      this._elem.loop = loop;
      this._changed?.emit();
    }
  }

  /// This is the volume to playback the audio at.
  double get volume => this._elem.volume.toDouble();

  set volume(
    double volume,
  ) {
    // ignore: parameter_assignments
    volume = clampVal(volume);
    if (Comparer.notEquals(this.volume, volume)) {
      this._elem.volume = volume;
      this._changed?.emit();
    }
  }

  /// This is the rate to playback the audio at.
  double get rate => this._elem.playbackRate.toDouble();

  set rate(
    double rate,
  ) {
    // ignore: parameter_assignments
    rate = clampVal(rate, 0.001, 100.0);
    if (Comparer.notEquals(this.rate, rate)) {
      this._elem.playbackRate = rate;
      this._changed?.emit();
    }
  }

  /// Plays this audio.
  void play({
    final double? volume,
    final double? rate,
    final bool? loop,
  }) {
    if (volume != null) this.volume = volume;
    if (rate != null) this.rate = rate;
    if (loop != null) this.loop = loop;
    this._elem.play();
  }

  /// Pauses the audio.
  void pause() => this._elem.pause();

  /// Emitted when the audio has finished being loading.
  Event get changed => this._changed ??= Event();

  /// Emitted when the audio starts playing.
  Event get onPlaying => this._onPlaying ??= Event();

  /// Emitted when the audio has paused.
  Event get onPause => this._onPause ??= Event();
}
