import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class Cobrar extends StatefulWidget {
  const Cobrar({super.key});

  @override
  State<Cobrar> createState() => _CobrarState();
}

class _CobrarState extends State<Cobrar> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  // File? _imageFile;
  //final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  String? tipoPago;
  final List<String> _tipoPagoItems = ['Yape', 'Plin', 'Otro'];
final ImagePicker _picker = ImagePicker();

  Future<String?> getImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        print('No se seleccionó ninguna imagen.');
        return null;
      }

      // Directorio donde se guardará la imagen en el almacenamiento externo
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        print('No se pudo obtener el directorio externo.');
        return null;
      }

      String fileName = 'IMG${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = path.join(externalDir.path, fileName);

      File imageFile = File(photo.path);
      await imageFile.copy(filePath);
      print('Imagen guardada en: $filePath');

      // Devuelve la ruta para que sea accesible en otras funciones
      return filePath;
    } catch (e) {
      print('Error al abrir la cámara: $e');
      return null;
    }
  }

  Future<dynamic> updateEstadoPedido(
      estadoNuevo, foto, observacion, tipoPago, pedidoID, beneficiado) async {
    try {
      //       print("update..........pedido");
      //print("$estadoNuevo$foto$observacion$tipoPago$pedidoID$beneficiado");
      if (pedidoID != 0) {
        await http.put(Uri.parse("$apiUrl$apiPedidosConductor$pedidoID"),
            headers: {"Content-type": "application/json"},
            body: jsonEncode({
              "estado": estadoNuevo,
              "foto": foto,
              "observacion": observacion == '' ? "NA" : observacion,
              "tipo_pago": tipoPago,
              "beneficiado_id": beneficiado,
            }));
      } else {
        //print('papas fritas');
      }
    } catch (error) {
      throw Exception("$error");
    }
  }

  /*Future<void> _takePicture(String pedidoID) async {
    final directory = await getApplicationDocumentsDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final picturesDirectory =
        Directory(path.join(directory.path, 'pictures', dateStr));

    if (!await picturesDirectory.exists()) {
      await picturesDirectory.create(recursive: true);
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final String fileName =
          '$pedidoID-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(picturesDirectory.path, fileName);
      final File newImage = await File(pickedFile.path).copy(filePath);

      if (mounted) {
        // Verifica si el widget está montado
        setState(() {
          _imageFile = newImage;
          _images.add(newImage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto guardada en $filePath')),
        );
      }
    } else {
      if (mounted) {
        // Verifica si el widget está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ninguna foto')),
        );
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final pedidosProvider =
        Provider.of<PedidoconductorProvider>(context, listen: false);
    final cardpedidoProvider =
        Provider.of<CardpedidoProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: MediaQuery.of(context).size.height / 18,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cobro",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 29,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/imagenes/olas.jpg"), // Ruta de la imagen
                fit: BoxFit.fill, // Ajusta la imagen al tamaño de la pantalla
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            //color: Color.fromARGB(255, 79, 87, 128),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Center(
                        child: Column(
                  children: [
                    Text(
                      "S/. ${cardpedidoProvider.pedido?.precio}",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width / 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Monto total",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: MediaQuery.of(context).size.width / 20),
                    )
                  ],
                ))),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    // VIRTUAL

                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 20,
                        child: ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Center(
                                          child: Text("Método de pago")),
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.5,
                                        child: Column(
                                          children: [
                                            const Text(
                                              "¿El cliente agrego productos al pedido?",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            const Text(
                                                "Escribe los productos."),
                                            TextField(
                                              controller: _controller,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Ej.3 bidones adicionales'),
                                            ),
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            const Text(
                                              "Precio del producto agregado",
                                              textAlign: TextAlign.left,
                                            ),
                                            TextField(
                                              controller: _controller2,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                  hintText: 'S/.0.00'),
                                            ),
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            const Text(
                                              "¿El cliente solo desea cancelar?",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900),
                                            ),
                                            const SizedBox(
                                              height: 14,
                                            ),
                                            StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setState) {
                                              return Container(
                                                //color: Colors.blue,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    12,
                                                child: Center(
                                                  child: DropdownButton(
                                                    hint: const Text(
                                                        'Tipo de pago'),
                                                    value: tipoPago,
                                                    items: _tipoPagoItems
                                                        .map((String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        tipoPago = newValue;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancelar")),
                                            TextButton(
                                              onPressed: () async {
                                                // Cierra el diálogo primero
                                                Navigator.pop(context);

                                                // Usa un retraso breve para asegurar que el contexto esté correctamente actualizado
                                                /*  await Future.delayed(
                                                    Duration(milliseconds: 300));*/

                                                // Realiza la lógica necesaria después de cerrar el diálogo
                                                await updateEstadoPedido(
                                                  "entregado",
                                                  null,
                                                  _controller.text +
                                                      _controller2.text,
                                                  tipoPago,
                                                  cardpedidoProvider.pedido?.id,
                                                  cardpedidoProvider
                                                      .pedido?.beneficiadoid,
                                                );
                                          pedidosProvider.getPedidosConductor();
                                                /*await _takePicture(
                                                    cardpedidoProvider.pedido!.id
                                                        .toString());*/
                                                
                                                String? imagePath =
                                                    await getImageFromCamera();
                                                if (imagePath != null) {
                                                  // Aquí puedes hacer algo con la ruta de la imagen
                                                  print(
                                                      'Imagen guardada en: $imagePath');
                                                  // Por ejemplo, podrías actualizar el pedido con la ruta de la imagen
                                                  // await updatePedidoConImagen(cardpedidoProvider.pedido?.id, imagePath);
                                                }

                                                // Navega a la pantalla Driver1 después de completar todas las operaciones
                                                // Navigator.pop(context,const Driver1());
                                                /*Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Driver1()),
                                                );*/
                                              },
                                              child: const Text("OK"),
                                            )
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                              Color.fromARGB(255, 66, 66, 209),
                            )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Pago virtual",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                )
                              ],
                            )),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // EFECTIVO
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 20,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Center(
                                        child: Text("Método de pago")),
                                    content: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      child: Column(
                                        children: [
                                          const Text(
                                            "¿El cliente agrego productos al pedido?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 18,
                                          ),
                                          const Text(
                                              "Escribe el o los productos que se agregaron al pedido"),
                                          TextField(
                                            controller: _controller,
                                            decoration: const InputDecoration(
                                                hintText:
                                                    'Ej.3 bidones adicionales'),
                                          ),
                                          const SizedBox(
                                            height: 18,
                                          ),
                                          const Text(
                                            "Precio del producto agregado",
                                            textAlign: TextAlign.left,
                                          ),
                                          TextField(
                                            controller: _controller2,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                hintText: 'S/.0.00'),
                                          ),
                                          const SizedBox(
                                            height: 28,
                                          ),
                                          const Text(
                                            "¿El cliente solo desea cancelar?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Cancelar")),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              /*showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return  AlertDialog(
                                                        title:
                                                           CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          strokeWidth: 4.0,
                                                        ),
                                                      );
                                                    });*/
                                              updateEstadoPedido(
                                                  "entregado",
                                                  null,
                                                  _controller.text +
                                                      _controller2.text,
                                                  "efectivo",
                                                  cardpedidoProvider.pedido?.id,
                                                  cardpedidoProvider
                                                      .pedido?.beneficiadoid);
                                              pedidosProvider
                                                  .getPedidosConductor();
                                              /*         Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Driver1()),
            (Route<dynamic> route) => false,
          );*/

                                              /* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder:
                                                          (BuildContext context) =>
                                                              Driver1()));*/
                                            },
                                            child: Text("OK"),
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Pago efectivo",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 20,
                                    color:
                                        const Color.fromARGB(255, 82, 82, 82)),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.currency_exchange_outlined,
                                color: Color.fromARGB(255, 82, 82, 82),
                              )
                            ],
                          ),
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Color.fromARGB(255, 221, 221, 132))),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
