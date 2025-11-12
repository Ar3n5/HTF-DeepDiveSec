import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_genui/flutter_genui.dart' as genui;
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:logging/logging.dart';

/// Direct Gemini API content generator for GenUI
/// Uses google_generative_ai package (Google AI Studio) instead of Firebase Vertex AI
class GeminiDirectContentGenerator implements genui.ContentGenerator {
  final gemini.ChatSession _chatSession;
  final String systemInstruction;
  final genui.Catalog catalog;
  final Logger _logger = Logger('GeminiDirectContentGenerator');

  // Stream controllers
  final _a2uiController = StreamController<genui.A2uiMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  final _errorController = StreamController<genui.ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

  GeminiDirectContentGenerator({
    required String apiKey,
    required this.catalog,
    required this.systemInstruction,
    String modelName = 'gemini-2.0-flash-exp',
  }) : _chatSession = gemini.GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          systemInstruction: gemini.Content.system(systemInstruction),
          tools: _createToolsFromCatalog(catalog),
        ).startChat();

  static List<gemini.Tool> _createToolsFromCatalog(genui.Catalog catalog) {
    // Create GenUI tools (surfaceUpdate, beginRendering, provideFinalOutput)
    return [
      gemini.Tool(functionDeclarations: [
        // surfaceUpdate tool
        gemini.FunctionDeclaration(
          'surfaceUpdate',
          'Updates a surface with a new set of components.',
          gemini.Schema.object(
            properties: {
              'surfaceId': gemini.Schema.string(
                description: 'The unique identifier for the UI surface to create or update.',
              ),
              'components': gemini.Schema.array(
                description: 'A list of component definitions.',
                items: _createComponentSchema(catalog),
              ),
            },
            requiredProperties: ['surfaceId', 'components'],
          ),
        ),
        // beginRendering tool
        gemini.FunctionDeclaration(
          'beginRendering',
          'Signals the client to begin rendering a surface with a root component.',
          gemini.Schema.object(
            properties: {
              'surfaceId': gemini.Schema.string(
                description: 'The unique identifier for the UI surface to render.',
              ),
              'root': gemini.Schema.string(
                description: 'The ID of the root widget.',
              ),
            },
            requiredProperties: ['surfaceId', 'root'],
          ),
        ),
        // provideFinalOutput tool
        gemini.FunctionDeclaration(
          'provideFinalOutput',
          'Returns the final output. Call this when done with the current turn.',
          gemini.Schema.object(
            properties: {
              'output': gemini.Schema.object(
                properties: {
                  'response': gemini.Schema.string(description: 'Optional response text'),
                },
              ),
            },
            requiredProperties: ['output'],
          ),
        ),
      ]),
    ];
  }

  static gemini.Schema _createComponentSchema(genui.Catalog catalog) {
    // Create a schema that includes all catalog items
    final componentSchemas = <String, gemini.Schema>{};
    
    // Convert GenUI schemas to Gemini schemas
    for (final item in catalog.items) {
      componentSchemas[item.name] = gemini.Schema.object();
    }

    return gemini.Schema.object(
      properties: {
        'id': gemini.Schema.string(description: 'Unique component ID'),
        'component': gemini.Schema.object(
          description: 'The component definition',
          properties: componentSchemas,
        ),
      },
      requiredProperties: ['id', 'component'],
    );
  }

  @override
  Future<void> sendRequest(
    genui.ChatMessage message, {
    Iterable<genui.ChatMessage>? history,
  }) async {
    _isProcessing.value = true;
    
    try {
      _logger.info('Generating content with direct Gemini API');

      // Convert GenUI ChatMessage to Gemini Content
      final userMessage = _convertToGeminiContent(message);

      // Send message and handle tool calls
      final response = await _chatSession.sendMessage(userMessage);

      _logger.info('Received response from Gemini API');

      // Handle function calls (tool calls for GenUI)
      if (response.functionCalls != null && response.functionCalls!.isNotEmpty) {
        for (final call in response.functionCalls!) {
          _logger.info('Function call: ${call.name}');
          
          // Create A2UI message from function call
          final a2uiMessage = genui.A2uiMessage(
            toolCalls: [
              genui.ToolCall(
                name: call.name,
                args: call.args,
              ),
            ],
          );
          
          _a2uiController.add(a2uiMessage);
        }
      }

      // Handle text response
      if (response.text != null && response.text!.isNotEmpty) {
        _logger.info('Text response generated');
        _textResponseController.add(response.text!);
      }
      
      _isProcessing.value = false;
    } catch (e, stackTrace) {
      _logger.severe('Error generating content with Gemini API: $e');
      _errorController.add(genui.ContentGeneratorError(e, stackTrace));
      _isProcessing.value = false;
    }
  }

  gemini.Content _convertToGeminiContent(genui.ChatMessage message) {
    final parts = <gemini.Part>[];
    
    for (final part in message.parts) {
      if (part is genui.TextPart) {
        parts.add(gemini.TextPart(part.text));
      } else if (part is genui.ToolResultPart) {
        parts.add(gemini.FunctionResponse(part.toolName, part.result));
      }
    }
    
    return gemini.Content.multi(parts);
  }

  @override
  Stream<genui.A2UiMessage> get a2uiMessageStream => const Stream.empty();

  @override
  Stream<genui.ContentGeneratorError> get errorStream => const Stream.empty();

  @override
  void dispose() {
    // Chat session cleanup if needed
  }
}

