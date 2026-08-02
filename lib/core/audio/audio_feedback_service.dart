import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plays short audio cues for in-app answer feedback.
class AudioFeedbackService {
  AudioFeedbackService() : _player = AudioPlayer();

  final AudioPlayer _player;

  /// Encouraging voice line played when the user answers correctly in
  /// Practice mode. Plays the English take when [isEnglish] is true, else
  /// the Arabic take.
  Future<void> playCorrectAnswerSound({bool isEnglish = false}) async {
    await _player.play(
      AssetSource(
        isEnglish ? 'sounds/correct_answer_en.mp3' : 'sounds/correct_answer_voice.mp3',
      ),
    );
  }

  /// Voice line played when the user answers incorrectly in Practice mode.
  /// Plays the English take when [isEnglish] is true, else the Arabic take.
  Future<void> playWrongAnswerSound({bool isEnglish = false}) async {
    await _player.play(
      AssetSource(
        isEnglish ? 'sounds/wrong_answer_en.mp3' : 'sounds/wrong_answer_voice.mp3',
      ),
    );
  }

  void dispose() {
    _player.dispose();
  }
}

final audioFeedbackServiceProvider = Provider<AudioFeedbackService>((ref) {
  final service = AudioFeedbackService();
  ref.onDispose(service.dispose);
  return service;
});
