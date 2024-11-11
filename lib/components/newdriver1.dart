import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/newdriver2.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/models/pedidocardmodel.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

class Driver1 extends StatefulWidget {
  const Driver1({super.key});

  @override
  State<Driver1> createState() => _Driver1State();
}

class _Driver1State extends State<Driver1> {
  GoogleMapController? _mapController;
  double _tilt = 0.0; // Variable para la inclinación del mapa
  String _mapStyle = '';
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  String apiUpdateestado = '/api/estadoflash/';
  List<Pedido> listPedidosbyRuta = [];
  LatLng _currentPosition = const LatLng(-16.4014, -71.5343);
  double _currentBearing = 0.0;
  int cantidadpedidos = 0;
  List<String> nombresproductos = [];
  List<Producto> listProducto = [];
  int cantidadproducto = 0;
  List<DetallePedido> detalles = [];
  Map<String, int> grouped = {};
  List<Map<String, dynamic>> result = [];
  String groupedJson = "na";
  int activeOrderIndex = 0;
  int rutaCounter = 0;
  final socketService = SocketService();

  /*void _verificarContador(int rutitacontador){
    print("......verificaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    if(rutitacontador>2){
     // rutaCounter = 1;
      _showdialogconductor();
    }
  }*/
  bool aceptePedido = false;
  bool esmiusuario = false;
  bool notificaron = false;
  int conductoridescuchado = 0;
  int pedidoescuchado = 0;
  String estadoescuchado = "NA";
  int pedidoguardado = 0;
  int pedidonotificado = 0;
  String nombreconductor = "NA";
  String tiempoaceptado = "NA";
  String apiAceptadopor = "/api/aceptarpedido";
  double _currentzoom = 16.0;
  List<LatLng> polypoints = [];
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;
  Future<dynamic> aceptadoPor(int? conductor, int pedido, int orden) async {
    final pedidosProvider =
        Provider.of<PedidoconductorProvider>(context, listen: false);
    try {
      DateTime horaactual = DateTime.now();
      print("---------------ACEPTAROD ..........");
      var res = await http.post(Uri.parse(apiUrl + apiAceptadopor),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "conductor_id": conductor,
            "pedido_id": pedido,
            "fecha_aceptacion": horaactual.toString()
          }));
      print("........RES ${res.body}");
      if (res.statusCode == 200) {
        print("post de consulta ok");
      } else {
        print("post incorrecto");
      }
    } catch (error) {
      throw Exception("Error de query aceptar: ${error}");
    }
  }

  void _showdialogconductor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: rutaCounter > 0
                ? const Text('Nuevo pedido')
                : const Text("Sin pedidos"),
            content: rutaCounter > 0
                ? const Text('Se añadió un pedido.')
                : const Text("Aún no hay pedidos nuevos."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    rutaCounter = 0;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(), //?,
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();
        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    return Future.value(
        false); // Previene el comportamiento predeterminado de retroceso
  }

  /* Future<dynamic> getPedidosConductor() async {
    setState(() {
      activeOrderIndex++;
    });
    //print("get pedidos conduc");
    SharedPreferences rutaidget = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    int? iduser = userPreference.getInt('userID');
    int? rutaid = 19;// rutaidget.getInt('rutaIDNEW');
  //  print("datos ruta : ${rutaidget.getInt('rutaIDNEW')}");
    //print("datos id usuario: ${iduser}");

    var res = await http.get(
      Uri.parse("$apiUrl$apiPedidosConductor$rutaid}"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
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
              comentario: mapa['observacion'] ?? 'sin comentarios');
        }).toList();
        //SE SETEA EL VALOR DE PEDIDOS BY RUTA


        /// AQUI GUARDAMOS LA LISTA EN EL PROVIDER , PARA LA LOGICA DE ELIMINACION EN VISTA 
        Provider.of<PedidoconductorProvider>(context,listen: false).setPedidos(listTemporal);


        if (mounted) {
          setState(() {
            listPedidosbyRuta = listTemporal;
            cantidadpedidos = listPedidosbyRuta.length;

          });
        }
      //  print("----pedidos lista conductor");
       // print(listPedidosbyRuta);
      }
    } catch (error) {
      throw Exception("Error de consulta $error");
    }
  }*/

  Future<dynamic> getDetalleXUnPedido(pedidoID) async {
    //print("-----detalle pedido");
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + pedidoID.toString()),
        headers: {"Content-type": "application/json"},
      );
      // print(res.body);
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          print(data);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['pedido_id'],
              productoID: mapa['producto_id'],
              productoNombre: mapa['nombre_prod'],
              cantidadProd: mapa['cantidad'],
              promocionID: mapa['promocion_id'],
              promocionNombre: mapa['nombre_prom'],
            );
          }).toList();
          // print("${listTemporal.first.productoNombre}");
          // Agrupar y sumar las cantidades
          grouped = {};
          result = [];
          for (var i = 0; i < listTemporal.length; i++) {
            String nombreProd = listTemporal[i].productoNombre;
            int cantidad = listTemporal[i].cantidadProd;

            if (grouped.containsKey(nombreProd)) {
              grouped[nombreProd] = grouped[nombreProd]! + cantidad;
            } else {
              grouped[nombreProd] = cantidad;
            }
          }
          // Crear la lista de resultados

          grouped.forEach((nombreProd, cantidad) {
            result.add({'nombre_prod': nombreProd, 'cantidad': cantidad});
          });
          // Convertir a JSON
          groupedJson = jsonEncode(result);

          // Imprimir el resultado
          //  print(groupedJson);
          /*r (var i = 0; i < listProducto.length; i++) {
              if (listProducto[i].cantidad != 0) {
                var salto = '\n';
                if (productosYCantidades == '') {
                  setState(() {
                    productosYCantidades =
                        "${listProducto[i].nombre} x ${listProducto[i].cantidad.toString()} uds."
                            .toUpperCase();
                  });
                } else {
                  setState(() {
                    productosYCantidades =
                        "$productosYCantidades $salto${listProducto[i].nombre.toUpperCase()} x ${listProducto[i].cantidad.toString()} uds.";
                  });
                }
                break;
              }
            }*/
        }
      } catch (e) {
        //print('Error en la solicitud: $e');
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      //print('papas');
    }
  }

/*

 void connectToServer()  {

    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 500,
      'reconnectionDelayMax': 2000,
    });
    socket.connect();
    socket.onConnect((_) {
    //  print('Conexión establecida: CONDUCTOR');

    });
    socket.onDisconnect((_) {
    //  print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {

    });
    socket.onError((error) {

    });

    socket.on(
      'pedidoañadido',
      (data) {
        print("entrando--------");
        print(data);
       

          setState(() {
          rutaCounter = rutaCounter +
              1; 
        });
        
        _showdialogconductor();

        
        print("CANTIDAD TOTAL DE PEDIDOS ELIMINADOS-------------------");
        print(rutaCounter);
      },
    );
  }*/

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  /*double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = _toRadians(start.latitude);
    double lon1 = _toRadians(start.longitude);
    double lat2 = _toRadians(end.latitude);
    double lon2 = _toRadians(end.longitude);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x);
    bearing = _toDegrees(bearing);
    return (bearing + 360) % 360;
  }*/

  /*Future<void> _getCurrentLocation() async {
    // print("-------------------------Llamando a current position");
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Obtener la ubicación inicial
    /*LocationData _locationData = await location.getLocation();
    _updatePosition(_locationData);

    // Escuchar las actualizaciones de la ubicación
    location.onLocationChanged.listen((LocationData currentLocation) {
      _updatePosition(currentLocation);
    });*/
  }*/
/*
  void _updatePosition(LocationData locationData) {
    if (!mounted) return;

    LatLng newPosition =
        LatLng(locationData.latitude!, locationData.longitude!);

    // Calcular el bearing si hay una posición anterior
    if (_currentPosition != newPosition) {
      double newBearing = _calculateBearing(_currentPosition, newPosition);
      setState(() {
        _currentBearing = newBearing;
        _currentPosition = newPosition;
      });
    }

    // Animar la cámara a la nueva posición y orientación
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentzoom,
          tilt: _tilt,
          bearing: _currentBearing,
        ),
      ),
    );

    // Actualizar los puntos de la polyline
   // getPolypoints();
  }*/

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('lib/imagenes/estilomapa.json');
    setState(() {
      _mapStyle = style;
    });
  }

  Future<void> _loadMarkerIcons() async {
    _originIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Tamaño del icono
      'lib/imagenes/carropin_final.png',
    );
    _destinationIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/imagenes/pin_casa_final.png',
    );
  }

  /// nueva función
  // Función para obtener los puntos de la ruta
/*Future<List<LatLng>> getPolypoints(LatLng origin, LatLng destination) async {
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polyPoints = [];

  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleApiKey: "AIzaSyA45xOgppdm-PXYDE5r07eDlkFuPzYmI9g",
    request: PolylineRequest(
      origin: PointLatLng(origin.latitude, origin.longitude),
       destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving)

  );

  if (result.points.isNotEmpty) {
    for (var point in result.points) {
      polyPoints.add(LatLng(point.latitude, point.longitude));
    }
  }

  return polyPoints;
}*/
// Función para obtener los puntos de la ruta con validación y manejo de errores
  Future<List<LatLng>> getPolypoints(LatLng origin, LatLng destination) async {
    List<LatLng> polyPoints = [];

    // Validación de coordenadas fuera de rango
    if (origin.latitude < -90 ||
        origin.latitude > 90 ||
        origin.longitude < -180 ||
        origin.longitude > 180 ||
        destination.latitude < -90 ||
        destination.latitude > 90 ||
        destination.longitude < -180 ||
        destination.longitude > 180) {
      print("Las coordenadas ingresadas están fuera de rango.");
      return polyPoints; // Retorna la lista vacía
    }

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey:
            "AIzaSyA45xOgppdm-PXYDE5r07eDlkFuPzYmI9g", // Asegúrate de usar tu API Key
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving, // Puedes cambiar a walking, biking, etc.
        ),
      );

      if (result.status == "OK" && result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polyPoints.add(LatLng(point.latitude, point.longitude));
        });
        print("Puntos de la ruta obtenidos correctamente.");
      } else if (result.status == "ZERO_RESULTS") {
        print("No se encontraron resultados para la ruta.");
      } else {
        print("Error al obtener la ruta: ${result.status}");
      }
    } catch (e) {
      print("Error al obtener la ruta: $e");
    }

    return polyPoints;
  }

  @override
  void initState() {
    super.initState();
    getProducts();
    _loadMapStyle();
    _loadMarkerIcons();
    // _getCurrentLocation();
    // getPedidosConductor();
    /*final pedidosProvider = Provider.of<PedidoconductorProvider>(context, listen: false);
    pedidosProvider.getPedidosConductor();*/
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    /*  final pedidosProvider =
        Provider.of<PedidoconductorProvider>(context, listen: false);
    pedidosProvider.getPedidosConductor();*/
    // socketService.connectToServer(apiUrl);
    /* if(rutaCounter>0){
      _showdialogconductor();
    }*/
    socketService.onPedidoAnadido((data) async {
      if (!mounted) return;
      print("Pedido añadido: $data");

      // Actualizar el estado
      setState(() {
        rutaCounter++;
      });

      // Asegúrate de que el contexto aún es válido
      if (mounted) {
        final pedidosProvider =
            Provider.of<PedidoconductorProvider>(context, listen: false);
        await pedidosProvider.getPedidosConductor();

        // Usar addPostFrameCallback para mostrar el SnackBar después de la actualización del estado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Verifica nuevamente si el widget está montado
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pedido añadido'),
                    Icon(Icons.local_shipping_outlined, color: Colors.white),
                  ],
                ),
                backgroundColor: Color.fromARGB(255, 42, 30, 174),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    });

    /////
    /* socketService.listenToEvent('pedidoañadido', (data) async {
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      print("------esta es la PEDIDO AÑADIDO");
      //print(data);

      //final userProvider = Provider.of<UserProvider>(context, listen: false);

      //if (data['conductor_id'] == userProvider.user?.id) {
      print("entro al fi");

      setState(() {
        rutaCounter = rutaCounter + 1;
        print("ruta ---counter");
        print(rutaCounter);
      });

      //_showdialogconductor();
      // _verificarContador(rutaCounter);
      setState(() {
        rutaCounter = 1;
      });

      // }
      final pedidosProvider =
          Provider.of<PedidoconductorProvider>(context, listen: false);
      pedidosProvider.getPedidosConductor();
    });*/
    ///

    socketService.listenToEvent('aceptado', (data) async {
      if (!mounted) return;
      final pedidosProvider =
          Provider.of<PedidoconductorProvider>(context, listen: false);

      print("----PEDIDO ACEPTADO");
      print("$data");
      setState(() {
        pedidoescuchado = data['id'];
        estadoescuchado = data['estado'];
        print("VARIABLES.....");
        print(pedidoescuchado);
        print(estadoescuchado);
        //pedidosProvider.getPedidosConductor();
      });
    });

    socketService.listenToEvent('notificarConductores', (data) async {
      if (!mounted) return;
      print("escucho a mi compañero ...");
      print("$data");
      final pedidosProvider =
          Provider.of<PedidoconductorProvider>(context, listen: false);
      SharedPreferences aceptadoporpref = await SharedPreferences.getInstance();

      setState(() {
        conductoridescuchado = data['conductor'];
        print("conductor $conductoridescuchado");
        pedidonotificado = data['pedido'];
      });
      print("id usuario ${userProvider.user?.id}");

      if (userProvider.user?.id != data['conductor']) {
        aceptadoporpref.setInt('conductorID', data['conductor']);
        pedidosProvider.setAceptadopor(data['nombre']);

        // pedidosProvider.rechazarPedidos(data['pedido']);
      } else {
        aceptadoporpref.setInt('conductorID', data['conductor']);
        pedidosProvider.setAceptadopor(userProvider.user!.nombre);
      }
    });

    //connectToServer();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
    //socketService.dispose();
  }

  @override
  void didChangeDependencies() {
    print(".....DID CHANGE......");
    // FUNCIONA TRAYENDO LOS DATOS DINAMICAMENTE, SI SE QUIERE REFRESCAR CONSTANTEMENTE LA VISTA
    super.didChangeDependencies();
    final pedidosProvider =
        Provider.of<PedidoconductorProvider>(context, listen: false);
    // Cargar los pedidos si la lista está vacía
    if (pedidosProvider.pedidos.isEmpty) {
      pedidosProvider.getPedidosConductor();
    }
  }

  @override
  Widget build(BuildContext context) {
    //final cardpedidoProvider = Provider.of<CardpedidoProvider>(context, listen: false);
    final pedidosProvider = context.watch<PedidoconductorProvider>();
    //final pedidosProvider = Provider.of<PedidoconductorProvider>(context);
    final cardpedidoProvider = context.watch<CardpedidoProvider>();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("mi id user provider es: ${userProvider.user?.id}");

    return /* WillPopScope(
      onWillPop: _onWillPop,
      child:*/
        Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 18,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pedidos',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 29,
                    color: Color.fromARGB(255, 0, 0, 0))),
            /*IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Aceptados por:"),
                        );
                      });
                },
                icon: const Icon(Icons.pan_tool_outlined).animate().shakeX())*/
          ],
        ),
        /* leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Driver()),
              ); // Regresa a Bienvenido
            },
          ),*/
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("lib/imagenes/olas2.jpg"), // Ruta de la imagen
                fit: BoxFit.fill, // Ajusta la imagen al tamaño de la pantalla
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              //color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CABECERA INFORME Y NOTIFICATION
                  Container(
                    // color: Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            pedidosProvider.pedidos.length > 0
                                ? "Ruta N° ${pedidosProvider.getIdRuta()} - Total: ${pedidosProvider.listPedidos.length}"
                                : "*",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      await pedidosProvider.getPedidosConductor();
                    },
                    child: Container(
                      // color: Colors.grey,
                      height: MediaQuery.of(context).size.height / 1.2,
                      child: Consumer<PedidoconductorProvider>(
                        builder: (context, pedidosProvider, child) {
                          // NUEVA VARIABLE A UTILIZAR
                          final listpedidosconductorruta =
                              pedidosProvider.listPedidos;
                          return ListView.builder(
                              itemCount: listpedidosconductorruta.length,
                              itemBuilder: (context, index) {
                                bool isActive = index == activeOrderIndex;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(20),
                                  height:
                                      MediaQuery.of(context).size.height * 0.48,
                                  decoration: BoxDecoration(
                                      color: listpedidosconductorruta[index].estado ==
                                              'en proceso'
                                          ? (listpedidosconductorruta[index].id ==
                                                          pedidonotificado &&
                                                      userProvider.user?.id ==
                                                          conductoridescuchado
                                                  ? Color.fromARGB(
                                                      255, 255, 255, 255)
                                                  : const Color.fromARGB(
                                                      255, 209, 209, 209))
                                              .withOpacity(0.85)
                                          : listpedidosconductorruta[index].estado ==
                                                  'entregado'
                                              ? Color.fromARGB(255, 30, 175, 25)
                                                  .withOpacity(0.85)
                                              : listpedidosconductorruta[index].estado ==
                                                      'anulado'
                                                  ? Color.fromARGB(255, 255, 2, 2)
                                                      .withOpacity(0.85)
                                                  : Color.fromRGBO(0, 38, 255, 1)
                                                      .withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Orden ID#",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    listpedidosconductorruta[index]
                                                                .estado ==
                                                            'en proceso'
                                                        ? const Color.fromARGB(
                                                            255, 0, 0, 0)
                                                        : Colors.white),
                                          ),
                                          Text(
                                            "${listpedidosconductorruta[index].id}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    listpedidosconductorruta[index]
                                                                .estado ==
                                                            'en proceso'
                                                        ? const Color.fromARGB(
                                                            255, 0, 0, 0)
                                                        : Colors.white),
                                          ),
                                          Text(
                                            "Estado: ${listpedidosconductorruta[index].estado}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: listpedidosconductorruta[
                                                                index]
                                                            .estado ==
                                                        'en proceso'
                                                    ? Color.fromARGB(
                                                        255, 0, 0, 0)
                                                    : Colors
                                                        .white // Color para 'en proceso'

                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // CIRCULO
                                          Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    19,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    19,
                                                decoration: BoxDecoration(
                                                    color:
                                                        listpedidosconductorruta[
                                                                        index]
                                                                    .tipo ==
                                                                'normal'
                                                            ? const Color
                                                                .fromARGB(255,
                                                                34, 223, 16)
                                                            : const Color
                                                                .fromARGB(255,
                                                                255, 4, 234),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                "F: ${listpedidosconductorruta[index].fecha.split('T')[0]} / H: ${listpedidosconductorruta[index].fecha.split('T')[1].split('.')[0]}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.029,
                                                    color:
                                                        listpedidosconductorruta[
                                                                        index]
                                                                    .estado ==
                                                                'en proceso'
                                                            ? Colors.black
                                                            : Colors.white),
                                              ),
                                            ],
                                          ),

                                          Text(
                                            "Pedido: ${listpedidosconductorruta[index].tipo}",
                                            style: TextStyle(
                                                color: listpedidosconductorruta[
                                                                index]
                                                            .estado ==
                                                        'en proceso'
                                                    ? Color.fromARGB(
                                                        255, 0, 0, 0)
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),

                                          /*Text(listpedidosconductorruta[index].estado !='pendiente' ? (listpedidosconductorruta[index].id == pedidonotificado 
                                                && userProvider.user?.id == conductoridescuchado ?
                                                 "Aceptado por: ${userProvider.user?.nombre}" : "Aceptado por: Compañero") : '',
                    
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(255, 124, 58, 138)
                                                ),)*/
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          overflow: TextOverflow.ellipsis,
                                          "Dirección: ${listpedidosconductorruta[index].direccion}",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  29,
                                              fontWeight: FontWeight.bold,
                                              color: listpedidosconductorruta[
                                                              index]
                                                          .estado ==
                                                      'en proceso'
                                                  ? const Color.fromARGB(
                                                      255, 0, 0, 0)
                                                  : Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      


                                      
                                      Text(
                                          "Total: S/. ${listpedidosconductorruta[index].montoTotal}",
                                          style: TextStyle(
                                              color: listpedidosconductorruta[
                                                              index]
                                                          .estado ==
                                                      'en proceso'
                                                  ? Color.fromARGB(255, 0, 0, 0)
                                                  : Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  25,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                9,
                                      ),
                                      Column(
                                        //  crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  pedidosProvider.rechazarPedidos(
                                                      listpedidosconductorruta[
                                                              index]
                                                          .id);
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            Color.fromARGB(255,
                                                                255, 110, 66))),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text("Rechazar pedido",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    SizedBox(width: 10),
                                                    Icon(
                                                        Icons
                                                            .delete_forever_rounded,
                                                        color: Colors.white),
                                                  ],
                                                ),
                                              )),
                                          Container(
                                            //color: Colors.grey,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: listpedidosconductorruta[
                                                            index]
                                                        .estado !=
                                                    'anulado'
                                                ? ElevatedButton(
                                                    onPressed: () async {
                                                      await getDetalleXUnPedido(
                                                          listpedidosconductorruta[
                                                                  index]
                                                              .id);
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        22),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        //color: const Color.fromARGB(255, 124, 111, 111),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "Orden N#",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: MediaQuery.of(context).size.width / 22),
                                                                        ),
                                                                        Text(
                                                                          "${listpedidosconductorruta[index].id}",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: MediaQuery.of(context).size.width / 22),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          width:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.blue,
                                                                              borderRadius: BorderRadius.circular(50)),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        const Text(
                                                                          "Cliente",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                      "${listpedidosconductorruta[index].nombre}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 28),
                                                                    ),
                                                                    /*Text(
                                                                      "Teléfono: ${listpedidosconductorruta[index].telefono}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 28),
                                                                    ),*/
                                                                    Text(
                                                                      "Tipo: ${listpedidosconductorruta[index].tipo}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 28),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          width:
                                                                              MediaQuery.of(context).size.height / 30,
                                                                          decoration: BoxDecoration(
                                                                              color: const Color.fromARGB(255, 223, 205, 84),
                                                                              borderRadius: BorderRadius.circular(50)),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        const Text(
                                                                          "Contenido",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      height:
                                                                          MediaQuery.of(context).size.height /
                                                                              5,
                                                                      // color: Colors.white,
                                                                      child: ListView
                                                                          .builder(
                                                                        itemCount:
                                                                            result.length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return Row(
                                                                            children: [
                                                                              Text(
                                                                                result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 3L'
                                                                                    ? result[index]['nombre_prod'].toUpperCase() + ' X PQTES : '
                                                                                    : result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 700ML'
                                                                                        ? result[index]['nombre_prod'].toUpperCase() + ' X PQTES : '
                                                                                        : result[index]['nombre_prod'].toUpperCase() == 'BIDON 20L'
                                                                                            ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                            : result[index]['nombre_prod'].toUpperCase() == 'RECARGA'
                                                                                                ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                                : result[index]['nombre_prod'].toUpperCase() == 'BOTELLA 7L'
                                                                                                    ? result[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                                    : result[index]['nombre_prod'].toUpperCase(),
                                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              Text(
                                                                                "${result[index]['cantidad']}",
                                                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });

                                                      //  cantidadproducto = 0;
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all(Colors
                                                                    .amber)),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Detalles de pedido",
                                                          style: TextStyle(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  0, 0, 0)),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .visibility_outlined,
                                                          color: Colors.black,
                                                        )
                                                      ],
                                                    ))
                                                : null,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: listpedidosconductorruta[
                                                            index]
                                                        .estado !=
                                                    'anulado'
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      double latitudp =
                                                          listpedidosconductorruta[
                                                                  index]
                                                              .latitud;
                                                      double longitudp =
                                                          listpedidosconductorruta[
                                                                  index]
                                                              .longitud;
                                                      LatLng coordenadapedido =
                                                          LatLng(latitudp,
                                                              longitudp);
                                                      print(
                                                          "coordenada pedido");
                                                      print(coordenadapedido);

                                                      Cardpedidomodel carta = Cardpedidomodel(
                                                          id: listpedidosconductorruta[index]
                                                              .id,
                                                          estado: listpedidosconductorruta[index]
                                                              .estado,
                                                          direccion:
                                                              listpedidosconductorruta[index]
                                                                  .direccion,
                                                          detallepedido: result,
                                                          nombres: listpedidosconductorruta[index]
                                                              .nombre,
                                                          apellidos:
                                                              listpedidosconductorruta[index]
                                                                  .apellidos,
                                                          telefono:
                                                              listpedidosconductorruta[index]
                                                                  .telefono,
                                                          tipo: listpedidosconductorruta[
                                                                  index]
                                                              .tipo,
                                                          precio:
                                                              listpedidosconductorruta[
                                                                      index]
                                                                  .montoTotal,
                                                          beneficiadoid:
                                                              listpedidosconductorruta[
                                                                      index]
                                                                  .beneficiadoID,
                                                          comentarios:
                                                              listpedidosconductorruta[
                                                                      index]
                                                                  .comentario);

                                                      cardpedidoProvider
                                                          .updateCard(carta);

                                                      //
                                                      //  updateestadoaceptar("en proceso",listpedidosconductorruta[index].id);
                                                      pedidosProvider
                                                          .updateestadoaceptar(
                                                              "en proceso",
                                                              listpedidosconductorruta[
                                                                      index]
                                                                  .id);
                                                      //pedidosProvider.getPedidosConductor();
                                                      setState(() {
                                                        pedidoguardado =
                                                            listpedidosconductorruta[
                                                                    index]
                                                                .id;
                                                        print(
                                                            "$pedidoguardado");
                                                      });

                                                      print("hola enviando");

                                                      // ACEPTADO POR LOS PEDIDOS
                                                      aceptadoPor(
                                                          userProvider.user!.id,
                                                          listpedidosconductorruta[
                                                                  index]
                                                              .id,
                                                          index);
                                                      //

                                                      socketService.emitEvent(
                                                          'avisarAceptado', {
                                                        "conductor":
                                                            userProvider
                                                                .user?.id,
                                                        "nombre": userProvider
                                                            .user?.nombre,
                                                        "pedido":
                                                            listpedidosconductorruta[
                                                                    index]
                                                                .id
                                                      });

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Navegacion(
                                                                      destination:
                                                                          coordenadapedido)));

                                                      // Cierra el diálogo después de que la navegación se complete
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(const Color
                                                                  .fromRGBO(0,
                                                                  38, 255, 1)),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text("Aceptar pedido",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 10),
                                                        Icon(
                                                            Icons
                                                                .navigation_outlined,
                                                            color:
                                                                Colors.white),
                                                      ],
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    LatLng destinationNew =
                                                        LatLng(
                                                      listpedidosconductorruta[
                                                              index]
                                                          .latitud,
                                                      listpedidosconductorruta[
                                                              index]
                                                          .longitud,
                                                    );
                                                    List<LatLng> routePoints =
                                                        await getPolypoints(
                                                            _currentPosition,
                                                            destinationNew);

                                                    setState(() {
                                                      polypoints = routePoints;
                                                    });

                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.55,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.75,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20)),
                                                              // color: Color.fromARGB(255, 209, 209, 209),
                                                              child: GoogleMap(
                                                                initialCameraPosition:
                                                                    CameraPosition(
                                                                  zoom:
                                                                      _currentzoom,
                                                                  target:
                                                                      _currentPosition,
                                                                  tilt: _tilt,
                                                                ),
                                                                mapType: MapType
                                                                    .normal,
                                                                // style: _mapStyle,
                                                                onMapCreated:
                                                                    (GoogleMapController
                                                                        controller) {
                                                                  _mapController =
                                                                      controller;
                                                                  // Asegúrate de que el mapa esté completamente cargado antes de llamar a animateCamera
                                                                  // _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
                                                                },

                                                                polylines: {
                                                                  Polyline(
                                                                    polylineId:
                                                                        PolylineId(
                                                                            "RUTA"),
                                                                    points:
                                                                        polypoints,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            163,
                                                                            5,
                                                                            236),
                                                                    width: 5,
                                                                  ),
                                                                },
                                                                markers: {
                                                                  if (_originIcon !=
                                                                      null)
                                                                    Marker(
                                                                      markerId:
                                                                          MarkerId(
                                                                              "origen"),
                                                                      position:
                                                                          _currentPosition,
                                                                      icon:
                                                                          _originIcon!,
                                                                      //rotation: _currentBearing - 245,
                                                                    ),
                                                                  if (_destinationIcon !=
                                                                      null)
                                                                    Marker(
                                                                      markerId:
                                                                          MarkerId(
                                                                              "destino"),
                                                                      position: LatLng(
                                                                          listpedidosconductorruta[index]
                                                                              .latitud,
                                                                          listpedidosconductorruta[index]
                                                                              .longitud),
                                                                      icon:
                                                                          _destinationIcon!,
                                                                      //rotation: _currentBearing,
                                                                    ),
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          "Detalle de dirección"),
                                                      Icon(Icons
                                                          .location_on_outlined)
                                                    ],
                                                  )))
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              });
                          /*const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.pink,
                                            ),
                                          );*/
                        },
                      ),

                      /* : Container(
                                height: MediaQuery.of(context).size.height / 4,
                                //color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.hourglass_bottom_sharp,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: MediaQuery.of(context).size.width /
                                                10)
                                        .animate()
                                        .shakeY(),
                                    Text(
                                      "Espera tus pedidos...",
                                      style: TextStyle(
                                        color: Colors.white,
                                          fontSize:
                                              MediaQuery.of(context).size.width / 20),
                                    )
                                  ],
                                ),
                              ),*/
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
