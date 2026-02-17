import 'dart:convert';
import 'dart:html' as html;

Future<bool> exportLogTextFile({
  required String fileName,
  required String text,
}) async {
  final bytes = utf8.encode(text);
  final blob = html.Blob(<dynamic>[bytes], 'text/plain;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
