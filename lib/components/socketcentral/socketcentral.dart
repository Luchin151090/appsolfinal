
/*import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;
  final Set<String> _registeredEvents = {};

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    // Initialization logic
    connectToServer();
  }

  void connectToServer() {
    final apiUrl = "http://147.182.251.164"; // Pon aquí tu URL de API

    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 2000,
      'reconnectionDelayMax': 2000,
      'timeout':10000
    });

    socket.connect();

    socket.onConnect((_) {
      print('Conexión establecida');
    });

    socket.onDisconnect((_) {
      print('Conexión desconectada');
    });

    socket.onConnectError((error) {
      print('Error de conexión: $error');
    });

    socket.onError((error) {
      print('Otro error: $error');
    });
  }

  void listenToEvent(String eventName, Function(dynamic) callback) {
    if (_registeredEvents.contains(eventName)) {
      // Si el evento ya está registrado, no lo registres de nuevo
      return;
    }

    socket.on(eventName, callback);
    _registeredEvents.add(eventName); // Marca el evento como registrado
  }

  void emitEvent(String eventName, dynamic data) {
    socket.emit(eventName, data);
  }

  void disconnet(){
    if(socket.connected){
      socket.disconnect();
      print("Conexión cerrada manualente");
    }
  }

  void dispose() {
    disconnet();
    //socket.dispose();
  }
}
*/

import 'package:socket_io_client/socket_io_client.dart' as io;
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;
  final Set<String> _registeredEvents = {};

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    // Initialization logic
    connectToServer();
  }

  void connectToServer() {
    final apiUrl = "http://147.182.251.164/"; // Pon aquí tu URL de API

    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 2000,
      'reconnectionDelayMax': 2000,
      'timeout': 10000,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Conexión establecida');
    });

    socket.onDisconnect((_) {
      print('Conexión desconectada');
    });

    socket.onConnectError((error) {
      print('Error de conexión: $error');
    });

    socket.onError((error) {
      print('Otro error: $error');
    });
  }

  void listenToEvent(String eventName, Function(dynamic) callback) {
    if (_registeredEvents.contains(eventName)) {
      // Si el evento ya está registrado, no lo registres de nuevo
      return;
    }

    socket.on(eventName, callback);
    _registeredEvents.add(eventName); // Marca el evento como registrado
  }

  void emitEvent(String eventName, dynamic data) {
    socket.emit(eventName, data);
  }

  void disconnet() {
    if (socket.connected) {
      socket.disconnect();
      print("Conexión cerrada manualmente");
    }
  }

  void dispose() {
    disconnet();
  }

  // Aquí manejamos eventos de rutas y pedidos
  void onRutaCreada(Function(dynamic) callback) {
    listenToEvent('creadoRuta', callback);
  }

  void onPedidoAnadido(Function(dynamic) callback) {
    listenToEvent('pedidoañadido', callback);
  }

 /* void notificarClientes(Function(dynamic) callback){
    listenToEvent('depósito', callback);
  }*/
}