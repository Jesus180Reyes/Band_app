import 'package:band_app/providers/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          socketService.socket.emit('emitir-mensaje', {
            {
              'nombre': 'Flutter',
              'mensaje': 'Hola desde Flutter',
            }
          });
        },
        child: const Icon(Icons.message),
      ),
      body: Center(
        child: Text(socketService.serverStatus.toString()),
      ),
    );
  }
}
