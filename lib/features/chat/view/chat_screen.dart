import 'package:flutter/material.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_components_demo.dart';

import '../models/chat_message.dart';
import '../viewmodel/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel()..init();
  }

  @override
  void dispose() {
    _viewModel.disposeConversation();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _viewModel.send(text);
    
    // Scroll to bottom after new message
    _scrollToBottom();
    
    // Also scroll when response is added (with a slight delay)
    Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.waves, size: 28),
            const SizedBox(width: 12),
            Text(l10n.appBarTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'View Components',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OceanComponentsDemo(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_viewModel.showAgentLog
                ? Icons.visibility_off
                : Icons.visibility),
            tooltip: 'Toggle Agent Log',
            onPressed: _viewModel.toggleAgentLog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
            onPressed: _viewModel.clearLogs,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return Column(
              children: [
                // Agent Log Panel
                if (_viewModel.showAgentLog)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[850],
                          child: Row(
                            children: [
                              const Icon(Icons.terminal,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Agent Run Log',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_viewModel.agentLogs.length} entries',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _viewModel.agentLogs.length,
                            itemBuilder: (_, i) {
                              final log = _viewModel.agentLogs[i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  log.toString(),
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: _getLogColor(log.type),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                // Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: false, // Normal order: top to bottom
                    itemCount: _viewModel.messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (_, i) {
                      final m = _viewModel.messages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: _MessageView(m, _viewModel.host, l10n),
                      );
                    },
                  ),
                ),
                // Processing Indicator (Abort temporarily disabled)
                ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isProcessing,
                  builder: (_, isProcessing, __) {
                    if (!isProcessing) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.blue[50],
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Agent processing...',
                              style: TextStyle(fontSize: 12)),
                          SizedBox(width: 12),
                          Text(
                            '(Please wait, this may take 10-20 seconds)',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Input Row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: l10n.hintTypeMessage,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _send,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getLogColor(type) {
    switch (type.toString().split('.').last) {
      case 'perceive':
        return Colors.cyan;
      case 'plan':
        return Colors.purple[300]!;
      case 'act':
        return Colors.yellow[700]!;
      case 'reflect':
        return Colors.orange[300]!;
      case 'present':
        return Colors.green[300]!;
      case 'error':
        return Colors.red[300]!;
      default:
        return Colors.grey[400]!;
    }
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView(this.model, this.host, this.l10n);

  final ChatMessageModel model;
  final GenUiHost host;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final surfaceId = model.surfaceId;

    if (surfaceId == null) {
      final label = model.isError
          ? l10n.labelError
          : (model.isUser ? l10n.labelYou : l10n.labelAI);
      final content = model.text ?? '';
      
      // Different styling for user vs AI messages
      if (model.isUser) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              content,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        );
      }
      
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Text(
            '$label: $content',
            style: TextStyle(
              fontSize: 14,
              color: model.isError ? Colors.red : Colors.grey[700],
            ),
          ),
        ),
      );
    }

    // GenUI surface - full width
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: GenUiSurface(host: host, surfaceId: surfaceId),
      ),
    );
  }
}
