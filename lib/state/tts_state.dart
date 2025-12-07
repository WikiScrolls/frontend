import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../api/tts_service.dart';
import '../api/article_service.dart';
import '../api/models/article.dart';

/// State manager for Text-to-Speech playback.
/// Handles audio generation, caching, and playback control.
class TtsState extends ChangeNotifier {
  final TtsService _ttsService = TtsService();
  final ArticleService _articleService = ArticleService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Cache generated audio by article ID to avoid re-generating
  final Map<String, String> _audioCache = {}; // articleId -> file path
  
  String? _currentArticleId;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isEnabled = true; // User can toggle TTS on/off
  String? _error;
  
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isEnabled => _isEnabled;
  String? get error => _error;
  String? get currentArticleId => _currentArticleId;
  
  TtsState() {
    _audioPlayer.playerStateStream.listen((state) {
      final wasPlaying = _isPlaying;
      _isPlaying = state.playing;
      if (wasPlaying != _isPlaying) {
        notifyListeners();
      }
    });
    
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _isPlaying = false;
        notifyListeners();
      }
    });
  }
  
  /// Toggle TTS on/off
  void toggleEnabled() {
    _isEnabled = !_isEnabled;
    if (!_isEnabled) {
      stop();
    }
    notifyListeners();
  }
  
  /// Set TTS enabled state
  void setEnabled(bool enabled) {
    if (_isEnabled != enabled) {
      _isEnabled = enabled;
      if (!_isEnabled) {
        stop();
      }
      notifyListeners();
    }
  }
  
  /// Play TTS for an article. Checks for existing audioUrl in DB first.
  /// If not available, generates via AI and saves to DB.
  Future<void> playArticleFromModel(ArticleModel article) async {
    if (!_isEnabled) return;
    
    final articleId = article.id;
    final articleText = article.content ?? '';
    
    if (articleText.isEmpty && article.audioUrl == null) return;
    
    // If same article is already playing, do nothing
    if (_currentArticleId == articleId && _isPlaying) return;
    
    // Stop any current playback
    await stop();
    
    _currentArticleId = articleId;
    _error = null;
    _isLoading = true;
    notifyListeners();
    
    try {
      String? audioPath = _audioCache[articleId];
      
      if (audioPath == null || !await File(audioPath).exists()) {
        // Check if article has existing audioUrl in database
        if (article.audioUrl != null && article.audioUrl!.isNotEmpty) {
          if (kDebugMode) print('[TtsState] Using existing audioUrl from DB for $articleId');
          
          // Download the audio file from URL
          audioPath = await _downloadAudioFile(articleId, article.audioUrl!);
        }
        
        // If still no audio, generate new audio via AI
        if (audioPath == null && articleText.isNotEmpty) {
          if (kDebugMode) print('[TtsState] Generating new audio for article $articleId');
          
          final audioData = await _ttsService.generateSpeech(articleText);
          
          if (audioData == null) {
            _error = 'Failed to generate speech';
            _isLoading = false;
            notifyListeners();
            return;
          }
          
          // Save to temp file for playback
          audioPath = await _saveAudioToFile(articleId, audioData);
          
          // Upload to backend and save URL to database (fire and forget)
          if (audioPath != null) {
            _uploadAndSaveAudioUrl(articleId, audioData);
          }
        }
        
        if (audioPath != null) {
          _audioCache[articleId] = audioPath;
        }
      }
      
      if (audioPath != null) {
        // Play the audio
        await _audioPlayer.setFilePath(audioPath);
        await _audioPlayer.play();
        _isPlaying = true;
      }
    } catch (e) {
      if (kDebugMode) print('[TtsState] Error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Legacy method for backward compatibility - just plays text without DB caching
  Future<void> playArticle(String articleId, String articleText) async {
    // Create a minimal article model for the new method
    final article = ArticleModel(id: articleId, title: '', content: articleText);
    await playArticleFromModel(article);
  }
  
  /// Download audio file from URL and save locally
  Future<String?> _downloadAudioFile(String articleId, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/tts_$articleId.wav';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) print('[TtsState] Downloaded audio to $filePath');
        return filePath;
      }
    } catch (e) {
      if (kDebugMode) print('[TtsState] Failed to download audio: $e');
    }
    return null;
  }
  
  /// Upload generated audio to backend and save URL to article (fire and forget)
  void _uploadAndSaveAudioUrl(String articleId, Uint8List audioData) async {
    try {
      // Convert PCM to WAV for upload
      final wavData = _createWavFile(audioData);
      
      // Upload to backend
      final audioUrl = await _articleService.uploadAudio(articleId, wavData);
      
      if (audioUrl != null) {
        // Save URL to article in database
        await _articleService.updateArticle(articleId, audioUrl: audioUrl);
        if (kDebugMode) print('[TtsState] Saved audioUrl to DB: $audioUrl');
      }
    } catch (e) {
      if (kDebugMode) print('[TtsState] Failed to upload/save audio: $e');
    }
  }
  
  /// Save raw PCM audio data to a WAV file
  Future<String?> _saveAudioToFile(String articleId, Uint8List pcmData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/tts_$articleId.wav';
      final file = File(filePath);
      
      // Convert raw PCM to WAV format
      // Gemini TTS returns 24kHz, 16-bit, mono PCM
      final wavData = _createWavFile(pcmData);
      await file.writeAsBytes(wavData);
      
      if (kDebugMode) print('[TtsState] Saved audio to $filePath');
      return filePath;
    } catch (e) {
      if (kDebugMode) print('[TtsState] Failed to save audio: $e');
      return null;
    }
  }
  
  /// Create WAV file from raw PCM data
  /// Gemini TTS outputs: 24kHz sample rate, 16-bit samples, mono channel
  Uint8List _createWavFile(Uint8List pcmData) {
    const int sampleRate = 24000;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const int blockAlign = numChannels * bitsPerSample ~/ 8;
    
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;
    
    final wavBuffer = ByteData(44 + dataSize);
    
    // RIFF header
    wavBuffer.setUint8(0, 0x52); // 'R'
    wavBuffer.setUint8(1, 0x49); // 'I'
    wavBuffer.setUint8(2, 0x46); // 'F'
    wavBuffer.setUint8(3, 0x46); // 'F'
    wavBuffer.setUint32(4, fileSize, Endian.little);
    wavBuffer.setUint8(8, 0x57);  // 'W'
    wavBuffer.setUint8(9, 0x41);  // 'A'
    wavBuffer.setUint8(10, 0x56); // 'V'
    wavBuffer.setUint8(11, 0x45); // 'E'
    
    // fmt subchunk
    wavBuffer.setUint8(12, 0x66); // 'f'
    wavBuffer.setUint8(13, 0x6D); // 'm'
    wavBuffer.setUint8(14, 0x74); // 't'
    wavBuffer.setUint8(15, 0x20); // ' '
    wavBuffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    wavBuffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    wavBuffer.setUint16(22, numChannels, Endian.little);
    wavBuffer.setUint32(24, sampleRate, Endian.little);
    wavBuffer.setUint32(28, byteRate, Endian.little);
    wavBuffer.setUint16(32, blockAlign, Endian.little);
    wavBuffer.setUint16(34, bitsPerSample, Endian.little);
    
    // data subchunk
    wavBuffer.setUint8(36, 0x64); // 'd'
    wavBuffer.setUint8(37, 0x61); // 'a'
    wavBuffer.setUint8(38, 0x74); // 't'
    wavBuffer.setUint8(39, 0x61); // 'a'
    wavBuffer.setUint32(40, dataSize, Endian.little);
    
    // Copy PCM data
    final wavBytes = wavBuffer.buffer.asUint8List();
    for (int i = 0; i < dataSize; i++) {
      wavBytes[44 + i] = pcmData[i];
    }
    
    return wavBytes;
  }
  
  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }
  
  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
  }
  
  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }
  
  /// Clear cache and free resources
  Future<void> clearCache() async {
    await stop();
    for (final path in _audioCache.values) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    _audioCache.clear();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
