import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:wikiscrolls_frontend/config/env.dart';

/// Service for Text-to-Speech using Gemini 2.5 Flash TTS API.
/// Converts article text to natural speech audio.
class TtsService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash-preview-tts';
  
  // Available voices - using an informative, clear voice for articles
  static const String _defaultVoice = 'Charon'; // Informative voice
  
  /// Available voice options from Gemini TTS:
  /// Bright: Zephyr, Autonoe
  /// Upbeat: Puck, Laomedeia
  /// Informative: Charon, Rasalgethi
  /// Firm: Kore, Orus, Alnilam
  /// Excitable: Fenrir
  /// Youthful: Leda
  /// Breezy: Aoede
  /// Easy-going: Callirrhoe, Umbriel
  /// Breathy: Enceladus
  /// Clear: Iapetus, Erinome
  /// Smooth: Algieba, Despina
  /// Gravelly: Algenib
  /// Soft: Achernar
  /// Even: Schedar
  /// Mature: Gacrux
  /// Forward: Pulcherrima
  /// Friendly: Achird
  /// Casual: Zubenelgenubi
  /// Gentle: Vindemiatrix
  /// Lively: Sadachbia
  /// Knowledgeable: Sadaltager
  /// Warm: Sulafat

  /// Generates speech audio from text using Gemini TTS.
  /// Returns raw PCM audio data (24kHz, 16-bit, mono) or null on failure.
  Future<Uint8List?> generateSpeech(String text, {String? voiceName}) async {
    if (text.isEmpty) return null;
    
    // Truncate very long text to avoid token limits (32k tokens max)
    // Rough estimate: 1 token ≈ 4 characters
    final truncatedText = text.length > 50000 ? text.substring(0, 50000) : text;
    
    final url = '$_baseUrl/models/$_model:generateContent?key=${Env.ttsApiKey}';
    
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': 'Read this article clearly and engagingly:\n\n$truncatedText'
            }
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {
              'voiceName': voiceName ?? _defaultVoice,
            }
          }
        }
      }
    });

    try {
      if (kDebugMode) {
        print('[TtsService] Generating speech for ${truncatedText.length} chars...');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 60)); // TTS can take a while

      if (kDebugMode) {
        print('[TtsService] Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract audio data from response
        // Response format: {candidates: [{content: {parts: [{inlineData: {mimeType, data}}]}}]}
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          if (kDebugMode) print('[TtsService] No candidates in response');
          return null;
        }
        
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          if (kDebugMode) print('[TtsService] No parts in response');
          return null;
        }
        
        final inlineData = parts[0]['inlineData'] as Map<String, dynamic>?;
        if (inlineData == null) {
          if (kDebugMode) print('[TtsService] No inlineData in response');
          return null;
        }
        
        final base64Audio = inlineData['data'] as String?;
        final mimeType = inlineData['mimeType'] as String?;
        
        if (kDebugMode) {
          print('[TtsService] Got audio data, mimeType: $mimeType');
        }
        
        if (base64Audio != null) {
          return base64Decode(base64Audio);
        }
      } else {
        if (kDebugMode) {
          print('[TtsService] Error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TtsService] Exception: $e');
      }
    }
    
    return null;
  }
  
  /// List of available voices with their characteristics
  static const Map<String, String> voices = {
    'Charon': 'Informative',
    'Rasalgethi': 'Informative',
    'Sadaltager': 'Knowledgeable',
    'Puck': 'Upbeat',
    'Zephyr': 'Bright',
    'Kore': 'Firm',
    'Aoede': 'Breezy',
    'Sulafat': 'Warm',
    'Achird': 'Friendly',
    'Gacrux': 'Mature',
  };
}
