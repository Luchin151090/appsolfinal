import 'dart:math';

import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/components/newdriver3.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/pedido_conductor_model.dart';
import 'package:appsol_final/models/pedido_detalle_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto_model.dart';

class Navegacion extends StatefulWidget {
  final LatLng destination;

  const Navegacion({super.key, required this.destination});

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  List<LatLng> polypoints = [];
  String _mapStyle = '';
  GoogleMapController? _mapController;
  double _tilt = 0.0; // Variable para la inclinación del mapa

  ///variables
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  String updatedeletepedido = '/api/revertirpedidocan/';

  List<Pedido> listPedidosbyRuta = [];
  int cantidadpedidos = 0;
  List<String> nombresproductos = [];
  List<Producto> listProducto = [];
  int cantidadproducto = 0;
  List<DetallePedido> detalles = [];
  Map<String, int> grouped = {};

  String groupedJson = "na";
  String mensajedelete = "No procesa";
  int activeOrderIndex = 0;
  String motivo = "NA";
  // variables
  LatLng _currentPosition = const LatLng(-16.4014, -71.5343);
  double _currentBearing = 0.0;
  double _currentzoom = 16.0;
  List<Map<String, dynamic>> result = [];
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;
  int anulados = 0;

  void _showdialoganulados() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: anulados > 0
                ? const Text(
                    'Atención se anuló el pedido',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text(
                    "No hay pedidos anulados",
                    style: TextStyle(color: Colors.white),
                  ),
            content: anulados > 0
                ? const Text(
                    'Se añadió un pedido más a tu ruta.',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text(
                    "Continúa con tus pedidos.",
                    style: TextStyle(color: Colors.white),
                  ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    anulados = 0;
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

  Future<dynamic> anularPedido(int? idpedido, String motivo) async {
    //print("*****************************dentro de anular");
    try {
      var res = await http.delete(
          Uri.parse(apiUrl + updatedeletepedido + idpedido.toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"motivoped": "conductor: $motivo"}));

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            mensajedelete = "Pedido revertido o eliminado";
          });
        }
      }
    } catch (error) {
      throw Exception("$error");
    }
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

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadMarkerIcons();
    // getPolypoints();
    _getCurrentLocation();
    final socketService = SocketService();
    socketService.listenToEvent('pedidoanulado', (data) async {
      // print("----anulando ---- pedido");
      // print("dentro del evento");
      final pedidosProvider = Provider.of<PedidoconductorProvider>(context, listen: false);

      //  print(rutaid);

      if (pedidosProvider.getIdRuta() == data['ruta_id']) {
        //     print("---entro a ala ruta_od");
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.red,
                title: const Text(
                  'Un pedido ha sido anulado',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                    'Un pedido con el que estabas trabajando ha sido cancelado. Por favor, revisa tu lista de pedidos.',
                    style: TextStyle(color: Colors.white)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const Driver1())); // Navega a la lista de pedidos
                    },
                    child: const Text('Ver Pedidos',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        }

        /*showDialog(context: context,
         builder: (BuildContext context){
          return const AlertDialog(
            backgroundColor: Colors.red,
            title: Text('Atención se anuló un pedido de tu ruta. Revísalo' ));
          
          
         });*/
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  double _calculateBearing(LatLng start, LatLng end) {
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
  }

  Future<void> _getCurrentLocation() async {
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
    LocationData _locationData = await location.getLocation();
    _updatePosition(_locationData);

    // Escuchar las actualizaciones de la ubicación
    location.onLocationChanged.listen((LocationData currentLocation) {
      _updatePosition(currentLocation);
    });
  }

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
    getPolypoints();
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('lib/imagenes/estilomapa.json');
    setState(() {
      _mapStyle = style;
    });
  }

  void getPolypoints() async {
    if (_currentPosition.latitude < -90 ||
        _currentPosition.latitude > 90 ||
        _currentPosition.longitude < -180 ||
        _currentPosition.longitude > 180 ||
        widget.destination.latitude < -90 ||
        widget.destination.latitude > 90 ||
        widget.destination.longitude < -180 ||
        widget.destination.longitude > 180) {
      //print("Las coordenadas ingresadas están fuera de rango.");
      return;
    }

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: "AIzaSyA45xOgppdm-PXYDE5r07eDlkFuPzYmI9g",
        request: PolylineRequest(
          origin: PointLatLng(
              _currentPosition.latitude, _currentPosition.longitude),
          destination: PointLatLng(
              widget.destination.latitude, widget.destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.status == "OK" && result.points.isNotEmpty) {
        setState(() {
          polypoints.clear();
          result.points.forEach((PointLatLng point) {
            polypoints.add(LatLng(point.latitude, point.longitude));
          });
        });
      } else if (result.status == "ZERO_RESULTS") {
        //  print("No se encontraron resultados para la ruta.");
      } else {
        //print("Error al obtener la ruta: ${result.status}");
      }
    } catch (e) {
      //print("Error al obtener la ruta: $e");
    }
  }

  void _tiltMap() {
    setState(() {
      _tilt = (_tilt == 0.0) ? 85.0 : 0.0;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentzoom + 4,
          tilt: _tilt,
          bearing: _currentBearing,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String telefonopedido) async {
    //print("alo");
    //print(telefonopedido);
    final Uri _phoneUri = Uri(
      scheme: 'tel',
      path:
          telefonopedido, // Cambia esto al número de teléfono que quieras marcar
    );

    if (!await launchUrl(_phoneUri)) {
      throw Exception('No se pudo realizar la llamada a $_phoneUri');
    }
  }

  void _launchMaps(double lat, double lng) async {
    final Uri googleMapsUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await launchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final pedidosProvider =
        Provider.of<PedidoconductorProvider>(context, listen: false);
    final cardpedidoProvider =
        Provider.of<CardpedidoProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: MediaQuery.of(context).size.height / 18,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Navegación",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 29),
            ),
            Badge(
              largeSize: 18,
              backgroundColor: anulados > 0
                  ? const Color.fromARGB(255, 243, 33, 82)
                  : Color.fromARGB(255, 0, 0, 0),
              label: Text(anulados.toString(),
                  style: const TextStyle(fontSize: 12)),
              child: IconButton(
                onPressed: () {
                  //getPedidosConductor();
                  _showdialoganulados();
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                iconSize: MediaQuery.of(context).size.width / 13.5,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          
          Container(
            padding: const EdgeInsets.all(3),
            height: MediaQuery.of(context).size.height / 1.22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              //color: Color.fromARGB(255, 62, 74, 98)
            ),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: _currentzoom,
                target: _currentPosition,
                tilt: _tilt,
              ),
              mapType: MapType.normal,
              style: _mapStyle,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onCameraMove: (CameraPosition position) {
                _currentBearing = position.bearing; // Update the bearing
                _currentzoom = position.zoom; // Update the zoom level
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId("RUTA"),
                  points: polypoints,
                  color: Color.fromARGB(255, 163, 5, 236),
                  width: 5,
                ),
              },
              markers: {
                if (_originIcon != null)
                  Marker(
                    markerId: MarkerId("origen"),
                    position: _currentPosition,
                    icon: _originIcon!,
                    //rotation: _currentBearing - 245,
                  ),
                if (_destinationIcon != null)
                  Marker(
                    markerId: MarkerId("destino"),
                    position: widget.destination,
                    icon: _destinationIcon!,
                    //rotation: _currentBearing,
                  ),
              },
            ),
          ),
          Positioned(
            bottom: 140,
            left: 16,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 20,
              //color: const Color.fromARGB(255, 36, 157, 40),
              child: ElevatedButton(
                  onPressed: () {
                    print(
                        "....esta es la ubicacion: ${widget.destination.latitude} ${widget.destination.longitude}");
                    _launchMaps(widget.destination.latitude,
                        widget.destination.longitude);
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 1, 163, 14)
                          )),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Navegar con :",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        Container(
                            width: 50,
                            height: 50,
                            // padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.grey,
                                image: const DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('lib/imagenes/mapa2.jpg')))),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            bottom: 206,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color.fromRGBO(0, 38, 255, 1),
              onPressed: () {
                _tiltMap();
              },
              child: const Icon(
                Icons.navigation_outlined,
                color: Colors.white,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize:
                0.1, // Tamaño inicial del widget en porcentaje de la pantalla
            minChildSize:
                0.1, // Tamaño mínimo del widget en porcentaje de la pantalla
            maxChildSize:
                0.4, // Tamaño máximo del widget en porcentaje de la pantalla
            builder: (BuildContext context, ScrollController controller) {
              return Container(
                //color: const Color.fromARGB(255, 144, 141, 141),
                decoration: BoxDecoration(
                    borderRadius:const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    color: const Color.fromRGBO(0, 38, 255, 1).withOpacity(0.95)
                   
                    
                    ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: Text(
                        'Detalles',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(Icons.keyboard_double_arrow_up,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width/18,),
                    const SizedBox(height: 4.0),
                    // Línea de agarre
                    Container(
                      height: 4.0,
                      width: MediaQuery.of(context).size.width / 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                       // color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      height: MediaQuery.of(context).size.height / 3.5,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Orden ID#",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Estado: ${cardpedidoProvider.pedido?.estado}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 85, 7, 255)),
                              ),
                              Text("${cardpedidoProvider.pedido?.id}")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 19,
                                height: MediaQuery.of(context).size.width / 19,
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Punto de entrega",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 255, 61, 7),
                                              title: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    "Anular pedido",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "La entrega del pedido se anulará",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextField(
                                                    onChanged: (value) {
                                                      motivo =
                                                          value; // Actualiza el motivo cuando el usuario escribe
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Ingrese el motivo de la cancelación',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () async {
                                                     await anularPedido(
                                                          cardpedidoProvider
                                                              .pedido?.id,
                                                          motivo);
                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.pink,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      pedidosProvider
                                                          .getPedidosConductor();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Continuar",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              236,
                                                              253,
                                                              4)),
                                                    )),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255)),
                                                    )),
                                              ],
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 255, 0, 0))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Anular",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          /*Text(
                            "${cardpedidoProvider.pedido?.direccion}",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),*/
                          Text(
                              "Total: S/. ${cardpedidoProvider.pedido?.precio}",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 30, 160),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // DETALLES
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await getDetalleXUnPedido(
                                          cardpedidoProvider.pedido?.id);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.75),
                                              child: Container(
                                                padding: EdgeInsets.all(22),
                                                decoration: BoxDecoration(
                                                    //color: Color.fromARGB(255, 218, 218, 218).withOpacity(0.75),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    1.5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Orden N#",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22),
                                                        ),
                                                        Text(
                                                          "${cardpedidoProvider.pedido?.id}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.blue,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Cliente",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                        "${cardpedidoProvider.pedido?.nombres}"),
                                                    Text(
                                                        "${cardpedidoProvider.pedido?.nombres}"),
                                                    Text(
                                                        "${cardpedidoProvider.pedido?.telefono}"),
                                                    Text(
                                                        "${cardpedidoProvider.pedido?.tipo}"),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              30,
                                                          decoration: BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  223, 205, 84),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50)),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Contenido",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              5,
                                                      // color: Colors.white,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            cardpedidoProvider
                                                                .pedido
                                                                ?.detallepedido
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Row(
                                                            children: [
                                                              Text(
                                                                cardpedidoProvider
                                                                            .pedido
                                                                            ?.detallepedido[index][
                                                                                'nombre_prod']
                                                                            .toUpperCase() ==
                                                                        'BOTELLA 3L'
                                                                    ? cardpedidoProvider
                                                                            .pedido
                                                                            ?.detallepedido[index][
                                                                                'nombre_prod']
                                                                            .toUpperCase() +
                                                                        ' X PQTES : '
                                                                    : cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() ==
                                                                            'BOTELLA 700ML'
                                                                        ? cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() +
                                                                            ' X PQTES : '
                                                                        : cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() ==
                                                                                'BIDON 20L'
                                                                            ? cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() +
                                                                                ' X UND : '
                                                                            : cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'RECARGA'
                                                                                ? cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                : cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() == 'BOTELLA 7L'
                                                                                    ? cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase() + ' X UND : '
                                                                                    : cardpedidoProvider.pedido?.detallepedido[index]['nombre_prod'].toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "${cardpedidoProvider.pedido?.detallepedido[index]['cantidad']}",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.amber)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Detalles",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.visibility_outlined,
                                          color: Colors.black,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                        )
                                      ],
                                    )),
                              ),

                              // COBRAR
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Cobrar()));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color.fromARGB(255, 38, 111, 48)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Cobrar ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35)),
                                      //const SizedBox(width: 5),
                                      Icon(Icons.attach_money_rounded,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),

                              // LLAMAR
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.height / 23,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //print("------llamandoooo aloooo ");
                                    // print(cardpedidoProvider.pedido!.telefono);
                                    _makePhoneCall(
                                        cardpedidoProvider.pedido!.telefono);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Color.fromARGB(255, 61, 69, 187)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Llamar ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  35)),
                                    //  const SizedBox(width: 10),
                                      Icon(Icons.phone,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              35,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                    // Agrega más widgets aquí según lo necesites
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
