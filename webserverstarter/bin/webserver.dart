import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Server running on http://${server.address.host}:${server.port}');
  print('Running from: ${Directory.current.path}');

  // 👇 either keep this as Directory.current or set an absolute path
  final rootDir = Directory.current;

  await for (HttpRequest request in server) {
    final uri = request.uri.path;
    final filePath = uri == '/' ? 'viewer.html' : uri.substring(1);
    final file = File(p.join(rootDir.path, filePath));

    if (await file.exists()) {
      final mimeType = _getMimeType(file.path);
      request.response.headers.contentType = ContentType.parse(mimeType);
      await request.response.addStream(file.openRead());
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('404 - File not found: ${request.uri.path}');
    }

    await request.response.close();
  }
}

String _getMimeType(String filePath) {
  final ext = p.extension(filePath).toLowerCase();
  switch (ext) {
    case '.html':
      return 'text/html; charset=utf-8';
    case '.css':
      return 'text/css; charset=utf-8';
    case '.js':
    case '.mjs':
      return 'application/javascript; charset=utf-8';
    case '.pdf':
      return 'application/pdf';
    case '.wasm':
      return 'application/wasm';
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.gif':
      return 'image/gif';
    default:
      return 'text/plain; charset=utf-8';
  }
}
