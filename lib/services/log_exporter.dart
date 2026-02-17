import 'log_exporter_stub.dart'
    if (dart.library.html) 'log_exporter_web.dart'
    as impl;

Future<bool> exportLogTextFile({
  required String fileName,
  required String text,
}) {
  return impl.exportLogTextFile(fileName: fileName, text: text);
}
