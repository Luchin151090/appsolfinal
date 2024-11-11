import 'dart:convert';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Confirmarubi extends StatefulWidget {
  final String direccion; // Recibimos la dirección de la pantalla anterior

  const Confirmarubi({Key? key, required this.direccion}) : super(key: key);

  @override
  State<Confirmarubi> createState() => _ConfirmarubiState();
}

class _ConfirmarubiState extends State<Confirmarubi> {
  final TextEditingController _detalleDireccionController =
      TextEditingController();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  LatLng? _ubicacionSeleccionada;
  late GoogleMapController _mapController;
  String googleApiKey =
      "AIzaSyA45xOgppdm-PXYDE5r07eDlkFuPzYmI9g"; // Asegúrate de reemplazar esto con tu propia API Key de Google

  @override
  void initState() {
    super.initState();
    _obtenerCoordenadasDeDireccion(widget.direccion);
  }

  Future<dynamic> creadoUbicacion(context,
      clienteId, distrito, latitudUser, longitudUser, direccionNueva) async {
    /*print(".....................creando.................");
    print(distrito);
    print(latitudUser);
    print(longitudUser);
    print(direccionNueva);
    print(clienteId);
    print(distrito);
    print(zonaIDUbicacion);*/
    var res = await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccionNueva,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
          "zona_trabajo_id": null
        }));

    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      // Crear una nueva instancia de UbicacionModel a partir de la respuesta
      UbicacionModel nuevaUbicacion = UbicacionModel(
        id: data['id'],
        latitud: data['latitud'].toDouble(),
        longitud: data['longitud'].toDouble(),
        direccion: data['direccion'],
        clienteID: data['cliente_id'],
        clienteNrID: data['cliente_nr_id'],
        distrito: data['distrito'],
        zonaID: data['zona_trabajo_id'],
      );

      // Actualizar el Provider con la nueva ubicación
      Provider.of<UbicacionListProvider>(context, listen: false)
          .addUbicacion(nuevaUbicacion);
    }
  }

  // Función para obtener las coordenadas desde la dirección usando Google Geocoding API
  Future<void> _obtenerCoordenadasDeDireccion(String direccion) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(direccion)}&key=$googleApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("---------------------------");
        print(data);

        if (data['status'] == 'OK') {
          final geometry = data['results'][0]['geometry']['location'];
          final lat = geometry['lat'];
          final lng = geometry['lng'];

          setState(() {
            _ubicacionSeleccionada = LatLng(lat, lng);
          });
        } else {
          print('Error en la API de Geocoding: ${data['status']}');
        }
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener las coordenadas: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _actualizarUbicacion(LatLng nuevaUbicacion) {
    setState(() {
      _ubicacionSeleccionada = nuevaUbicacion;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ubicacionListaProvider =
        Provider.of<UbicacionListProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('¿Dónde quieres recibir el pedido?',style:TextStyle(fontSize:19.sp))),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.amber),
                SizedBox(width: MediaQuery.of(context).size.width * 0.035),
                Text(
                  "Ajusta tu ubicación exacta en el mapa",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _ubicacionSeleccionada != null
                ? Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _ubicacionSeleccionada!,
                        zoom: 19.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("ubicacion"),
                          position: _ubicacionSeleccionada!,
                          draggable: true,
                          onDragEnd: (LatLng position) {
                            _actualizarUbicacion(position);
                          },
                        ),
                      },
                      onTap: (LatLng nuevaUbicacion) {
                        _actualizarUbicacion(nuevaUbicacion);
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            /*TextField(
              decoration: const InputDecoration(
                labelText: 'Dpto./ Interior/ Piso/ Lote/ Bloque (opcional):',
                hintText: 'Ejem. Casa 3, Dpto 101.',
                border: OutlineInputBorder(),
              ),
              controller: _detalleDireccionController,
            ),*/
            Expanded(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05)),
            Container(
              width: MediaQuery.of(context).size.width / 1.05,
              child: ElevatedButton(
                onPressed: () async {
                  print(
                      "----------------*************************---------------");
                  print("Ubicación confirmada: $_ubicacionSeleccionada");
                  if (_ubicacionSeleccionada != null) {
                    print(
                        "----------------*************************---------------");
                    print("Ubicación confirmada: $_ubicacionSeleccionada");
                    print("---------DATOS");

                    // Dividir la cadena por comas
                    List<String> partes = widget.direccion.split(',');

                    // Acceder al distrito
                    String distrito = partes[1];
                    print(
                        "${userProvider.user?.id},${widget.direccion.split(',')[1]},${_ubicacionSeleccionada!.latitude},${_ubicacionSeleccionada!.longitude},${widget.direccion}");
                    await creadoUbicacion(
                      context,
                        userProvider.user?.id,
                        distrito,
                        _ubicacionSeleccionada!.latitude,
                        _ubicacionSeleccionada!.longitude,
                        widget.direccion);

                    // ubicacionListaProvider.ubicacion?.listaUbisString.add(widget.direccion);
                    //  ubicacionListaProvider.ubicacion?.listaUbisObjeto.add()

                    /*Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Pedido()),
                    );*/
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);

                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 47, 33, 243),
                ),
                child: Text(
                  'Confirmar y guardar',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ],
        ),
      ),
    );
  }
}
