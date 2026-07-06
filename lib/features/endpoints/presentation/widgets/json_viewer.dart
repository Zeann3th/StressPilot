import 'dart:convert';
import 'package:flutter/material.dart';

class JsonViewer extends StatefulWidget {
  final Map<String, dynamic> json;
  final TextStyle? style;
  final String? searchQuery;
  final int activeMatchIndex;
  final Function(int)? onMatchesCountChanged;

  const JsonViewer({
    super.key,
    required this.json,
    this.style,
    this.searchQuery,
    this.activeMatchIndex = 0,
    this.onMatchesCountChanged,
  });

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  GlobalKey? _activeMatchKey;
  int _matchCount = 0;
  int _lastReportedCount = -1;

  Map<String, dynamic>? _cachedJson;
  List<_ColorSegment>? _cachedSegments;

  @override
  void didUpdateWidget(JsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.activeMatchIndex != oldWidget.activeMatchIndex &&
        _activeMatchKey != null) {
      _scrollToActiveMatch();
    }

    if (widget.searchQuery != oldWidget.searchQuery ||
        widget.json != oldWidget.json) {
      _lastReportedCount = -1;
    }
  }

  void _scrollToActiveMatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeMatchKey == null) return;

      final context = _activeMatchKey!.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _activeMatchKey = null;
    _matchCount = 0;

    // Colorized segments only depend on the response data, so they're cached
    // across rebuilds triggered purely by search-box typing (identical map
    // reference in the common `_getResponseData` path).
    if (!identical(widget.json, _cachedJson) || _cachedSegments == null) {
      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(widget.json);
      _cachedJson = widget.json;
      _cachedSegments = _colorizeJson(jsonString, context);
    }

    final spans = _applySearch(_cachedSegments!);

    if (widget.onMatchesCountChanged != null) {
      final currentCount = _matchCount;
      if (currentCount != _lastReportedCount) {
        _lastReportedCount = currentCount;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onMatchesCountChanged!(currentCount);
        });
      }
    }

    return SelectableText.rich(
      TextSpan(
        style:
            widget.style ??
            TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        children: spans,
      ),
    );
  }

  List<_ColorSegment> _colorizeJson(String json, BuildContext context) {
    final List<_ColorSegment> segments = [];
    final regex = RegExp(
      r'(?<key>".*?":)|(?<string>".*?")|(?<number>-?\d+(?:\.\d+)?)|(?<bool>true|false)|(?<null>null)',
    );

    int lastMatchEnd = 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final keyColor = isDark ? const Color(0xFF9CDCFE) : const Color(0xFF0451A5);
    final stringColor = isDark
        ? const Color(0xFFCE9178)
        : const Color(0xFFA31515);
    final numberColor = isDark
        ? const Color(0xFFB5CEA8)
        : const Color(0xFF098658);
    final keywordColor = isDark
        ? const Color(0xFF569CD6)
        : const Color(0xFF0000FF);

    for (final match in regex.allMatches(json)) {
      if (match.start > lastMatchEnd) {
        segments.add(
          _ColorSegment(json.substring(lastMatchEnd, match.start), null),
        );
      }

      Color? color;
      if (match.namedGroup('key') != null) {
        color = keyColor;
      } else if (match.namedGroup('string') != null) {
        color = stringColor;
      } else if (match.namedGroup('number') != null) {
        color = numberColor;
      } else if (match.namedGroup('bool') != null) {
        color = keywordColor;
      } else if (match.namedGroup('null') != null) {
        color = keywordColor;
      }

      segments.add(_ColorSegment(match.group(0)!, color));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < json.length) {
      segments.add(_ColorSegment(json.substring(lastMatchEnd), null));
    }

    return segments;
  }

  List<InlineSpan> _applySearch(List<_ColorSegment> segments) {
    final List<InlineSpan> spans = [];
    for (final segment in segments) {
      _addTextWithSearch(spans, segment.text, segment.color);
    }
    return spans;
  }

  void _addTextWithSearch(List<InlineSpan> spans, String text, Color? color) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: color != null ? TextStyle(color: color) : null,
        ),
      );
      return;
    }

    final query = widget.searchQuery!.toLowerCase();
    final lowerText = text.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(query, start);
      if (index == -1) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: color != null ? TextStyle(color: color) : null,
          ),
        );
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: color != null ? TextStyle(color: color) : null,
          ),
        );
      }

      final matchText = text.substring(index, index + query.length);
      final matchIndex = _matchCount;
      _matchCount++;

      final isActive = matchIndex == widget.activeMatchIndex;

      if (isActive) {
        final key = GlobalKey();
        _activeMatchKey = key;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              key: key,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                matchText,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(
              backgroundColor: Colors.yellow.withValues(alpha: 0.4),
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      start = index + query.length;
    }
  }
}

class _ColorSegment {
  const _ColorSegment(this.text, this.color);

  final String text;
  final Color? color;
}
