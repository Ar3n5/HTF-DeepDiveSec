import 'package:flutter/material.dart';

class ChatMessageModel {
  const ChatMessageModel({
    this.text,
    this.surfaceId,
    this.isUser = false,
    this.isError = false,
    this.placeholderWidget,
  }) : assert(text != null || surfaceId != null || placeholderWidget != null);

  final String? text;
  final String? surfaceId;
  final bool isUser;
  final bool isError;
  final Widget? placeholderWidget;
}
