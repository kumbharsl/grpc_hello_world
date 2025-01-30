import 'package:grpc/grpc.dart' as grpc;
import 'package:hello_words/generated/hello.pbgrpc.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'dart:io';

class GreeterService extends GreeterServiceBase {
  @override
  Future<HelloReply> sayHello(
      grpc.ServiceCall call, HelloRequest request) async {
    return HelloReply()..message = 'Hello, ${request.name}! From gRPC server.';
  }
}

Future<Response> _handler(Request request) async {
  // Handle OPTIONS request (CORS preflight)
  if (request.method == 'OPTIONS') {
    return Response(
      200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  }

  // Handle GET requests (including favicon.ico)
  if (request.method == 'GET') {
    if (request.url.path == 'favicon.ico') {
      return Response.notFound('No favicon');
    }
    return Response.ok('gRPC-web proxy server');
  }

  // Handle POST requests (gRPC-web)
  if (request.method == 'POST') {
    final handler = proxyHandler('http://localhost:50051');
    return await handler(request);
  }

  return Response.notFound('Not Found');
}

Future<void> main() async {
  // Start gRPC server
  final grpcServer = grpc.Server([
    GreeterService(),
  ]);

  await grpcServer.serve(
    address: InternetAddress.anyIPv4,
    port: 50051,
  );
  print('gRPC server listening on port 50051');

  // Start proxy server
  final handler = const Pipeline()
      .addMiddleware((innerHandler) => (request) async {
            final response = await _handler(request);
            return response.change(headers: {
              ...response.headers,
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
              'Access-Control-Allow-Headers': '*',
            });
          })
      .addHandler(_handler);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    50052,
    poweredByHeader: null,
  );

  print('HTTP proxy for gRPC-web listening on port ${server.port}');
}
