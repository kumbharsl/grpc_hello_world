import 'package:grpc/grpc_web.dart';
import '../generated/hello.pbgrpc.dart';

class GrpcService {
  static GrpcWebClientChannel? _channel;
  static GreeterClient? _client;

  static Future<GreeterClient> getClient() async {
    if (_client != null) return _client!;

    _channel = GrpcWebClientChannel.xhr(
      Uri.parse('http://localhost:50052'),
    );

    _client = GreeterClient(_channel!);
    return _client!;
  }

  static Future<void> dispose() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
  }

  // Example method to call a gRPC serv
  static Future<String> sayHello(String name) async {
    try {
      final client = await getClient();
      final response = await client.sayHello(HelloRequest()..name = name);
      return response.message;
    } catch (e) {
      print('Error calling sayHello: $e');
      rethrow;
    }
  }
}
