import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:hack_the_future_starter/features/chat/models/chat_message.dart';
import 'package:hack_the_future_starter/features/chat/models/agent_log.dart';
import 'package:hack_the_future_starter/features/chat/services/genui_service.dart';
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_stats_card.dart';
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_chart_widget.dart';
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_gauge_widget.dart'
    show OceanGaugeWidget;
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_interactive_map.dart';

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
  bool _ignoreNextResponse = false;

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
        if (_ignoreNextResponse) {
          addLog(AgentLogType.info, 'Ignoring surface due to abort');
          return;
        }
        addLog(AgentLogType.present, 'Created UI surface: ${s.surfaceId}');
        _messages.add(ChatMessageModel(surfaceId: s.surfaceId));
        notifyListeners();
        // Small delay to ensure UI updates before scrolling
        Future.delayed(const Duration(milliseconds: 100), notifyListeners);
      },
      onTextResponse: (text) {
        if (_ignoreNextResponse) {
          addLog(AgentLogType.info, 'Ignoring text response due to abort');
          _ignoreNextResponse = false; // Reset flag after ignoring
          return;
        }
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
          addLog(
            AgentLogType.info,
            'API rate limited - showing placeholder visualization',
          );
          _showPlaceholderVisualization();
        } else {
          _messages.add(
            ChatMessageModel(text: 'Error: $errorMsg', isError: true),
          );
        }
        notifyListeners();
      },
    );

    addLog(
      AgentLogType.info,
      'Ocean Explorer initialized with ${_catalog.items.length} UI components',
    );
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
    
    // Set flag to ignore any pending responses
    _ignoreNextResponse = true;
    
    // Add message to chat
    _messages.add(ChatMessageModel(
      text: '🛑 Request aborted. Any pending results will be ignored.\n'
            'You can ask a new question now.',
    ));
    notifyListeners();
  }

  void disposeConversation() {
    _conversation.dispose();
  }

  /// Show placeholder visualization when API is rate limited
  void _showPlaceholderVisualization() {
    final lowerQuery = _lastUserQuery.toLowerCase();

    // Add warning message
    _messages.add(
      ChatMessageModel(
        text:
            '⚠️ API RATE LIMITED - Showing placeholder data below.\n'
            'Wait 60 seconds before trying again.',
      ),
    );

    // Determine and show appropriate placeholder widget
    Widget placeholderWidget;

    if (lowerQuery.contains('temperature') || lowerQuery.contains('temp')) {
      if (lowerQuery.contains('gauge') || lowerQuery.contains('meter')) {
        placeholderWidget = OceanGaugeWidget(
          title: 'Ocean Temperature (PLACEHOLDER)',
          value: 18.5,
          min: 0,
          max: 30,
          unit: '°C',
          color: Colors.orange,
        );
      } else if (lowerQuery.contains('trend') || lowerQuery.contains('chart')) {
        placeholderWidget = const OceanLineChart(
          title: 'Temperature Trends (PLACEHOLDER)',
          dataPoints: [
            {'timestamp': '2024-01-01', 'value': 15.2},
            {'timestamp': '2024-01-08', 'value': 16.1},
            {'timestamp': '2024-01-15', 'value': 17.3},
            {'timestamp': '2024-01-22', 'value': 18.5},
            {'timestamp': '2024-01-29', 'value': 17.8},
          ],
          unit: '°C',
          color: Colors.orange,
        );
      } else {
        placeholderWidget = const OceanStatsCard(
          title: 'Ocean Temperature (PLACEHOLDER)',
          value: '18.5°C',
          icon: Icons.thermostat,
          color: Colors.orange,
          subtitle: 'Placeholder - API rate limited',
          min: 12.3,
          max: 24.1,
        );
      }
    } else if (lowerQuery.contains('wave') || lowerQuery.contains('height')) {
      placeholderWidget = const OceanStatsCard(
        title: 'Wave Height (PLACEHOLDER)',
        value: '3.2m',
        icon: Icons.waves,
        color: Colors.blue,
        subtitle: 'Placeholder - API rate limited',
        min: 1.5,
        max: 4.8,
      );
    } else if (lowerQuery.contains('location') ||
        lowerQuery.contains('where') ||
        lowerQuery.contains('map') ||
        lowerQuery.contains('sea')) {
      placeholderWidget = const OceanInteractiveMap(
        title: 'Ocean Locations (PLACEHOLDER)',
        locations: [
          {
            'name': 'Red Sea',
            'latitude': 22.0,
            'longitude': 38.0,
            'value': '28°C',
          },
          {
            'name': 'Mediterranean',
            'latitude': 35.0,
            'longitude': 18.0,
            'value': '24°C',
          },
          {
            'name': 'Arabian Sea',
            'latitude': 15.0,
            'longitude': 65.0,
            'value': '26°C',
          },
        ],
      );
    } else {
      placeholderWidget = const OceanStatsCard(
        title: 'Ocean Data (PLACEHOLDER)',
        value: 'Available',
        icon: Icons.water_drop,
        color: Colors.blue,
        subtitle: 'Placeholder - API rate limited',
      );
    }

    _messages.add(ChatMessageModel(placeholderWidget: placeholderWidget));
    notifyListeners();
  }
}
