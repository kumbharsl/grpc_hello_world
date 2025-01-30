import 'package:flutter/material.dart';
import 'generated/hello.pbgrpc.dart';
import 'services/grpc_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter gRPC Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  String _response = '';

  Future<void> _sendRequest() async {
    try {
      final client = await GrpcService.getClient();
      final response = await client.sayHello(
        HelloRequest()..name = _nameController.text,
      );
      setState(() {
        _response = response.message;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendRequest,
              child: const Text('Send gRPC Request'),
            ),
            const SizedBox(height: 16),
            Text(
              'Server Response:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_response),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    GrpcService.dispose();
    super.dispose();
  }
}
