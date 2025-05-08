import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketHandler {
  late io.Socket socket;
  Function(String)? onMessageCallback;

  SocketHandler({required String serverUrl}) {
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void connect() {
    socket.connect();
  }

  void disconnect() {
    socket.disconnect();
  }

  void subscribeToMessages(Function(String) callback) {
    onMessageCallback = callback;
    socket.on('message', (data) {
      if (onMessageCallback != null) {
        onMessageCallback!(data.toString());
      }
    });
    connect();
  }

  void sendMessage(String message) {
    socket.emit('message', message);
  }
}
