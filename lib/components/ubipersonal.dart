/*import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:appsol_final/components/hola.dart';

const kGoogleApiKey = "AIzaSyC_DGTR1A486oAHhNG1F6LXKU1AmhjJptY";

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ubipersonal = TextEditingController();
  LatLng _currentPosition =
      LatLng(-16.409047, -71.537451); // Coordenadas iniciales de Arequipa
  Marker? _marker;
  var nombrelugar = "Elige el nombre de tu ubicación";

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: _currentPosition,
      draggable: true,
      onDragEnd: (newPosition) {
        _currentPosition = newPosition;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color.fromRGBO(33, 88, 254, 1),
      body: Container(
        decoration: const BoxDecoration(
          gradient:  LinearGradient(colors: [
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
                    Color.fromRGBO(0, 106, 252, 1.000),

          Colors.white,
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOGO DE SOL
                  Container(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('lib/imagenes/nuevito.png'))),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
        
                  // TITULO
                  Container(
                    //color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Indicanos tu ubicación",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Colors.white),
                    padding: const EdgeInsets.all(0.0),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _addressController,
                      googleAPIKey: kGoogleApiKey,
                      inputDecoration: const InputDecoration(
                        //fillColor: Colors.white,
                        //isDense: true,
        
                        hintText: "Busca tu dirección",
        
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      debounceTime: 400,
                      countries: ["pe"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        setState(() {
                          _currentPosition = LatLng(
                            double.parse(prediction.lat ?? '0'),
                            double.parse(prediction.lng ?? '0'),
                          );
                          _updateMapLocation();
                        });
                      },
                      itemClick: (Prediction prediction) {
                        _addressController.text = prediction.description ?? "";
                        _addressController.selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: prediction.description?.length ?? 0),
                        );
                      },
                      seperatedBuilder: Divider(),
                      containerHorizontalPadding: 10,
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 7),
                              Expanded(
                                  child: Text(
                                "${prediction.description ?? ""}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        );
                      },
                      isCrossBtnShown: true,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.all(19),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Expanded(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition,
                          zoom: 18.0,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: _marker != null ? {_marker!} : {},
                        onCameraMove: (position) {
                          _currentPosition = position.target;
                        },
                      ),
                    ),
                  ),
                  /* Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nombra tu ubicación',
                      ),
                    ),
                  ),*/
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: const Text(
                      "Nombra tu ubicación",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                   const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 197, 197, 197),
                        borderRadius: BorderRadius.circular(20)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Text(
                      "${nombrelugar}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 78, 77, 77),
                          fontSize: 18),
                    )),
                  ),
                   const SizedBox(
                    height: 10-3,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: ElevatedButton(
                                onPressed: () {
                                  print("-------casaaaaaaaa....");
                                  setState(() {
                                    nombrelugar = "Casa";
                                    _nameController.text = nombrelugar;
                                  });
                                },
                                child: const Text(
                                  "Casa",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 48, 42, 246)),
                                ))),
                        Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: ElevatedButton(
                                onPressed: () {
                                  print("-------trabajo....");
                                  setState(() {
                                    nombrelugar = "Trabajo";
                                    _nameController.text = nombrelugar;
                                  });
                                },
                                child: const Text(
                                  "Trabajo",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 48, 42, 246)),
                                ))),
                        Container(
                            child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(15),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5,
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Nombra tu ubicación",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 38, 70, 250),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  controller: _ubipersonal,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Nombre de ubicación',
                                                    labelStyle: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey,
                                                    ),
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey,
                                                    ),
                                                    hintText: 'Ej. Oficina',
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20)),
                                                    //filled: true,
                                                    //fillColor: Colors.white.withOpacity(1),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 15,
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      244,
                                                                      47,
                                                                      87)),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            nombrelugar =
                                                                _ubipersonal.text;
                                                            _nameController.text =
                                                                _ubipersonal.text;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Si",
                                                          style: TextStyle(
                                                              color:
                                                                  Color.fromARGB(
                                                                      255,
                                                                      53,
                                                                      53,
                                                                      249),
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 35,
                                  color: Color.fromARGB(255, 45, 69, 255),
                                )))
                      ],
                    ),
                  ),
                  const SizedBox(height: 10+5,),
                  Container(
                    decoration: BoxDecoration(
                      //color: Color.fromRGBO(58, 182, 0, 1),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Color.fromRGBO(58, 182, 0, 1))
                      ),
                      onPressed: _addLocation,
                      child: Text(
                        "Guardar Ubicación",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width/20,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateMapLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 14.0),
      ),
    );

    setState(() {
      _marker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition,
        draggable: true,
        onDragEnd: (newPosition) {
          _currentPosition = newPosition;
        },
      );
    });
  }

  void _addLocation() {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      print('Ubicación guardada: $name - $_currentPosition');
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 7,
              child: Column(
                children: [
                  const Text(
                    "Felicitaciones, tu nueva ubicación se guardó.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 38, 70, 250),
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BarraNavegacion(
                                    indice: 0,
                                    subIndice: 0,
                                  )),
                        );
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 1, 76, 138),
                            fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
          );
        });
  }
}
*/
import 'dart:convert';
import 'dart:math';

import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:appsol_final/models/ubicaciones_lista_model.dart';
import 'package:appsol_final/models/zona_model.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:appsol_final/components/hola.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const kGoogleApiKey = "AIzaSyA45xOgppdm-PXYDE5r07eDlkFuPzYmI9g";

class MapScreen extends StatefulWidget {
  final int? clienteId;

  //final double? latitud;
  // final double? longitud;

  MapScreen({
    this.clienteId,

    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  GoogleMapController? _mapController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ubipersonal = TextEditingController();
  Map<int, dynamic> mapaLineasZonas = {};
  LatLng _currentPosition =
      LatLng(-16.3988738, -71.5369976); // Coordenadas iniciales de Arequipa
  Marker? _marker;
  late String direccionNueva;
  late String? distrito;
  var nombrelugar = "Elige el nombre de tu ubicación";
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  List<Zona> listZonas = [];
  List<UbicacionModel> listUbicacionesObjetos = [];
  List<String> ubicacionesString = [];
  int? zonaIDUbicacion = 0;
  List<String> tempString = [];
  String apiZona = '/api/zona';
  final FocusNode _focusNode = FocusNode();
  Future<void> _updateMapLocation() async {
    //print("3---------UPDATE");
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 14.0),
      ),
    );

    setState(() {
      _marker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition,
        draggable: true,
        onDragEnd: (newPosition) {
          _currentPosition = newPosition;
        },
      );
    });

    //print("------------------>UBICACION ACTUALIZADA CON LA");
    //print(_marker!.position);

    /*await obtenerDireccion(
        _currentPosition.latitude, _currentPosition.longitude);*/

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );
    } catch (e) {
      // print("Error in reverse geocoding: $e");
    }

    // print("Updated location: ${_currentPosition.latitude}, ${_currentPosition.longitude}");
  }

  Future<void> obtenerDireccion(x, y) async {
    // 3 ...............

    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        print("lugar de la ubicación: $lugar");
        setState(() {
          direccionNueva =
              "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
          setState(() {
            distrito = lugar.locality;
          });
        });
      } else {
        direccionNueva = "Default";
      }
      await puntoEnPoligono(x, y);
    } catch (e) {
      //throw Exception("Error ${e}");
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      //print("Error al obtener la ubicación: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error de Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: const Text(
              'Hubo un problema al obtener la ubicación. Por favor, inténtelo de nuevo.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el AlertDialog
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        latitudUser = x;
        longitudUser = y;
        int suma = 0;
        for (UbicacionModel ubi in listUbicacionesObjetos) {
          if (ubi.direccion != direccionNueva) {
            //son diferentesssss
            suma += 0;
          } else {
            //son iguales
            suma += 1;
          }
        }
        if (suma == 0) {
          //no es igual a ninguna direccion existente
          nuevaUbicacion();
        } else {
          //es igual a una direccion, por lo tanto no se agrega nada
        }
      });
    }
  }

  Future<void> _addLocation() async {
    // obtener
    // print("2-------ADD--LOCATION");
    String name = _nameController.text;
    //if (name.isNotEmpty) {
    print('Ubicación guardada: $name - $_currentPosition');
    await obtenerDireccion(
        _currentPosition.latitude, _currentPosition.longitude);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );
//obtener direcciones await obtener
      /*
        await obtenerDireccion(
            _currentPosition.latitude, _currentPosition.longitude);
*/
      /* if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";
        print('Location saved: $name');
        print('Address: $address');
        print(
            'Coordinates: ${_currentPosition.latitude}, ${_currentPosition.longitude}');
      }*/
      //await _updateMapLocation();
    } catch (e) {
      // print("Error in reverse geocoding: $e");
      //}
    }
  }

  Future<void> nuevaUbicacion() async {
    /*  print("nueva ....................");
    print(widget.clienteId);
    print(distrito);*/
    await creadoUbicacion(widget.clienteId, distrito);
    await getUbicaciones(widget.clienteId);
  }

  Future<dynamic> getZonas() async {
    // print("2.--------GET- ZONAS------");
    var res = await http.get(
      Uri.parse(apiUrl + apiZona),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Zona> tempZona = data.map<Zona>((mapa) {
          return Zona(
            id: mapa['id'],
            nombre: mapa['nombre'],
            poligono: mapa['poligono'],
            departamento: mapa['departamento'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            listZonas = tempZona;
          });
          for (var i = 0; i < listZonas.length; i++) {
            setState(() {
              tempString = listZonas[i].poligono.split(',');
            });
            //el string 'poligono', se separa en strings por las comas en la lista
            //temString
            for (var j = 0; j < tempString.length; j++) {
              //luego se recorre la lista y se hacen puntos con cada dos numeros
              if (j % 2 == 0) {
                //es multiplo de dos
                //SI ES PAR
                double x = double.parse(tempString[j]);
                double y = double.parse(tempString[j + 1]);
                //print('$x y $y');
                setState(() {
                  //print('entro al set Statw');
                  listZonas[i].puntos.add(Point(x, y));
                });
              }
            }
            //print('se llenaron los puntos de esta zona');
            //print(listZonas[i].puntos);
          }

          //AHORA DE ACUERDO A LA CANTIDAD DE PUTNOS QUE HAY EN LA LISTA DE PUNTOS SE CALCULA LA CANTIDAD
          //DE LINEAS CON LAS QUE S ETRABAJA
          for (var i = 0; i < listZonas.length; i++) {
            //print('entro al for que revisa zona por zona');
            var zonaID = listZonas[i].id;
            //print('esta en la ubicación = $i, con zona ID = $zonaID');
            setState(() {
              //print(
              //  'se crea la key zon ID, con un valor igual a un mapa vacio');
              mapaLineasZonas[zonaID] = {};
            });

            for (var j = 0; j < listZonas[i].puntos.length; j++) {
              //ingresa a un for en el que se obtienen los datos de todas la lineas que forman los puntos del polígono
              if (j == listZonas[i].puntos.length - 1) {
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[0];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };

                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              } else {
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[j + 1];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };

                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getUbicaciones(clienteID) async {
    //print("1.-------GET-UBICACIONES----");
    setState(() {
      listUbicacionesObjetos = [];
      ubicacionesString = [];
    });
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        //print("2) entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<UbicacionModel> tempUbicacion = data.map<UbicacionModel>((mapa) {
          return UbicacionModel(
              id: mapa['id'],
              latitud: mapa['latitud'].toDouble(),
              longitud: mapa['longitud'].toDouble(),
              direccion: mapa['direccion'],
              clienteID: mapa['cliente_id'],
              clienteNrID: null,
              distrito: mapa['distrito'],
              zonaID: mapa['zona_trabajo_id'] ?? 0);
        }).toList();
        if (mounted) {
          setState(() {
            // print(".... lista d ubicaciones");
            //print(tempUbicacion.first.distrito);
            listUbicacionesObjetos = tempUbicacion;
          });
          for (var i = 0; i < listUbicacionesObjetos.length; i++) {
            setState(() {
              ubicacionesString.add(listUbicacionesObjetos[i].direccion);
            });
          }
          UbicacionListaModel listUbis = UbicacionListaModel(
              listaUbisObjeto: listUbicacionesObjetos,
              listaUbisString: ubicacionesString);
          Provider.of<UbicacionListProvider>(context, listen: false)
              .updateUbicacionList(listUbis);
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
    /*print(".....................creando.................");
    print(distrito);
    print(latitudUser);
    print(longitudUser);
    print(direccionNueva);
    print(clienteId);
    print(distrito);
    print(zonaIDUbicacion);*/
    await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccionNueva,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
          "zona_trabajo_id": zonaIDUbicacion
        }));
  }

  Future puntoEnPoligono(double? xA, double? yA) async {
    if (xA is double && yA is double) {
      //print('1) son double, se recorre las zonas');
      for (var i = 0; i < listZonas.length; i++) {
        var zonaID = listZonas[i].id;
        //print('zonaID = $zonaID');
        mapaLineasZonas[zonaID].forEach((value, mapaLinea) {
          //print('Ingreso a recorrer las lineas de la zona $zonaID');
          if (xA <= mapaLinea["maxX"] &&
              mapaLinea['minY'] <= yA &&
              yA <= mapaLinea['maxY']) {
            //print('- Cumple todas estas');
            //print('- $xA <= ${mapaLinea["maxX"]}');
            //print('- ${mapaLinea['minY']} <= $yA');
            //print('- $yA<= ${mapaLinea['maxY']}');
            //print('');
            var xInterseccion =
                (yA - mapaLinea['constante']) / mapaLinea['pendiente'];
            /*print('Se calcula la xInterseccion');
            print(
                'xI = ($yA - ${mapaLinea['constante']})/${mapaLinea['pendiente']} = $xInterseccion');*/
            if (xA <= xInterseccion) {
              //EL PUNTO INTERSECTA A LA LINEA
              /*print('- el punto intersecta la linea hacia la deresha');
              print('- $xA <= $xInterseccion');
              print('');*/
              setState(() {
                mapaLinea['intersecciones'] = 1;
              });
            }
          }
        });
      }
      //SE CUENTA LA CANTIDAD DE INTERSECCIONES EN CADA ZONA
      for (var i = 0; i < listZonas.length; i++) {
        //se revisa para cada zona
        /* print('');
        print('');
        print('Ahora se cuenta la cantidad de intersecciones');*/
        var zonaID = listZonas[i].id;
        //print('Primero en la zona $zonaID');
        int intersecciones = 0;
        mapaLineasZonas[zonaID].forEach((key, mapaLinea) {
          if (mapaLinea['intersecciones'] == 1) {
            intersecciones += 1;
          }
        });
        if (intersecciones > 0) {
          // print('Nª intersecciones = $intersecciones en la Zona $zonaID');
          if (intersecciones % 2 == 0) {
            //  print('- Es una cantidad PAR, ESTA AFUERA');
            setState(() {
              zonaIDUbicacion = null;
            });
          } else {
            setState(() {
              // print('- Es una cantidad IMPAR, ESTA DENTRO');
              zonaIDUbicacion = zonaID;
              //print(zonaIDUbicacion);
            });
            //es impar ESTA AFUERA
            break;
          }
        } else {
          setState(() {
            zonaIDUbicacion = null;
          });
        }
      }
    }
  }

  UbicacionModel direccionSeleccionada(String direccion) {
    UbicacionModel ubicacionObjeto = UbicacionModel(
        id: 0,
        latitud: 0,
        longitud: 0,
        direccion: 'direccion',
        clienteID: 0,
        clienteNrID: 0,
        distrito: 'distrito',
        zonaID: 0);
    for (var i = 0; i < listUbicacionesObjetos.length; i++) {
      if (listUbicacionesObjetos[i].direccion == direccion) {
        setState(() {
          ubicacionObjeto = listUbicacionesObjetos[i];
        });
      }
    }
    return ubicacionObjeto;
  }

  @override
  void initState() {
    // print("1 .... init");
    super.initState();
    _marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: _currentPosition,
      draggable: true,
      onDragEnd: (newPosition) {
        _currentPosition = newPosition;
        //  print("UBICACION OBTENIDA DESDE ON DRAG END");
        //  print(_currentPosition);
        //obtenerDireccion(_currentPosition.latitude, _currentPosition.longitude);
      },
    );
    // print("UBICACION OBTENIDA DEL MARCADOR");
    //print(_currentPosition);
    getUbicaciones(widget.clienteId);
    getZonas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color.fromRGBO(33, 88, 254, 1),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO DE SOL
              Container(
                //padding: const EdgeInsets.all(9),
                //color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          image: const DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('lib/imagenes/nuevecito.png'))),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Indicanos tu ubicación de destino",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 22,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // TITULO

              Container(
                width: MediaQuery.of(context).size.width / 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.white),
                padding: const EdgeInsets.all(0.0),
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressController,
                  focusNode: _focusNode,
                  googleAPIKey: kGoogleApiKey,
                  inputDecoration: const InputDecoration(
                    //fillColor: Colors.white,
                    //isDense: true,

                    hintText: "Busca tu dirección",

                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  debounceTime: 400,
                  countries: ["pe"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    setState(() {
                      _currentPosition = LatLng(
                        double.parse(prediction.lat ?? '0'),
                        double.parse(prediction.lng ?? '0'),
                      );
                      _updateMapLocation();
                      // print("UBICACION OBTENIDA A TRAVES DE PREDICCION");
                      //print(_updateMapLocation);
                      // print(_currentPosition);
                    });
                  },
                  itemClick: (Prediction prediction) {
                    _addressController.text = prediction.description ?? "";
                    _addressController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description?.length ?? 0),
                    );
                  },
                  seperatedBuilder: Divider(),
                  containerHorizontalPadding: 10,
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 7),
                          Expanded(
                              child: Text(
                            "${prediction.description ?? ""}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                    );
                  },
                  isCrossBtnShown: true,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // MAPA
              Container(
                height: MediaQuery.of(context).size.height / 1.95,
                width: MediaQuery.of(context).size.width / 1,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1)),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14.0,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _marker != null ? {_marker!} : {},
                  onCameraMove: (position) {
                    _currentPosition = position.target;
                  },
                ),
              ),

              // ESPACIO FINAL
              const SizedBox(
                height: 15,
              ),

              // BOTON GUARDAR
              Container(
                decoration: const BoxDecoration(),
                width: MediaQuery.of(context).size.width / 1.1,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 72, 11, 255))),
                  //onPressed: _addLocation,
                  onPressed: () async {
                    try {
                      await _addLocation(); // Esperamos a que _addLocation() termine

                      if (!context.mounted)
                        return; // Verificamos si el contexto sigue válido

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Éxito"),
                            content: const Text(
                                "Los datos se han guardado de manera exitosa."),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cerramos el diálogo

                                  // Usamos Future.microtask para la navegación
                                  Future.microtask(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Pedido()),
                                    );
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      // Manejo de errores
                      //print("Error al guardar la ubicación: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("No se pudo guardar la ubicación")),
                        );
                      }
                    }
                  },

                  child: Text(
                    "Guardar Ubicación",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
