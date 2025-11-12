import 'package:flutter_genui/flutter_genui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logging/logging.dart';

/// Direct Gemini API content generator for GenUI
/// Uses google_generative_ai package instead of Firebase Vertex AI
class GeminiDirectContentGenerator implements ContentGenerator {
  final GenerativeModel _model;
  final String systemInstruction;
  final Logger _logger = Logger('GeminiDirectContentGenerator');

  GeminiDirectContentGenerator({
    required String apiKey,
    required Catalog catalog,
    required this.systemInstruction,
    String modelName = 'gemini-2.0-flash-exp',
  }) : _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          systemInstruction: Content.system(systemInstruction),
          tools: _createToolsFromCatalog(catalog),
        );

  static List<Tool> _createToolsFromCatalog(Catalog catalog) {
    // GenUI provides the tools (surfaceUpdate, beginRendering, provideFinalOutput)
    // This is a simplified implementation - in production you'd map the catalog properly
    return [];
  }

  @override
  Future<GeneratedContent> generateContent(
    ChatMessage message, {
    List<ChatMessage> history = const [],
    Map<String, Object?>? requestConfiguration,
  }) async {
    try {
      _logger.info('Generating content with direct Gemini API');

      // Convert GenUI ChatMessage to Gemini Content
      final contents = <Content>[
        ...history.map(_convertToGeminiContent),
        _convertToGeminiContent(message),
      ];

      final response = await _model.generateContent(contents);

      _logger.info('Received response from Gemini API');

      // Convert Gemini response to GenUI GeneratedContent
      return GeneratedContent(
        textParts: response.text != null ? [TextPart(response.text!)] : [],
        toolCalls: [], // Tool calls would be extracted from function calls
      );
    } catch (e) {
      _logger.severe('Error generating content: $e');
      rethrow;
    }
  }

  Content _convertToGeminiContent(ChatMessage message) {
    final textParts = message.parts.whereType<TextPart>();
    final text = textParts.map((p) => p.text).join('\n');
    
    return Content.text(text);
  }
}

