import 'package:flutter/foundation.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/models/agent_log.dart';
import 'package:hack_the_future_starter/features/chat/services/genui_service.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({GenUiService? service}) : _service = service ?? GenUiService();

  final GenUiService _service;

  late final Catalog _catalog;
  late final GenUiManager _manager;
  late final GenUiConversation _conversation;

  GenUiHost get host => _conversation.host;

  ValueListenable<bool> get isProcessing => _conversation.isProcessing;

  final List<ChatMessageModel> _messages = [];
  final List<AgentLogEntry> _agentLogs = [];
  bool _showAgentLog = false;
  String _lastUserQuery = '';

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  List<AgentLogEntry> get agentLogs => List.unmodifiable(_agentLogs);
  bool get showAgentLog => _showAgentLog;

  void toggleAgentLog() {
    _showAgentLog = !_showAgentLog;
    notifyListeners();
  }

  void addLog(AgentLogType type, String message, [Map<String, dynamic>? data]) {
    _agentLogs.add(AgentLogEntry(type: type, message: message, data: data));
    notifyListeners();
  }

  void clearLogs() {
    _agentLogs.clear();
    notifyListeners();
  }

  void init() {
    _catalog = _service.createCatalog();
    _manager = GenUiManager(catalog: _catalog);
    final generator = _service.createContentGenerator(catalog: _catalog);

    _conversation = GenUiConversation(
      genUiManager: _manager,
      contentGenerator: generator,
      onSurfaceAdded: (s) {
        addLog(AgentLogType.present, 'Created UI surface: ${s.surfaceId}');
        _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
        notifyListeners();
        // Small delay to ensure UI updates before scrolling
        Future.delayed(const Duration(milliseconds: 100), notifyListeners);
      },
      onTextResponse: (text) {
        addLog(AgentLogType.present, 'Text response generated');
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 100), notifyListeners);
      },
      onError: (err) {
        final errorMsg = err.error.toString();
        addLog(AgentLogType.error, 'Error: $errorMsg');
        
        // Check if rate limited - show helpful message
        if (errorMsg.contains('overload') || 
            errorMsg.contains('rate limit') ||
            errorMsg.contains('quota') ||
            errorMsg.contains('429')) {
          addLog(AgentLogType.info, 'API rate limited - suggesting dashboard');
          _messages.add(ChatMessageModel(
            text: '⚠️ API RATE LIMITED\n\n'
                  'The Gemini API is currently overloaded. Please:\n\n'
                  '1️⃣ Wait 60 seconds before trying again\n'
                  '2️⃣ Click the 📊 dashboard button (top right) to see all ocean visualizations with placeholder data\n\n'
                  'Your question was: "$_lastUserQuery"\n\n'
                  'The dashboard shows examples of all components: temperature gauges, wave charts, '
                  'interactive maps, and more!',
          ));
        } else {
          _messages.add(
            ChatMessageModel(text: 'Error: $errorMsg', isError: true),
          );
        }
        notifyListeners();
      },
    );
    
    addLog(AgentLogType.info, 'Ocean Explorer initialized with ${_catalog.items.length} UI components');
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    
    _lastUserQuery = text;
    addLog(AgentLogType.perceive, 'User query: "$text"');
    _messages.add(ChatMessageModel(text: text, isUser: true));
    notifyListeners();
    
    addLog(AgentLogType.plan, 'Planning response strategy...');
    
    try {
      await _conversation.sendRequest(UserMessage([TextPart(text)]));
      addLog(AgentLogType.info, 'Request completed successfully');
    } catch (e) {
      addLog(AgentLogType.error, 'Request failed: $e');
      rethrow;
    }
  }

  void abort() {
    addLog(AgentLogType.info, 'User requested abort');
    // Note: GenUiConversation API doesn't support true cancellation
    // The LLM request will complete in background, but we inform the user
    _messages.add(ChatMessageModel(
      text: '🛑 Abort requested. The agent will stop showing results from this request. '
            'You can ask a new question.',
    ));
    notifyListeners();
  }

  void disposeConversation() {
    _conversation.dispose();
  }
}
