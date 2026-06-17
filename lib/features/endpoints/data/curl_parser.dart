class CurlParsedData {
  final String? url;
  final String? method;
  final Map<String, String>? headers;
  final String? body;

  CurlParsedData({this.url, this.method, this.headers, this.body});
}

class CurlParser {
  static CurlParsedData parse(String curlCommand) {
    final cleanCommand = curlCommand
        .replaceAll('\\\n', ' ')
        .replaceAll('\\\r\n', ' ');

    String method = 'GET';
    String url = '';
    Map<String, String> headers = {};
    String body = '';

    final urlMatch = RegExp(
      r'''(?:curl\s+)?(?:['"]?)(https?://[^'"\s]+)(?:['"]?)''',
    ).firstMatch(cleanCommand);
    if (urlMatch != null) {
      url = urlMatch.group(1)!;
    }

    final methodMatch = RegExp(
      r'''(?:-X|--request)\s+(['"]?)([A-Z]+)\1''',
    ).firstMatch(cleanCommand);
    if (methodMatch != null) {
      method = methodMatch.group(2)!;
    } else if (cleanCommand.contains('-d') ||
        cleanCommand.contains('--data') ||
        cleanCommand.contains('--data-raw')) {
      method = 'POST';
    }

    final headerRegExp = RegExp(
      r'''(?:-H|--header)\s+(['"])([^:]+):\s*(.*?)\1''',
    );
    for (final match in headerRegExp.allMatches(cleanCommand)) {
      headers[match.group(2)!.trim()] = match.group(3)!.trim();
    }

    final headerNoQuoteRegExp = RegExp(
      r'''(?:-H|--header)\s+([^'"\s]+):\s*([^'"\s]+)''',
    );
    for (final match in headerNoQuoteRegExp.allMatches(cleanCommand)) {
      final key = match.group(1)!.trim();
      if (!headers.containsKey(key)) {
        headers[key] = match.group(2)!.trim();
      }
    }

    final dataRegExp = RegExp(
      r'''(?:-d|--data(?:-raw|-binary)?)\s+(['"])(.*?)\1''',
      dotAll: true,
    );
    final dataMatch = dataRegExp.firstMatch(cleanCommand);
    if (dataMatch != null) {
      body = dataMatch.group(2) ?? '';
    } else {
      final dataNoQuoteRegExp = RegExp(
        r'''(?:-d|--data(?:-raw|-binary)?)\s+([^{'"\s][^\s]*)''',
      );
      final dataNoQuoteMatch = dataNoQuoteRegExp.firstMatch(cleanCommand);
      if (dataNoQuoteMatch != null) {
        body = dataNoQuoteMatch.group(1) ?? '';
      }
    }

    return CurlParsedData(
      url: url,
      method: method,
      headers: headers,
      body: body,
    );
  }
}

class CurlGenerator {
  static String generate({
    required String url,
    required String method,
    required Map<String, String> headers,
    required Map<String, String> params,
    required String body,
  }) {
    String fullUrl = url;
    if (params.isNotEmpty) {
      final uri = Uri.parse(url);
      final hasQuery = uri.hasQuery && uri.query.isNotEmpty;
      final paramStr = params.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      fullUrl = hasQuery ? '$url&$paramStr' : '$url?$paramStr';
    }

    var curl = 'curl -X $method "$fullUrl"';
    headers.forEach((key, value) {
      final safeKey = key.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
      final safeValue = value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
      curl += ' \\\n  -H "$safeKey: $safeValue"';
    });

    if (body.isNotEmpty &&
        (method == 'POST' ||
            method == 'PUT' ||
            method == 'PATCH' ||
            method == 'DELETE')) {
      final escapedBody = body
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll(r'$', r'\$')
          .replaceAll('`', '\\`');
      // Escaped for bash/zsh/PowerShell; cmd.exe users need to remove backslashes manually
      curl += ' \\\n  --data-raw "$escapedBody"';
    }
    return curl;
  }
}
