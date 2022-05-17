import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus {
  online,
  offline,
  connecting,
}

class SocketService extends ChangeNotifier {
  ServerStatus serverStatus = ServerStatus.connecting;
  io.Socket? _socket;
  io.Socket get socket => _socket!;
  SocketService() {
    _initConfig();
  }
  void _initConfig() {
    _socket = io.io('http://192.168.0.108:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket!.onConnect((_) {
      serverStatus = ServerStatus.online;
      // print('conected');
      notifyListeners();
    });
    _socket!.onDisconnect((_) {
      serverStatus = ServerStatus.offline;
      // print('disconected');
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', (data) {
    //   print('nuevo mensaje');
    //   print('nombre' + data['nombre']);
    //   print('mensaje ' + data['mensaje']);
    //   print(
    //       data.containsKey('mensaje3') ? data['mensaje3'] : 'no hay mensaje3');

    //   notifyListeners();
    // });
  }
}
