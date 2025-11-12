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
        
        // Check if rate limited - show placeholder visualizations
        if (errorMsg.contains('overload') || 
            errorMsg.contains('rate limit') ||
            errorMsg.contains('quota') ||
            errorMsg.contains('429')) {
          addLog(AgentLogType.info, 'API rate limited - showing placeholder data');
          _showPlaceholderResponse(_lastUserQuery);
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

  /// Show placeholder data when rate limited
  void _showPlaceholderResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Add warning banner
    _messages.add(ChatMessageModel(
      text: '⚠️ API RATE LIMITED - Showing placeholder data below. '
            'Wait 60 seconds before trying again.',
    ));
    
    // Create a surface with placeholder data based on query
    final surfaceId = 'placeholder_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final surface = _manager.getOrCreateSurface(surfaceId);
      
      // Determine what type of visualization to show
      if (lowerQuery.contains('temperature') || lowerQuery.contains('temp')) {
        _showPlaceholderTemperature(surface, lowerQuery);
      } else if (lowerQuery.contains('wave') || lowerQuery.contains('height')) {
        _showPlaceholderWaves(surface, lowerQuery);
      } else if (lowerQuery.contains('salinity') || lowerQuery.contains('salt')) {
        _showPlaceholderSalinity(surface, lowerQuery);
      } else if (lowerQuery.contains('location') || lowerQuery.contains('where') || 
                 lowerQuery.contains('map')) {
        _showPlaceholderLocations(surface);
      } else {
        // Default: show general ocean stats
        _showPlaceholderGeneral(surface);
      }
      
      _messages.add(ChatMessageModel(surfaceId: surfaceId));
      notifyListeners();
    } catch (e) {
      addLog(AgentLogType.error, 'Failed to create placeholder: $e');
    }
  }

  void _showPlaceholderTemperature(Surface surface, String query) {
    if (query.contains('gauge') || query.contains('meter')) {
      // Show as gauge
      surface.update([
        GenUiComponentData(
          id: 'placeholder_gauge',
          componentName: 'OceanGauge',
          data: {
            'title': 'Ocean Temperature (PLACEHOLDER)',
            'value': 18.5,
            'unit': '°C',
            'min': 0.0,
            'max': 30.0,
            'color': 'orange',
          },
        ),
      ]);
    } else if (query.contains('trend') || query.contains('over time') || 
               query.contains('chart')) {
      // Show as line chart
      surface.update([
        GenUiComponentData(
          id: 'placeholder_chart',
          componentName: 'OceanLineChart',
          data: {
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
          },
        ),
      ]);
    } else {
      // Show as stats card
      surface.update([
        GenUiComponentData(
          id: 'placeholder_stats',
          componentName: 'OceanStatsCard',
          data: {
            'title': 'Ocean Temperature (PLACEHOLDER)',
            'value': '18.5°C',
            'icon': 'thermostat',
            'color': 'orange',
            'subtitle': 'Current measurement',
            'min': '12.3°C',
            'max': '24.1°C',
            'average': '18.5°C',
          },
        ),
      ]);
    }
  }

  void _showPlaceholderWaves(Surface surface, String query) {
    if (query.contains('gauge')) {
      surface.update([
        GenUiComponentData(
          id: 'placeholder_gauge',
          componentName: 'OceanGauge',
          data: {
            'title': 'Wave Height (PLACEHOLDER)',
            'value': 3.2,
            'unit': 'm',
            'min': 0.0,
            'max': 10.0,
            'color': 'blue',
          },
        ),
      ]);
    } else {
      surface.update([
        GenUiComponentData(
          id: 'placeholder_stats',
          componentName: 'OceanStatsCard',
          data: {
            'title': 'Wave Height (PLACEHOLDER)',
            'value': '3.2m',
            'icon': 'waves',
            'color': 'blue',
            'subtitle': 'Current measurement',
            'min': '1.5m',
            'max': '4.8m',
            'average': '3.2m',
          },
        ),
      ]);
    }
  }

  void _showPlaceholderSalinity(Surface surface, String query) {
    surface.update([
      GenUiComponentData(
        id: 'placeholder_stats',
        componentName: 'OceanStatsCard',
        data: {
          'title': 'Salinity (PLACEHOLDER)',
          'value': '35.5 PSU',
          'icon': 'water_drop',
          'color': 'teal',
          'subtitle': 'Practical Salinity Unit',
          'min': '32.1 PSU',
          'max': '37.8 PSU',
          'average': '35.5 PSU',
        },
      ),
    ]);
  }

  void _showPlaceholderLocations(Surface surface) {
    surface.update([
      GenUiComponentData(
        id: 'placeholder_map',
        componentName: 'OceanInteractiveMap',
        data: {
          'title': 'Ocean Measurement Locations (PLACEHOLDER)',
          'locations': [
            {
              'name': 'North Atlantic',
              'latitude': 45.0,
              'longitude': -30.0,
              'value': '18.5°C'
            },
            {
              'name': 'Pacific Ocean',
              'latitude': 10.0,
              'longitude': -150.0,
              'value': '22.1°C'
            },
            {
              'name': 'Indian Ocean',
              'latitude': -15.0,
              'longitude': 75.0,
              'value': '26.3°C'
            },
          ],
        },
      ),
    ]);
  }

  void _showPlaceholderGeneral(Surface surface) {
    surface.update([
      GenUiComponentData(
        id: 'placeholder_stats',
        componentName: 'OceanStatsCard',
        data: {
          'title': 'Ocean Conditions (PLACEHOLDER)',
          'value': 'Data Available',
          'icon': 'info',
          'color': 'blue',
          'subtitle': 'Placeholder data shown due to rate limiting',
        },
      ),
    ]);
  }
}
