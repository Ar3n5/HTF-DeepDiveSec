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
        
        // Check if rate limited - show placeholder visualization
        if (errorMsg.contains('overload') || 
            errorMsg.contains('rate limit') ||
            errorMsg.contains('quota') ||
            errorMsg.contains('429')) {
          addLog(AgentLogType.info, 'API rate limited - showing placeholder visualization');
          _showPlaceholderVisualization();
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
    addLog(AgentLogType.info, 'User requested abort - recreating conversation');
    
    // Dispose the current conversation and create a new one
    // This will stop the LLM from processing
    try {
      _conversation.dispose();
      
      // Recreate the conversation
      final generator = _service.createContentGenerator(catalog: _catalog);
      _conversation = GenUiConversation(
        genUiManager: _manager,
        contentGenerator: generator,
        onSurfaceAdded: (s) {
          addLog(AgentLogType.present, 'Created UI surface: ${s.surfaceId}');
          _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
          notifyListeners();
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
      
      _messages.add(ChatMessageModel(
        text: '🛑 Request aborted. You can ask a new question now.',
      ));
      notifyListeners();
    } catch (e) {
      addLog(AgentLogType.error, 'Failed to abort: $e');
    }
  }

  void disposeConversation() {
    _conversation.dispose();
  }

  /// Show placeholder visualization when API is rate limited
  void _showPlaceholderVisualization() {
    // Add warning message first
    _messages.add(ChatMessageModel(
      text: '⚠️ API RATE LIMITED - Showing placeholder visualization below.\n'
            'Wait 60 seconds before trying again.',
    ));
    
    // Create a unique surface ID
    final surfaceId = 'placeholder_${DateTime.now().millisecondsSinceEpoch}';
    final lowerQuery = _lastUserQuery.toLowerCase();
    
    // Manually create a surface with placeholder data
    final surface = _manager.host.surfaces[surfaceId] ?? 
                    _manager.host.createSurface(surfaceId);
    
    // Determine what visualization to show based on query
    List<Map<String, dynamic>> components = [];
    
    if (lowerQuery.contains('temperature') || lowerQuery.contains('temp')) {
      if (lowerQuery.contains('gauge') || lowerQuery.contains('meter')) {
        components = [
          {
            'id': 'placeholder_gauge',
            'componentName': 'OceanGauge',
            'data': {
              'title': 'Ocean Temperature (PLACEHOLDER)',
              'value': 18.5,
              'unit': '°C',
              'min': 0.0,
              'max': 30.0,
              'color': 'orange',
            }
          }
        ];
      } else if (lowerQuery.contains('trend') || lowerQuery.contains('over time')) {
        components = [
          {
            'id': 'placeholder_chart',
            'componentName': 'OceanLineChart',
            'data': {
              'title': 'Ocean Temperature Trends (PLACEHOLDER)',
              'dataPoints': [
                {'timestamp': '2024-01-01', 'value': 15.2},
                {'timestamp': '2024-01-08', 'value': 16.1},
                {'timestamp': '2024-01-15', 'value': 17.3},
                {'timestamp': '2024-01-22', 'value': 18.5},
                {'timestamp': '2024-01-29', 'value': 17.8},
              ],
              'unit': '°C',
              'color': 'orange',
            }
          }
        ];
      } else {
        components = [
          {
            'id': 'placeholder_stats',
            'componentName': 'OceanStatsCard',
            'data': {
              'title': 'Ocean Temperature (PLACEHOLDER)',
              'value': '18.5°C',
              'icon': 'thermostat',
              'color': 'orange',
              'subtitle': 'Placeholder data - API rate limited',
              'min': '12.3°C',
              'max': '24.1°C',
              'average': '18.5°C',
            }
          }
        ];
      }
    } else if (lowerQuery.contains('wave') || lowerQuery.contains('height')) {
      components = [
        {
          'id': 'placeholder_waves',
          'componentName': 'OceanStatsCard',
          'data': {
            'title': 'Wave Height (PLACEHOLDER)',
            'value': '3.2m',
            'icon': 'waves',
            'color': 'blue',
            'subtitle': 'Placeholder data - API rate limited',
            'min': '1.5m',
            'max': '4.8m',
            'average': '3.2m',
          }
        }
      ];
    } else if (lowerQuery.contains('location') || lowerQuery.contains('where') || 
               lowerQuery.contains('map')) {
      components = [
        {
          'id': 'placeholder_map',
          'componentName': 'OceanInteractiveMap',
          'data': {
            'title': 'Ocean Locations (PLACEHOLDER)',
            'locations': [
              {'name': 'North Atlantic', 'latitude': 45.0, 'longitude': -30.0, 'value': '18.5°C'},
              {'name': 'Pacific Ocean', 'latitude': 10.0, 'longitude': -150.0, 'value': '22.1°C'},
              {'name': 'Indian Ocean', 'latitude': -15.0, 'longitude': 75.0, 'value': '26.3°C'},
            ]
          }
        }
      ];
    } else {
      // Default: show a stats card
      components = [
        {
          'id': 'placeholder_default',
          'componentName': 'OceanStatsCard',
          'data': {
            'title': 'Ocean Data (PLACEHOLDER)',
            'value': 'Available',
            'icon': 'water_drop',
            'color': 'blue',
            'subtitle': 'Placeholder data - API rate limited',
          }
        }
      ];
    }
    
    // Update the surface with components
    try {
      surface.update(components);
      _messages.add(ChatMessageModel(surfaceId: surfaceId));
      notifyListeners();
    } catch (e) {
      addLog(AgentLogType.error, 'Failed to show placeholder: $e');
    }
  }
}
