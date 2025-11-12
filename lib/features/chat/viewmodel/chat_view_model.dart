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
      },
      onTextResponse: (text) {
        addLog(AgentLogType.present, 'Text response generated');
        _messages.add(ChatMessageModel(text: text));
        notifyListeners();
      },
      onError: (err) {
        addLog(AgentLogType.error, 'Error: ${err.error}');
        _messages.add(
          ChatMessageModel(text: err.error.toString(), isError: true),
        );
        notifyListeners();
      },
    );
    
    addLog(AgentLogType.info, 'Ocean Explorer initialized with ${_catalog.items.length} UI components');
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    
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
    addLog(AgentLogType.info, 'User aborted current operation');
    
    // Workaround: Recreate the conversation to cancel the current request
    try {
      _conversation.dispose();
      
      // Recreate conversation
      final generator = _service.createContentGenerator(catalog: _catalog);
      _conversation = GenUiConversation(
        genUiManager: _manager,
        contentGenerator: generator,
        onSurfaceAdded: (s) {
          addLog(AgentLogType.present, 'Created UI surface: ${s.surfaceId}');
          _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
          notifyListeners();
        },
        onTextResponse: (text) {
          addLog(AgentLogType.present, 'Text response generated');
          _messages.add(ChatMessageModel(text: text));
          notifyListeners();
        },
        onError: (err) {
          addLog(AgentLogType.error, 'Error: ${err.error}');
          _messages.add(
            ChatMessageModel(text: err.error.toString(), isError: true),
          );
          notifyListeners();
        },
      );
      
      addLog(AgentLogType.info, 'Conversation reset - ready for new queries');
    } catch (e) {
      addLog(AgentLogType.error, 'Failed to abort: $e');
    }
    
    notifyListeners();
  }

  void disposeConversation() {
    _conversation.dispose();
  }
}
