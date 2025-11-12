import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:hack_the_future_starter/core/theme_provider.dart';
import 'package:hack_the_future_starter/features/ocean/widgets/ocean_components_demo.dart';

import '../models/chat_message.dart';
import '../viewmodel/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  final ThemeProvider? themeProvider;
  
  const ChatScreen({super.key, this.themeProvider});

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
          // Dark/Light mode toggle
          if (widget.themeProvider != null)
            IconButton(
              icon: Icon(widget.themeProvider!.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: widget.themeProvider!.toggleTheme,
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
                // Processing Indicator with Abort Button
                ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isProcessing,
                  builder: (_, isProcessing, __) {
                    if (!isProcessing) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D2D2D)
                          : Colors.blue[50],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          const Text('Agent processing...',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 12),
                          Text(
                            '(May take 10-20 seconds)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.stop, size: 16),
                            label: const Text('Abort'),
                            onPressed: _viewModel.abort,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
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
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              // Check if Shift is pressed
                              final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                              
                              if (!isShiftPressed) {
                                // Enter alone - send message
                                _send();
                              }
                              // Shift+Enter - allow new line (do nothing, default behavior)
                            }
                          },
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: l10n.hintTypeMessage,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              helperText: 'Enter to send, Shift+Enter for new line',
                              helperStyle: const TextStyle(fontSize: 10),
                            ),
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1565C0)
                                      : Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _send,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1565C0) : Colors.blue[100],
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
      
      // AI text responses - styled like message bubbles
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(-20 * (1 - value), 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: model.isError 
                        ? (isDark ? Colors.red[900]!.withOpacity(0.3) : Colors.red[50])
                        : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(18),
                    border: model.isError
                        ? Border.all(color: Colors.red, width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: model.isError 
                          ? Colors.red[300]
                          : (isDark ? Colors.white : Colors.grey[800]),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
