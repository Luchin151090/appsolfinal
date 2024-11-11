import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

int activeOrderIndex = 0;

class PedidoconductorProvider extends ChangeNotifier {
  List<Pedido> listPedidos = [];
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  String apiUpdateestado = '/api/estadoflash/';
  List<Pedido> get pedidos => listPedidos;
  int? rutaIDGET = 0;
  int? _rutaActual;
  String? _nombreConductor;


  cargarPreferencias() async {
   /* SharedPreferences rutaidget = await SharedPreferences.getInstance();

    rutaIDGET = rutaidget.getInt('rutaActual');
    print("---RUTA ID GET: ${rutaIDGET}");
*/
    await getPedidosConductor();
  }

  void setAceptadopor(dynamic nombre)async{
    _nombreConductor = nombre.toString();
  }

  String? getnombreconductor(){
    return _nombreConductor;
  }

  Future<dynamic> getlastrutaconductor() async {
    print("-----1---");
    var res = await http.get(Uri.parse(apiUrl + '/api/lastrutafasty'),
        headers: {"Content-type": "application/json"});
    try {
      //SharedPreferences rutaidget = await SharedPreferences.getInstance();
      
      // print("------esta es la RUTA");
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        //rutaidget.setInt('rutaActual', data['id']);
        setRutaActual(data['id']);
      //  rutaIDGET = data['id'];
        print("getlastconductor-----$data");
        notifyListeners();
      }
    } catch (error) {
      throw Exception("error en la solicitud $error");
    }
  }

  int? getIdRuta(){
    return _rutaActual;
  }

  Future<void> getPedidosConductor() async {
    print(".....2...dentro del provider get");
   // SharedPreferences rutaidget = await SharedPreferences.getInstance();

    //int? rutaid = rutaidget.getInt('rutaActual'); // Cambia esto si es necesario
    //print("...ruta en provider: $rutaIDGET");
    print(
        "-----la ruta es: ${apiUrl + apiPedidosConductor + getIdRuta().toString()}");
    var res = await http.get(
      Uri.parse(apiUrl + apiPedidosConductor + getIdRuta().toString()),
      headers: {"Content-type": "application/json"},
    );

    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);

        // Verifica si 'data' es una lista
        if (data is List) {
          List<Pedido> listTemporal = data.map<Pedido>((mapa) {
            return Pedido(
              id: mapa['id'],
              montoTotal: mapa['total']?.toDouble(),
              latitud: mapa['latitud']?.toDouble(),
              longitud: mapa['longitud']?.toDouble(),
              fecha: mapa['fecha'],
              estado: mapa['estado'],
              tipo: mapa['tipo'],
              nombre: mapa['nombre'],
              apellidos: mapa['apellidos'],
              telefono: mapa['telefono'],
              direccion: mapa['direccion'],
              tipoPago: mapa['tipo_pago'],
              beneficiadoID: mapa['beneficiado_id'],
              comentario: mapa['observacion'] ?? 'sin comentarios',
            );
          }).toList();

          print(".....CANTIDAD PEDIDOS PROVIDER....");
          print("${listTemporal.length}");

          // Asigna la lista de pedidos temporal a la lista principal

          listPedidos = listTemporal;
         // estado pendiente
         notifyListeners();
         setPedidos(listTemporal);
        } else {
          print("Error: Los datos recibidos no son una lista.");
        }
      } else {
        print("Error en la respuesta: ${res.statusCode}");
        print("Cuerpo de la respuesta: ${res.body}");
      }
    } catch (error) {
      throw Exception("Error de consulta $error");
    }
  }

  void setPedidos(List<Pedido> pedidos) {
    listPedidos = pedidos;
    notifyListeners();
  }



  void setRutaActual(int idRuta){
    _rutaActual = idRuta;
    print("---1.1.............. $_rutaActual");
    notifyListeners();
  }

  void rechazarPedidos(int pedidosId) {
    print("........RECHAZANDO..............");
    listPedidos.removeWhere((pedido) => pedido.id == pedidosId);
    notifyListeners();
  }

  Future<dynamic> updateestadoaceptar(String estado, int idpedido) async {
    try {
      print("........LLLAMANDO AL UPDATE");
      // Hacemos la petición a la API para actualizar el estado en el servidor
      var res = await http.put(
        Uri.parse(apiUrl + apiUpdateestado + idpedido.toString()),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"estado": estado}),
      );

      if (res.statusCode == 200) {
        // Actualizamos el estado del pedido localmente si la solicitud fue exitosa
        int index = listPedidos.indexWhere((pedido) => pedido.id == idpedido);
        if (index != -1) {
          listPedidos[index].estado = estado;
          notifyListeners(); // Notificamos a los widgets escuchando que la lista ha cambiado
        }
      } else {
        throw Exception('Error al actualizar el estado: ${res.statusCode}');
      }
    } catch (error) {
      throw Exception("Error en la solicitud: $error");
    }
  }
}
