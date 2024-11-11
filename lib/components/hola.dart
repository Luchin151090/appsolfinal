import 'dart:math';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/components/ubipersonal.dart';
import 'package:appsol_final/models/ubicaciones_lista_model.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:lottie/lottie.dart';
import 'package:appsol_final/models/zona_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductoHola {
  final String nombre;
  final double precio;
  final String descripcion;

  final String foto;

  ProductoHola(
      {required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.foto});
}

class Hola2 extends StatefulWidget {
  final String? url;
  final String? loggedInWith;
  final int? clienteId;
  final bool? esNuevo;
  //final double? latitud;
  // final double? longitud;

  const Hola2({
    this.url,
    this.loggedInWith,
    this.clienteId,
    this.esNuevo,
    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);

  @override
  State<Hola2> createState() => _HolaState();
}

class _HolaState extends State<Hola2> with TickerProviderStateMixin {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiZona = '/api/zona';
  List<ProductoHola> listProducto = [];
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  int? zonaIDUbicacion = 0;
  int? clienteID = 0;
  bool? yaSeMostro = false;
  bool? yaComproBidon = false;
  List<UbicacionModel> listUbicacionesObjetos = [];
  List<String> ubicacionesString = [];
  String? _ubicacionSelected;
  late String? dropdownValue;
  late String? distrito;
  int cantCarrito = 0;
  double ganacia = 3.00;
  Color colorCantidadCarrito = Colors.black;
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  late String direccionNueva;
  late UbicacionModel miUbicacion;
  late UbicacionModel miUbicacionNueva;
  List<Zona> listZonas = [];
  List<String> tempString = [];
  Map<int, dynamic> mapaLineasZonas = {};
  //ACA SE DEBE ACTUALIZAR LA IMAGEN PARA COMPARTIR EN LOS ESTADOS
  String direccionImagenParaEstados = 'lib/imagenes/12-so-dscto-AGUA-SOL.png';
  //ACA SE DEBE ACTUALIZAR EL LINK PARA DESCARGAR LA APPPPPP
  String urlPreview = 'https://youtu.be/EFe9YOZ3YOg?si=1YcKww6EIBJfKnqv';
  String urlExplicacion = 'https://youtu.be/EFe9YOZ3YOg?si=1YcKww6EIBJfKnqv';
  String tituloUbicacion = 'Gracias por compartir tu ubicación!';
  String contenidoUbicacion = '¡Disfruta de Sol Vida!';
  List<String> listPromociones = [];

  List<Producto> bidonProducto = [];

  //bool _disposed = false;
  //bool _autoScrollInProgress = false;

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  // Define un controlador global
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();
  Timer? _timer;
  DateTime fechaLimite = DateTime.now();

  final socketService = SocketService();

// VARIABLES PARA DEPÓSITO
  bool depositaron = false;
  String mensajeDeposito = 'Todavía no tienes notificaciones.';
  int notificacionesCount = 0;

  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      return DateTime.parse(fecha);
    } else {
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    _scrollController.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    ordenarFuncionesInit();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ESCUCHA EL EVENTO DEL DEPÓSITO
    /* socketService.listenToEvent('depósito',(data) async {
    if(!mounted) return;
    if(data['idcliente'] == userProvider.user?.id){
      depositaron = true;
      mensajeDeposito = 'Ya recibiste tu S/.${userProvider.user?.saldoBeneficio} \nverifica tu saldo, en tu aplicativo de ahorros';
    }
   });*/
  }

  Future<void> muestraDialogoPubli(BuildContext context) async {
    SharedPreferences yasemostroPubli = await SharedPreferences.getInstance();
    yasemostroPubli.setBool("ya", true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var codigo = userProvider.user?.codigocliente;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(
          //barrierColor: Colors.grey.withOpacity(0.41), // opacidad por detras
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                //width: MediaQuery.of(context).size.width * 0.56,
                //color: Colors.green,
                height: MediaQuery.of(context).size.height /
                    1.2, //altura del dialogo
                child: RotatedBox(
                  quarterTurns: -1,
                  child: ListWheelScrollView(
                    itemExtent: MediaQuery.of(context).size.height / 3,
                    controller: _scrollController,
                    children: [
                      RotatedBox(
                        quarterTurns: 1,
                        child: Container(
                          // height: 300,
                          // height: 100,
                          // ALTO DEL CONTENEDOR
                          //height: MediaQuery.of(context).size.height/2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Colors.amber
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                    decoration: BoxDecoration(
                                        // color: Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                            fit: BoxFit.fill,
                                            image: AssetImage(
                                                'lib/imagenes/codigoentra2.jpg'))),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.515,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Center(
                                          child: Text(
                                            "${codigo}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                                color: Colors.redAccent),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              //const Size
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      // Hacer scroll al siguiente elemento
                                      final currentPosition =
                                          _scrollController.offset;
                                      final itemExtent =
                                          MediaQuery.of(context).size.height /
                                              3;
                                      _scrollController.animateTo(
                                        currentPosition + itemExtent,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Icon(
                                      Icons.navigate_next,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                      color: Colors.blue,
                                    )).animate().shake(),
                              )
                            ],
                          ),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Container(
                          // height: 300,
                          // height: 100,
                          // ALTO DEL CONTENEDOR
                          //height: MediaQuery.of(context).size.height/2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Colors.amber
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 1.5,
                                decoration: BoxDecoration(
                                    // color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                    image: const DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'lib/imagenes/descuento1.jpg'))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  //padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      // color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        final pedidoProvider =
                                            Provider.of<PedidoProvider>(context,
                                                listen: false);
                                        /*print(
                                                      "BIDON PRODUCT------------");
                                                  print(bidonProducto[0].id);
                                                  print("cantidad");
                                                  print(
                                                      bidonProducto[0].cantidad);
                                                  print(bidonProducto[0].nombre);
                                                  print(bidonProducto[0].precio);
                                                  print(bidonProducto[0].promoID);
                                                  print(bidonProducto[0].cantidadRequeridaParaRuta);*/
                                        bidonProducto[0].cantidad = 1;

                                        PedidoModel newPedido = PedidoModel(
                                            seleccionados: bidonProducto,
                                            seleccionadosPromo: [],
                                            cantidadProd:
                                                bidonProducto[0].cantidad,
                                            totalProds:
                                                bidonProducto[0].precio *
                                                    bidonProducto[0].cantidad,
                                            envio: 0);

                                        // SE ENVIA EL PROVIDER ACTUAL
                                        pedidoProvider.updatePedido(newPedido);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Pedido()
                                              //const Promos()
                                              ),
                                        );
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Color.fromRGBO(
                                                      255, 0, 93, 1))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.025,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                          Text(
                                            "¡Comprar ahora!",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.023,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ))),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      // Hacer scroll al siguiente elemento
                                      final currentPosition =
                                          _scrollController.offset;
                                      final itemExtent =
                                          MediaQuery.of(context).size.height /
                                              3;
                                      _scrollController.animateTo(
                                        currentPosition + itemExtent,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Icon(
                                      Icons.navigate_next,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                      color: Colors.blue,
                                    )).animate().shake(),
                              )
                            ],
                          ),
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Container(
                          // height: 300,
                          // height: 100,
                          // ALTO DEL CONTENEDOR
                          //height: MediaQuery.of(context).size.height/2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Colors.amber
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 1.5,
                                decoration: BoxDecoration(
                                    // color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                    image: const DecorationImage(
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            'lib/imagenes/codigoamigo.jpg'))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  //padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      // color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        final pedidoProvider =
                                            Provider.of<PedidoProvider>(context,
                                                listen: false);
                                        /*print("BIDON PRODUCT------------");
                                                print(bidonProducto[0].id);
                                                print("cantidad");
                                                print(bidonProducto[0].cantidad);
                                                print(bidonProducto[0].nombre);
                                                print(bidonProducto[0].precio);
                                                print(bidonProducto[0].promoID);
                                                print(bidonProducto[0]
                                                    .cantidadRequeridaParaRuta);*/
                                        bidonProducto[0].cantidad = 1;

                                        PedidoModel newPedido = PedidoModel(
                                            seleccionados: bidonProducto,
                                            seleccionadosPromo: [],
                                            cantidadProd:
                                                bidonProducto[0].cantidad,
                                            totalProds:
                                                bidonProducto[0].precio *
                                                    bidonProducto[0].cantidad,
                                            envio: 0);

                                        // SE ENVIA EL PROVIDER ACTUAL
                                        pedidoProvider.updatePedido(newPedido);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Pedido()
                                              //const Promos()
                                              ),
                                        );
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Color.fromRGBO(
                                                      255, 0, 93, 1))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.white,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.025,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                          ),
                                          Text(
                                            "¡Sí, usar!",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.023,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ))),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      // Termina
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.waving_hand_outlined,
                                      size: MediaQuery.of(context).size.height *
                                          0.028,
                                      color: Colors.blue,
                                    )).animate().shake(),
                              )
                            ],
                          ),
                        ),
                      ),

                      /*Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Column(children: [
                          Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'lib/imagenes/codigoentra2.jpg')))),
                          Container(
                              height: 90,
                              decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'lib/imagenes/codigoentra2.jpg'))))
                        ]),
                      )*/
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }

  _cargarPreferencias() async {
    SharedPreferences yasemostroPubli = await SharedPreferences.getInstance();
    // BIDON COMPRADO ?
    SharedPreferences bidonCliente = await SharedPreferences.getInstance();
    //print("prefrencias-----------");
    setState(() {
      yaComproBidon = bidonCliente.getBool('comproBidon');
    });
    //print(yaComproBidon);
    if (yasemostroPubli.getBool("ya") != null) {
      setState(() {
        yaSeMostro = yasemostroPubli.getBool("ya");
      });
    } else {
      setState(() {
        yaSeMostro = false;
      });
    }
  }

  Future<dynamic> getBidonCliente(clienteID) async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + '/api/clientebidones/' + clienteID.toString()),
        headers: {"Content-type": "application/json"},
      );
      SharedPreferences bidonCliente = await SharedPreferences.getInstance();

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        //print("data si hay bidon o no");
        //print(data);
        bool compre = false;
        if (data == null) {
          //print("no hay data");
          //print("no compre");
          if (mounted) {
            setState(() {
              compre = false;
            });
          }
          return compre;
        } else {
          // print("compre");
          if (mounted) {
            setState(() {
              compre = true;
            });
          }
          return compre;
          //print("no hay dta");
        }
      }
    } catch (e) {
      throw Exception("Error ${e}");
    }
  }

  Future<void> ordenarFuncionesInit() async {
    await _cargarPreferencias();
    await getUbicaciones(widget.clienteId);
    await getProducts();
    await getZonas();
    await getPromociones();
    // TRAEMOS EL ID DEL USUARIO
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool compreBidon = await getBidonCliente(userProvider.user?.id);
    //print("numerito ${compreBidon}");

    //print("..widget nuevo");
    //print(widget.esNuevo);
    //print("...YASEMOSTRO");
    //print(yaSeMostro);
    //print("ya compro");
    //print(compreBidon);
    if (!mounted) return;
    if (widget.esNuevo == true && compreBidon == false) {
      //print(".....ENTRANDO Y LLAMANDO.........");
      //print("...todavia");

      await muestraDialogoPubli(context);
    } else if (widget.esNuevo == false && compreBidon == false) {
      //print("...todavia");

      await muestraDialogoPubli(context);
    } else if (widget.esNuevo == false && compreBidon == true) {
      //print("ya compre");
    }
    if (compreBidon == true) {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        userProvider.user?.esNuevo = false;
      });
      //print("-----PROVIDER USER");
      //print(userProvider.user?.esNuevo);
    }
  }

  Future<void> nuevaUbicacion() async {
    await creadoUbicacion(widget.clienteId, distrito);
    await getUbicaciones(widget.clienteId);
  }

  Future<dynamic> getZonas() async {
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

  Future<dynamic> getPromociones() async {
    var res = await http.get(
      Uri.parse('$apiUrl/api/promocion'),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<String> tempPromocion = data.map<String>((mapa) {
          return '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}';
        }).toList();

        if (mounted) {
          setState(() {
            listPromociones = tempPromocion;
          });
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
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

  Future<void> obtenerDireccion(x, y) async {
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
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

  Future<void> currentLocation() async {
    //print("¡¡Entro al CurrectLocation!!");
    var location = location_package.Location();
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });
    // Verificar si el servicio de ubicación está habilitado
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
    }

    // Obtener la ubicación
    try {
      locationData = await location.getLocation();

      //updateLocation(locationData);
      await obtenerDireccion(locationData.latitude, locationData.longitude);

      //print("ubicación - $locationData");
      //print("latitud - $latitudUser");
      //print("longitud - $longitudUser");

      // Aquí puedes utilizar la ubicación obtenida (locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      //print("Error al obtener la ubicación: $e");
    }
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
        /*print('');
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
          //print('Nª intersecciones = $intersecciones en la Zona $zonaID');
          if (intersecciones % 2 == 0) {
            //print('- Es una cantidad PAR, ESTA AFUERA');
            setState(() {
              zonaIDUbicacion = null;
            });
          } else {
            setState(() {
              //print('- Es una cantidad IMPAR, ESTA DENTRO');
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

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<ProductoHola> tempProducto = data.map<ProductoHola>((mapa) {
          return ProductoHola(
            nombre: 'hoalalalalalalala', //mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        List<Producto> tempProdProvider = data.map<Producto>((mapa) {
          return Producto(
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        // VERIFICAR SI EL WIDGET EXISTE Y LUEGO SETEAMOS EL VALOR
        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            bidonProducto = [tempProdProvider[0]];
            //conductores = tempConductor;
          });
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      cantCarrito = pedido.cantidadProd;
      if (pedido.cantidadProd > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      setState(() {
        cantCarrito = 0;
        colorCantidadCarrito = Colors.grey;
      });
    }
  }

  void direccionesVacias() {
    if (listUbicacionesObjetos.isEmpty) {
      setState(() {
        dropdownValue = "";
      });
    } else {
      setState(() {
        dropdownValue = listUbicacionesObjetos.first.direccion;
        miUbicacion = listUbicacionesObjetos.first;
      });
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
  // TEST UBICACIONES PARA DROPDOWN

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height / 1.08;
    final userProvider = context.watch<UserProvider>();
    String mensajeCodigoParaAmigos =
        'Hola!,\nTe presento la *app 💧 Sol Vida 💧* usa mi codigo para tu primera compra de un *BIDÓN DE AGUA DE 20L (bidon + agua)* y te lo podrás llevar *a solo S/.23.00 ~(Precio regular: S/.35.00)~*.\n¡Solo usando mi código!.\nAdemás puedes referir a tus contactos con tu codigo y _*beneficiarte con S/. 3.00 💸*_ por las compras que realicen. \n✅ USA MI CODIGO DE REFERENCIA: ${userProvider.user?.codigocliente}\n❓ Más detalles AQUÍ: $urlExplicacion \n⏬ Descarga la APP AQUÍ: $urlPreview';
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final pedidoProvider = context.watch<PedidoProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    direccionesVacias();
    esVacio(pedidoProvider.pedido);
    return Scaffold(
        backgroundColor: Colors.white,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: SafeArea(
              key: _scaffoldKey,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //CONTAINER DE UBICACION Y CARRITO
                          /*Container(
                            width: anchoActual,
                            color: Colors.grey,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //LOCATION
                                /*Container(
                                  //width: MediaQuery.of(context).size.width / 1.3,
                                  decoration: BoxDecoration(
                                    color:Colors.amber,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    children: [
                                      //BOTON DE AGREGAR UBI
                                     Container(
                                        width: anchoActual * 0.13,
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade200,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      0, 106, 252, 1.000),
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      top: largoActual * 0.041,
                                                      left: anchoActual * 0.055,
                                                      right: anchoActual * 0.055),
                                                  height: largoActual * 0.17,
                                                  width: anchoActual,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                left: 10),
                                                        child: Text(
                                                          'Agregar Ubicación',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                largoActual *
                                                                    0.023,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: largoActual *
                                                              0.013),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await currentLocation();
                    
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.pop(
                                                              // ignore: use_build_context_synchronously
                                                              context);
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.pop(
                                                              // ignore: use_build_context_synchronously
                                                              context);
                                                        },
                                                        style: ButtonStyle(
                                                          surfaceTintColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                          elevation:
                                                              MaterialStateProperty
                                                                  .all(8),
                                                          minimumSize:
                                                              MaterialStatePropertyAll(
                                                                  Size(
                                                                      anchoActual *
                                                                          0.28,
                                                                      largoActual *
                                                                          0.054)),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                        ),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .add_location_alt_rounded,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                                size:
                                                                    largoActual *
                                                                        0.034,
                                                              ),
                                                              Text(
                                                                ' Agregar ubicación actual',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.021,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        0,
                                                                        106,
                                                                        252,
                                                                        1.000)),
                                                              ),
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                              Icons.add_location_alt_outlined,
                                              size: largoActual * 0.031,
                                              color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        width: anchoActual * 0.005,
                                      ),
                                      //BOTON DE LISTA DE UBIS
                                      Container(
                                        width: anchoActual * 0.63,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              83, 176, 68, 1.000),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          //color: Colors.amberAccent,
                                          margin: const EdgeInsets.only(
                                              left: 12, right: 5),
                                          child: DropdownButton<String>(
                                            hint: Text(
                                              '¿A dónde llevamos tu pedido?',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: largoActual * 0.018,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: largoActual * 0.018,
                                                fontWeight: FontWeight.w500),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            elevation: 20,
                                            dropdownColor: const Color.fromRGBO(
                                                83, 176, 68, 1.000),
                                            isExpanded: true,
                                            value: _ubicacionSelected,
                                            items: ubicacionesString
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue is String) {
                                                if (direccionSeleccionada(
                                                            newValue)
                                                        .zonaID ==
                                                    0) {
                                                  setState(() {
                                                    tituloUbicacion =
                                                        'Lo sentimos :(';
                                                    contenidoUbicacion =
                                                        'Todavía no llegamos a tu zona, pero puedes revisar nuestros productos en la aplicación o elegir otra ubicación :D';
                                                  });
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        surfaceTintColor:
                                                            Colors.white,
                                                        title: Text(
                                                          tituloUbicacion,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  largoActual *
                                                                      0.026,
                                                              fontWeight:
                                                                  FontWeight.w400,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        content: Text(
                                                          contenidoUbicacion,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  largoActual *
                                                                      0.018,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Cierra el AlertDialog
                                                            },
                                                            child: Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      largoActual *
                                                                          0.02,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  setState(() {
                                                    _ubicacionSelected = newValue;
                                                    miUbicacion =
                                                        direccionSeleccionada(
                                                            newValue);
                                                  });
                                                  Provider.of<UbicacionProvider>(
                                                          context,
                                                          listen: false)
                                                      .updateUbicacion(
                                                          miUbicacion);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().shakeX(
                                      duration: Duration(milliseconds: 300),
                                    ),*/
                                //////////////// DESDE AQUÍ SE QUITO LA UBICACIÓN COMPLETAMENTE

                                /*  Container(
                                  //width: anchoActual * 0.13,
                                  height: largoActual * 0.059,
                                  width: largoActual * 0.059,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(0, 106, 252, 1.000),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        backgroundColor: const Color.fromRGBO(
                                            0, 106, 252, 1.000),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                                top: largoActual * 0.041,
                                                left: anchoActual * 0.055,
                                                right: anchoActual * 0.055),
                                            height: largoActual * 0.20,
                                            width: anchoActual,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10),
                                                  child: Text(
                                                    'Agregar ubicación de destino',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          largoActual * 0.023,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: largoActual * 0.013),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await currentLocation();
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                    
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext context) {
                                                        return Dialog(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                5,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration: const BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image: AssetImage(
                                                                              'lib/imagenes/nuevecito.png'))),
                                                                ),
                                                                const SizedBox(
                                                                  height: 19,
                                                                ),
                                                                Text(
                                                                  "Ubicación añadida! Revisala arriba.",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          25,
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          2,
                                                                          100,
                                                                          181)),
                                                                ),
                                                                const SizedBox(
                                                                  height: 19,
                                                                ),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "OK",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          fontSize:
                                                                              24,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              4,
                                                                              93,
                                                                              167)),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    surfaceTintColor:
                                                        MaterialStateProperty.all(
                                                            Colors.white),
                                                    elevation:
                                                        MaterialStateProperty.all(
                                                            8),
                                                    minimumSize:
                                                        MaterialStatePropertyAll(
                                                            Size(
                                                                anchoActual *
                                                                    0.28,
                                                                largoActual *
                                                                    0.054)),
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Colors.white),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_location_alt_rounded,
                                                          color: const Color
                                                              .fromRGBO(
                                                              0, 106, 252, 1.000),
                                                          size:
                                                              largoActual * 0.034,
                                                        ),
                                                        Text(
                                                          ' Agregar ubicación actual',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  largoActual *
                                                                      0.021,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000)),
                                                        ),
                                                      ]),
                                                ),
                                                SizedBox(
                                                    height: largoActual * 0.013),
                    
                                                    //////////// GOOGLE MAPS //////////
                                                ElevatedButton(
                                                  onPressed: () async {
                    
                                                      print("holi");
                                                       Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              MapScreen(clienteId: widget.clienteId)));
                                                  },
                                                  style: ButtonStyle(
                                                    surfaceTintColor:
                                                        MaterialStateProperty.all(
                                                            Colors.white),
                                                    elevation:
                                                        MaterialStateProperty.all(
                                                            8),
                                                    minimumSize:
                                                        MaterialStatePropertyAll(
                                                            Size(
                                                                anchoActual *
                                                                    0.28,
                                                                largoActual *
                                                                    0.054)),
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Colors.white),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_location_alt_rounded,
                                                          color: const Color
                                                              .fromRGBO(
                                                              0, 106, 252, 1.000),
                                                          size:
                                                              largoActual * 0.034,
                                                        ),
                                                        Text(
                                                          ' Agregar ubicación manualmente',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  largoActual *
                                                                      0.021,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000)),
                                                        ),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.add_location_alt_outlined,
                                        size: largoActual * 0.031,
                                        color: Colors.white),
                                  ),
                                ),*/
                                // UBICACION
                                /*Container(
                                  width: anchoActual * 0.63,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(58, 182, 0, 1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    //color: Colors.amberAccent,
                                    margin:
                                        const EdgeInsets.only(left: 12, right: 5),
                                    child: DropdownButton<String>(
                                      hint: Text(
                                        '¿A dónde llevamos tu pedido?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: largoActual * 0.018,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: largoActual * 0.018,
                                          fontWeight: FontWeight.w500),
                                      borderRadius: BorderRadius.circular(20),
                                      elevation: 20,
                                      dropdownColor:
                                          const Color.fromRGBO(58, 182, 0, 1),
                                      isExpanded: true,
                                      value: _ubicacionSelected,
                                      icon:const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors
                                            .white, // Cambia aquí el color de la flecha
                                      ),
                                      items:
                                          ubicacionesString.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue is String) {
                                          if (direccionSeleccionada(newValue)
                                                  .zonaID ==
                                              0) {
                                            setState(() {
                                              tituloUbicacion = 'Lo sentimos :(';
                                              contenidoUbicacion =
                                                  'Todavía no llegamos a tu zona, pero puedes revisar nuestros productos en la aplicación o elegir otra ubicación :D';
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  surfaceTintColor: Colors.white,
                                                  title: Text(
                                                    tituloUbicacion,
                                                    style: TextStyle(
                                                        fontSize:
                                                            largoActual * 0.026,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black),
                                                  ),
                                                  content: Text(
                                                    contenidoUbicacion,
                                                    style: TextStyle(
                                                        fontSize:
                                                            largoActual * 0.018,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Cierra el AlertDialog
                                                      },
                                                      child: Text(
                                                        'OK',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize:
                                                                largoActual *
                                                                    0.02,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              _ubicacionSelected = newValue;
                                              miUbicacion =
                                                  direccionSeleccionada(newValue);
                                            });
                                            Provider.of<UbicacionProvider>(
                                                    context,
                                                    listen: false)
                                                .updateUbicacion(miUbicacion);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),*/
                                Column(
                                  children: [
                                    Container(
                                      width: 60.w,
                                      height: 60.h,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'lib/imagenes/nuevecito.png'))),
                                    ),
                                    Container(
                                      //  color: Colors.amber,
                                      //margin: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(children: [
                                                Container(
                                                  height: largoActual * 0.079,
                                                  //color: Colors.green.shade100,
                                                  child: IconButton(
                                                    icon: Lottie.asset(
                                                        "lib/imagenes/infos.json"),
                                                    onPressed: () async {
                                                      //  print("inffff");
                                                      await muestraDialogoPubli(
                                                          context);
                                                    },
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    const SizedBox(height: 70),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 18),
                                                      //color: Colors.pink,
                                                      // height: 50,
                                                      child: Text("+ Info",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  largoActual *
                                                                      0.016,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: const Color
                                                                  .fromRGBO(
                                                                  0,
                                                                  148,
                                                                  217,
                                                                  1))),
                                                    ),
                                                  ],
                                                ),
                                              ])
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 29.w,
                                ),

                                // Bienvenida
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bienvenid@, ${userProvider.user?.nombre?.capitalize()}\na la familia Sol",
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: anchoActual * 0.035,
                                          color: Colors.black),
                                    ),
                                    /*Text(
                                      "a la familia Sol",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: anchoActual * 0.035,
                                          color: Colors.black),
                                    ),*/
                                  ],
                                ),
                                SizedBox(
                                  width: 89.w,
                                ),
                                //CARRITO
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      // alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              0, 106, 252, 1.000),
                                          borderRadius:
                                              BorderRadius.circular(50.r)),
                                      height: 45.h,
                                      width: 45.w,
                                      child: Badge(
                                        largeSize: 18,
                                        backgroundColor: colorCantidadCarrito,
                                        label: Text(cantCarrito.toString(),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Pedido()
                                                  //const Promos()
                                                  ),
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.shopping_cart_rounded),
                                          color: Colors.white,
                                          iconSize: largoActual * 0.030,
                                        ), /*.animate().shakeY(
                                              duration: Duration(milliseconds: 300),
                                            ),*/
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                    ////////////////////
                                    Container(
                                      // alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              0, 106, 252, 1.000),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      height: 45.h,
                                      width: 45.w,
                                      child: Badge(
                                        largeSize: 18,
                                        backgroundColor: colorCantidadCarrito,
                                        label: Text(cantCarrito.toString(),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.notifications),
                                          color: Colors.white,
                                          iconSize: largoActual * 0.030,
                                        ), /*.animate().shakeY(
                                              duration: Duration(milliseconds: 300),
                                            ),*/
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),*/

                          Container(
                            width: anchoActual,
                            // color: Colors.grey,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 55.w,
                                        height: 55.h,
                                        decoration: const BoxDecoration(
                                            // color: Colors.white,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'lib/imagenes/nuevecito.png'))),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        "Bienvenid@, ${userProvider.user?.nombre}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        "a la gran familia Sol",
                                        style: GoogleFonts.poppins(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 55.w,
                                        height: 55.h,
                                        //color: Colors.green.shade100,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(50.r)),
                                        child: IconButton(
                                          icon: Lottie.asset(
                                              "lib/imagenes/infos.json"),
                                          onPressed: () async {
                                            //  print("inffff");
                                            await muestraDialogoPubli(context);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Container(
                                        width: 100.w,
                                        // color:Colors.amber,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              // alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(
                                                      0, 106, 252, 1.000),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r)),
                                              height: 40.h,
                                              width: 40.w,
                                              child: Badge(
                                                largeSize: 18.sp,
                                                backgroundColor:
                                                    colorCantidadCarrito,
                                                label: Text(
                                                    cantCarrito.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                child: IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Pedido()
                                                            //const Promos()
                                                            ),
                                                      );
                                                    },
                                                    icon: const Icon(Icons
                                                        .shopping_cart_rounded),
                                                    color: Colors.white,
                                                    iconSize: 20
                                                        .sp), /*.animate().shakeY(
                                              duration: Duration(milliseconds: 300),
                                            ),*/
                                              ),
                                            ),

                                            // FLUTTER NOTIFICACIONES
                                            Container(
                                              // alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(
                                                      0, 106, 252, 1.000),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.r)),
                                              height: 40.h,
                                              width: 40.w,
                                              child: Badge(
                                                largeSize: 18.sp,
                                                backgroundColor: Colors.grey,
                                                label: Text(
                                                    notificacionesCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                child: IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            content:
                                                                !depositaron
                                                                    ? Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.info_outline_rounded,
                                                                            size:
                                                                                50.sp,
                                                                            color:
                                                                                Colors.blue,
                                                                          ),
                                                                          SizedBox(
                                                                              height: MediaQuery.of(context).size.height * 0.029),
                                                                          Text(
                                                                            "${mensajeDeposito}",
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontSize: MediaQuery.of(context).size.width * 0.035,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.attach_money_rounded,
                                                                            size:
                                                                                50,
                                                                            color:
                                                                                Colors.blue,
                                                                          ),
                                                                          SizedBox(
                                                                              height: MediaQuery.of(context).size.height * 0.029),
                                                                          Text(
                                                                            "${mensajeDeposito}",
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontSize: MediaQuery.of(context).size.width * 0.035,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ],
                                                                      ));
                                                      },
                                                    );
                                                  },
                                                  icon: const Icon(
                                                      Icons.notifications),
                                                  color: Colors.white,
                                                  iconSize: 20.sp,
                                                ), /*.animate().shakeY(
                                              duration: Duration(milliseconds: 300),
                                            ),*/
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                          ),

                          //BIENVENIDA DEL CLIENTE
                          /* Container(
                            //color: Colors.amber,
                            margin:const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      
                                      Stack(
                                        children: [
                                              Container(
                                                height: largoActual * 0.079,
                                                //color: Colors.green.shade100,
                                                child: IconButton(
                                                  icon: Lottie.asset(
                                                  "lib/imagenes/infos.json"),
                                                  onPressed: () async {
                                                  //  print("inffff");
                                                    await muestraDialogoPubli(context);
                                                  },
                                                ),
                                              ),
                                              
                                              Column(
                                                children: [
                                                  const SizedBox(height:70),
                                                  Container(
                                                    margin: EdgeInsets.only(left:18),
                                                    //color: Colors.pink,
                                                   // height: 50,
                                                    child: Text("+ Info",
                                                                                            style: TextStyle(
                                                    fontSize: largoActual * 0.016,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color.fromRGBO(0, 148, 217, 1))
                                                                                              ),
                                                  ),
                                                ],
                                              ),
                                        ]
                                      )
                                    ],
                                  ),
                                
                              ],
                            ),
                          ),*/
                          SizedBox(height: 20.h,),
                          Container(
                            height:
                                50, // Altura para el contenedor de las categorías
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return ActionChip(
                                      label: Text("Hogar y accesorios"),
                                      onPressed: () {
                                        // Acción cuando se presiona el chip
                                      },
                                      backgroundColor: const Color.fromRGBO(
                                          0, 106, 252, 1.000),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30
                                            .r), // Ajusta el radio a tu preferencia
                                      ),
                                    );
                                  } else if (index == 1) {
                                    return ActionChip(
                                      label: Text("Bienestar y salud"),
                                      onPressed: () {
                                        // Acción cuando se presiona el chip
                                      },
                                      backgroundColor: const Color.fromRGBO(
                                          0, 106, 252, 1.000),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30
                                            .r), // Ajusta el radio a tu preferencia
                                      ),
                                    );
                                  } else {
                                    return ActionChip(
                                      label: Text("Pronto"),
                                      onPressed: () {
                                        // Acción cuando se presiona el chip
                                      },
                                      backgroundColor: Color.fromARGB(255, 93, 95, 99),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30
                                            .r), // Ajusta el radio a tu preferencia
                                      ),
                                    );
                                  }
                                }),
                          ),

                          SizedBox(
                            height: 80.h,
                          ),
                          //TAB BAR PRODUCTOS/PROMOCIONES
                          SizedBox(
                            height: largoActual * 0.046,
                            width: anchoActual,
                            child: TabBar(
                                indicatorSize: TabBarIndicatorSize.label,
                                controller: _tabController,
                                indicatorWeight: 10,
                                /*indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color.fromRGBO(120, 251, 99, 0.5),
                                ),*/
                                labelStyle: TextStyle(
                                    fontSize: largoActual * 0.019,
                                    fontWeight: FontWeight
                                        .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                                unselectedLabelStyle: TextStyle(
                                    fontSize: largoActual * 0.019,
                                    fontWeight: FontWeight.w300),
                                labelColor: Colors.black, //colorTextos,
                                unselectedLabelColor:
                                    Colors.black, //colorTextos,
                                indicatorColor:
                                    const Color.fromRGBO(58, 182, 0, 1),
                                tabs: const [
                                  Tab(
                                    text: "Promociones",
                                  ),
                                  Tab(
                                    text: "Productos",
                                  ),
                                ]),
                          ),

                          //IMAGENES DE PRODUCTOS Y PROMOCIONES TAB BAR
                          Container(
                            margin: EdgeInsets.only(
                              top: largoActual * 0.013,
                            ),
                            height: largoActual / 2.5,
                            width: double.maxFinite,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                ListView.builder(
                                    controller: scrollController1,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listPromociones.length,
                                    itemBuilder: (context, index) {
                                      String promo = listPromociones[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BarraNavegacion(
                                                      indice: 0,
                                                      subIndice: 1,
                                                    )),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: anchoActual * 0.028),
                                          height: anchoActual * 0.83,
                                          width: anchoActual * 0.83,
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image: CachedNetworkImageProvider(
                                                    promo), //NetworkImage(promo),
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      );
                                    }),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BarraNavegacion(
                                                indice: 0,
                                                subIndice: 2,
                                              )
                                          //const Productos()
                                          ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: anchoActual * 0.028),
                                    height: anchoActual * 0.83,
                                    width: anchoActual * 0.83,
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 206, 206, 206),
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                "$apiUrl/images/bodegon.jpg"),
                                            fit: BoxFit.cover)),
                                  ),
                                )
                                /*
                                ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    controller: scrollController2,
                                    itemCount: listProducto.length,
                                    itemBuilder: (context, index) {
                                      Producto producto = listProducto[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BarraNavegacion(
                                                      indice: 0,
                                                      subIndice: 2,
                                                    )
                                                //const Productos()
                                                ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: anchoActual * 0.028),
                                          height: anchoActual * 0.83,
                                          width: anchoActual * 0.83,
                                          decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 130, 219, 133),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(producto.foto),
                                                fit: BoxFit.fitHeight,
                                              )),
                                        ),
                                      );
                                    }),*/
                              ],
                            ),
                          ),
                          //Expanded(child: Container()),
                          SizedBox(
                            height: largoActual * 0.025,
                          ),
                          //BILLETERA SOL
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(anchoActual * 0.03),
                            child: Text(
                              'Mi billetera sol',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: largoActual * 0.005,
                          ),

                          // NUEVA CARD DE SALDO
                          Container(
                            height: 150.h,
                            width: MediaQuery.of(context).size.width,
                            //color: Colors.grey,
                            child: Card(
                              color: const Color.fromRGBO(0, 106, 252, 1.000),
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Saldo beneficiario",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'S/. ${userProvider.user?.saldoBeneficio}0',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 35.sp),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Más información",
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      fontSize: 16.sp),
                                                ),
                                                SizedBox(
                                                  width: 16.w,
                                                ),
                                                Container(
                                                  width: 38.w,
                                                  height: 38.h,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.r)),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            /*barrierColor:
                                                                                              Colors.black.withOpacity(0.8),*/
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.r)),
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                surfaceTintColor:
                                                                    Colors
                                                                        .transparent,
                                                                child: Stack(
                                                                    clipBehavior:
                                                                        Clip
                                                                            .none,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      //CONTAINER CON INFO DE LA PROMOOO
                                                                      Container(
                                                                        height: largoActual *
                                                                            0.65,
                                                                        width: anchoActual *
                                                                            0.8,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(15),
                                                                            gradient: const LinearGradient(colors: [
                                                                              Color.fromRGBO(0, 106, 252, 1.000),
                                                                              Color.fromRGBO(0, 106, 252, 1.000),
                                                                              Color.fromRGBO(0, 106, 252, 1.000),
                                                                              Color.fromRGBO(150, 198, 230, 1),
                                                                              Colors.white,
                                                                              Colors.white,
                                                                            ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.all(anchoActual * 0.06),
                                                                          child:
                                                                              Column(
                                                                            //mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              //ESPACIO PARA QUE EL TEXTO NO SE TAPE CON LAS IMAGENES
                                                                              SizedBox(
                                                                                height: largoActual * 0.15,
                                                                              ),
                                                                              //TEXTO QUIERES GANAR MONI
                                                                              Text(
                                                                                '¿Quieres ganar dinero',
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: largoActual * 0.027, fontWeight: FontWeight.w800),
                                                                              ),
                                                                              Text(
                                                                                'sin salir de tu hogar?',
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: largoActual * 0.027, fontWeight: FontWeight.w800),
                                                                              ),
                                                                              Text(
                                                                                '¡Con Sol Vida puedes',
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: largoActual * 0.025, fontWeight: FontWeight.w400),
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    'logralo!',
                                                                                    textAlign: TextAlign.left,
                                                                                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white, fontSize: largoActual * 0.025, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                  Column(
                                                                                    children: [
                                                                                      SizedBox(
                                                                                        height: largoActual * 0.005,
                                                                                      ),
                                                                                      InkWell(
                                                                                        child: Row(
                                                                                          children: [
                                                                                            RichText(
                                                                                              text: TextSpan(
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: '          video',
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w800,
                                                                                                      fontStyle: FontStyle.normal,
                                                                                                      color: colorLetra,
                                                                                                      fontSize: largoActual * 0.014,
                                                                                                      height: 0.3, // Esto controla la altura de la línea para "video"
                                                                                                    ),
                                                                                                  ),
                                                                                                  TextSpan(
                                                                                                    text: '\nexplicativo ',
                                                                                                    style: TextStyle(
                                                                                                      fontWeight: FontWeight.w800,
                                                                                                      fontStyle: FontStyle.normal,
                                                                                                      color: colorLetra,
                                                                                                      fontSize: largoActual * 0.014,
                                                                                                      height: 1.13, // Esto controla la altura de la línea para "explicativo"
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: anchoActual * 0.0075),
                                                                                            Container(
                                                                                              child: Image.asset('lib/imagenes/icons8-youtube-48.png'),
                                                                                              height: anchoActual * 0.08,
                                                                                              width: anchoActual * 0.08,
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(6),
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        onTap: () async {
                                                                                          final Uri url = Uri.parse(urlExplicacion);
                                                                                          if (!await launchUrl(url)) {
                                                                                            throw Exception('Could not launch $url');
                                                                                          }
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),

                                                                              /*Text('salir de tu hogar?',
                                                              textAlign:
                                                                  TextAlign.left,
                                                              style: TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                  fontSize:
                                                                      largoActual *
                                                                          0.028,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),),*/
                                                                              //TEXTO CON AGUA SOL PUEDES LOGRARLO
                                                                              SizedBox(
                                                                                height: largoActual * 0.025,
                                                                              ),

                                                                              //TEXTO EXPLICATIVO
                                                                              RichText(
                                                                                  text: TextSpan(style: TextStyle(fontStyle: FontStyle.normal, color: colorLetra, fontSize: largoActual * 0.021, fontWeight: FontWeight.w400), children: [
                                                                                const TextSpan(text: 'Puedes '),
                                                                                TextSpan(text: 'GANAR S/. ${ganacia}0 ', style: const TextStyle(fontWeight: FontWeight.w800)),
                                                                                const TextSpan(text: 'por cada '),
                                                                                const TextSpan(text: 'Bidon Nuevo ', style: TextStyle(fontWeight: FontWeight.w800)),
                                                                                const TextSpan(text: 'que '),
                                                                                const TextSpan(text: 'compren ', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
                                                                                const TextSpan(text: 'tus contactos con tu código: '),
                                                                                TextSpan(text: '${userProvider.user?.codigocliente}.', style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
                                                                              ])),
                                                                              SizedBox(
                                                                                height: largoActual * 0.004,
                                                                              ),
                                                                              RichText(
                                                                                  text: TextSpan(style: TextStyle(fontStyle: FontStyle.normal, color: colorLetra, fontSize: largoActual * 0.017, fontWeight: FontWeight.w400), children: const [
                                                                                TextSpan(
                                                                                  text: 'Recuerda que tu código tiene una válidez de ',
                                                                                ),
                                                                                TextSpan(text: '3 meses ', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
                                                                                TextSpan(text: 'desde que creaste tu cuenta.'),
                                                                              ])),

                                                                              //ESPACIOOO
                                                                              SizedBox(height: largoActual * 0.029),

                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                                                                    height: largoActual * 0.04,
                                                                                    child: ElevatedButton(
                                                                                        style: const ButtonStyle(
                                                                                            elevation: MaterialStatePropertyAll(10),
                                                                                            surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                                            backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 55, 87, 218)),
                                                                                            shape: MaterialStatePropertyAll(
                                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                            ),
                                                                                            side: MaterialStatePropertyAll(BorderSide.none)),
                                                                                        onPressed: () async {
                                                                                          await Share.share(mensajeCodigoParaAmigos + urlPreview);
                                                                                        },
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Icon(Icons.share, size: largoActual * 0.02, color: Colors.white),
                                                                                            SizedBox(width: anchoActual * 0.02),
                                                                                            Text(
                                                                                              'COMPARTE TU CÓDIGO',
                                                                                              style: TextStyle(
                                                                                                  fontStyle: FontStyle.normal,
                                                                                                  color: Colors.white, //colorTextos,
                                                                                                  fontSize: largoActual * 0.015,
                                                                                                  fontWeight: FontWeight.w500),
                                                                                            ),
                                                                                          ],
                                                                                        )),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: largoActual * 0.011,
                                                                                  ),
                                                                                  //BOTON PARA PUBLICARLO EN TU ESTADO
                                                                                  Container(
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                                                                    height: largoActual * 0.04,
                                                                                    child: ElevatedButton(
                                                                                      style: const ButtonStyle(
                                                                                          elevation: MaterialStatePropertyAll(10),
                                                                                          surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                                          backgroundColor: MaterialStatePropertyAll(Colors.white),
                                                                                          shape: MaterialStatePropertyAll(
                                                                                            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                          ),
                                                                                          side: MaterialStatePropertyAll(BorderSide.none)),
                                                                                      onPressed: () async {
                                                                                        var codigo = userProvider.user?.codigocliente;
                                                                                        final image = await rootBundle.load(direccionImagenParaEstados);
                                                                                        final buffer = image.buffer;
                                                                                        final temp = await getTemporaryDirectory();
                                                                                        final path = '${temp.path}/image.jpg';

                                                                                        await Share.shareXFiles(
                                                                                          [
                                                                                            XFile.fromData(
                                                                                              buffer.asUint8List(
                                                                                                image.offsetInBytes,
                                                                                                image.lengthInBytes,
                                                                                              ),
                                                                                              mimeType: 'jpg',
                                                                                              name: 'usaMiCodigo',
                                                                                            )
                                                                                          ],
                                                                                          subject: '💵💵 Usa mi codigo: $codigo',
                                                                                        );
                                                                                      },
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.share,
                                                                                            size: largoActual * 0.02,
                                                                                            color: colorTextos,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: anchoActual * 0.02,
                                                                                          ),
                                                                                          Text(
                                                                                            'PUBLÍCALO EN TU ESTADO',
                                                                                            style: TextStyle(fontStyle: FontStyle.normal, color: colorTextos, fontSize: largoActual * 0.015, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              //BOTON COMPARTE
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //ANIMACION PALMERAS
                                                                      Positioned(
                                                                        top: -largoActual *
                                                                            0.08,
                                                                        left: anchoActual *
                                                                            0.035,
                                                                        height: largoActual *
                                                                            0.23,
                                                                        child: Lottie.asset(
                                                                            'lib/imagenes/palmeras1.json'),
                                                                      ),

                                                                      //ANIMACION PLAYERA
                                                                      Positioned(
                                                                        top: -largoActual *
                                                                            0.08,
                                                                        left: anchoActual *
                                                                            0.035,
                                                                        height: largoActual *
                                                                            0.23,
                                                                        child: Lottie.asset(
                                                                            'lib/imagenes/playa1.json'),
                                                                      ),
                                                                      //ANIMACION PALMERAS
                                                                      Positioned(
                                                                        top: -largoActual *
                                                                            0.08,
                                                                        left: anchoActual *
                                                                            0.18,
                                                                        height: largoActual *
                                                                            0.23,
                                                                        child: Lottie.asset(
                                                                            'lib/imagenes/palmeras1.json'),
                                                                      ),

                                                                      //IMAGEN DE BIDONCITO BONITO
                                                                      Positioned(
                                                                        top: -largoActual *
                                                                            0.15,
                                                                        right: -anchoActual *
                                                                            0.08,
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              largoActual * 0.30,
                                                                          width:
                                                                              anchoActual * 0.5,
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          decoration: const BoxDecoration(
                                                                              color: Colors.transparent,
                                                                              image: DecorationImage(image: AssetImage('lib/imagenes/BIDON20.png'), fit: BoxFit.scaleDown)),
                                                                        ),
                                                                      ),
                                                                      //BOTON DE CERRADO
                                                                      Positioned(
                                                                        top: -largoActual *
                                                                            0.13,
                                                                        right: -anchoActual *
                                                                            0.018,
                                                                        child: Container(
                                                                            alignment: Alignment.center,
                                                                            decoration: BoxDecoration(color: const Color.fromARGB(11, 191, 191, 191), borderRadius: BorderRadius.circular(50)),
                                                                            height: largoActual * 0.05,
                                                                            width: largoActual * 0.05,
                                                                            child: IconButton(
                                                                              onPressed: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => const Pedido()
                                                                                      //const Promos()
                                                                                      ),
                                                                                );
                                                                              },
                                                                              icon: const Icon(Icons.close_rounded),
                                                                              color: Colors.white,
                                                                              iconSize: largoActual * 0.030,
                                                                            )),
                                                                      ),
                                                                    ]),
                                                              );
                                                            });
                                                      },
                                                      icon: Icon(
                                                          Icons
                                                              .info_outline_rounded,
                                                          size: 20.sp,
                                                          color: Colors.blue)),
                                                )
                                              ],
                                            ),

                                            /*Text(
                                            'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.016),
                                          ),*/
                                          ]),
                                      Container(
                                          width: largoActual * 0.1,
                                          height: largoActual * 0.13,
                                          decoration: const BoxDecoration(
                                              //color: Colors.amber,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'lib/imagenes/manita.png')))),
                                    ]),
                              ),
                            ),
                          ),
/*
                          Container(
                            height: largoActual * 0.14,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                surfaceTintColor: Colors.white,
                                color: const Color.fromRGBO(0, 106, 252, 1.000),
                                elevation: 10,
                                child: OutlinedButton(
                                  style: const ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                      ),
                                      side: MaterialStatePropertyAll(
                                          BorderSide.none)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        /*barrierColor:
                                            Colors.black.withOpacity(0.8),*/
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            backgroundColor: Colors.transparent,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.center,
                                                children: [
                                                  //CONTAINER CON INFO DE LA PROMOOO
                                                  Container(
                                                    height: largoActual * 0.65,
                                                    width: anchoActual * 0.8,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        gradient:
                                                            const LinearGradient(
                                                                colors: [
                                                              Color.fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000),
                                                              Color.fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000),
                                                              Color.fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000),
                                                              Color.fromRGBO(
                                                                  150,
                                                                  198,
                                                                  230,
                                                                  1),
                                                              Colors.white,
                                                              Colors.white,
                                                            ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomCenter)),
                                                    child: Container(
                                                      margin: EdgeInsets.all(
                                                          anchoActual * 0.06),
                                                      child: Column(
                                                        //mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //ESPACIO PARA QUE EL TEXTO NO SE TAPE CON LAS IMAGENES
                                                          SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.15,
                                                          ),
                                                          //TEXTO QUIERES GANAR MONI
                                                          Text(
                                                            '¿Quieres ganar dinero',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                                fontSize:
                                                                    largoActual *
                                                                        0.027,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                          Text(
                                                            'sin salir de tu hogar?',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                                fontSize:
                                                                    largoActual *
                                                                        0.027,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                          Text(
                                                            '¡Con Sol Vida puedes',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    largoActual *
                                                                        0.025,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'logralo!',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.025,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height:
                                                                        largoActual *
                                                                            0.005,
                                                                  ),
                                                                  InkWell(
                                                                    child: Row(
                                                                      children: [
                                                                        RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: '          video',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w800,
                                                                                  fontStyle: FontStyle.normal,
                                                                                  color: colorLetra,
                                                                                  fontSize: largoActual * 0.014,
                                                                                  height: 0.3, // Esto controla la altura de la línea para "video"
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '\nexplicativo ',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w800,
                                                                                  fontStyle: FontStyle.normal,
                                                                                  color: colorLetra,
                                                                                  fontSize: largoActual * 0.014,
                                                                                  height: 1.13, // Esto controla la altura de la línea para "explicativo"
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                anchoActual * 0.0075),
                                                                        Container(
                                                                          child:
                                                                              Image.asset('lib/imagenes/icons8-youtube-48.png'),
                                                                          height:
                                                                              anchoActual * 0.08,
                                                                          width:
                                                                              anchoActual * 0.08,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6),
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    onTap:
                                                                        () async {
                                                                      final Uri
                                                                          url =
                                                                          Uri.parse(
                                                                              urlExplicacion);
                                                                      if (!await launchUrl(
                                                                          url)) {
                                                                        throw Exception(
                                                                            'Could not launch $url');
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),

                                                          /*Text('salir de tu hogar?',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255),
                                                                fontSize:
                                                                    largoActual *
                                                                        0.028,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),),*/
                                                          //TEXTO CON AGUA SOL PUEDES LOGRARLO
                                                          SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.025,
                                                          ),

                                                          //TEXTO EXPLICATIVO
                                                          RichText(
                                                              text: TextSpan(
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      color:
                                                                          colorLetra,
                                                                      fontSize:
                                                                          largoActual *
                                                                              0.021,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        'Puedes '),
                                                                TextSpan(
                                                                    text:
                                                                        'GANAR S/. ${ganacia}0 ',
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w800)),
                                                                const TextSpan(
                                                                    text:
                                                                        'por cada '),
                                                                const TextSpan(
                                                                    text:
                                                                        'Bidon Nuevo ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w800)),
                                                                const TextSpan(
                                                                    text:
                                                                        'que '),
                                                                const TextSpan(
                                                                    text:
                                                                        'compren ',
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        fontWeight:
                                                                            FontWeight.w800)),
                                                                const TextSpan(
                                                                    text:
                                                                        'tus contactos con tu código: '),
                                                                TextSpan(
                                                                    text:
                                                                        '${userProvider.user?.codigocliente}.',
                                                                    style: const TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        fontWeight:
                                                                            FontWeight.w800)),
                                                              ])),
                                                          SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.004,
                                                          ),
                                                          RichText(
                                                              text: TextSpan(
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                      color:
                                                                          colorLetra,
                                                                      fontSize:
                                                                          largoActual *
                                                                              0.017,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                  children: const [
                                                                TextSpan(
                                                                  text:
                                                                      'Recuerda que tu código tiene una válidez de ',
                                                                ),
                                                                TextSpan(
                                                                    text:
                                                                        '3 meses ',
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        fontWeight:
                                                                            FontWeight.w800)),
                                                                TextSpan(
                                                                    text:
                                                                        'desde que creaste tu cuenta.'),
                                                              ])),

                                                          //ESPACIOOO
                                                          SizedBox(
                                                              height:
                                                                  largoActual *
                                                                      0.029),

                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                height:
                                                                    largoActual *
                                                                        0.04,
                                                                child: ElevatedButton(
                                                                    style: const ButtonStyle(
                                                                        elevation: MaterialStatePropertyAll(10),
                                                                        surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                        backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 55, 87, 218)),
                                                                        shape: MaterialStatePropertyAll(
                                                                          RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                        ),
                                                                        side: MaterialStatePropertyAll(BorderSide.none)),
                                                                    onPressed: () async {
                                                                      await Share.share(
                                                                          mensajeCodigoParaAmigos +
                                                                              urlPreview);
                                                                    },
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .share,
                                                                            size: largoActual *
                                                                                0.02,
                                                                            color:
                                                                                Colors.white),
                                                                        SizedBox(
                                                                            width:
                                                                                anchoActual * 0.02),
                                                                        Text(
                                                                          'COMPARTE TU CÓDIGO',
                                                                          style: TextStyle(
                                                                              fontStyle: FontStyle.normal,
                                                                              color: Colors.white, //colorTextos,
                                                                              fontSize: largoActual * 0.015,
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    largoActual *
                                                                        0.011,
                                                              ),
                                                              //BOTON PARA PUBLICARLO EN TU ESTADO
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                height:
                                                                    largoActual *
                                                                        0.04,
                                                                child:
                                                                    ElevatedButton(
                                                                  style: const ButtonStyle(
                                                                      elevation: MaterialStatePropertyAll(10),
                                                                      surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                                                                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                                                                      shape: MaterialStatePropertyAll(
                                                                        RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20))),
                                                                      ),
                                                                      side: MaterialStatePropertyAll(BorderSide.none)),
                                                                  onPressed:
                                                                      () async {
                                                                    var codigo =
                                                                        userProvider
                                                                            .user
                                                                            ?.codigocliente;
                                                                    final image =
                                                                        await rootBundle
                                                                            .load(direccionImagenParaEstados);
                                                                    final buffer =
                                                                        image
                                                                            .buffer;
                                                                    final temp =
                                                                        await getTemporaryDirectory();
                                                                    final path =
                                                                        '${temp.path}/image.jpg';

                                                                    await Share
                                                                        .shareXFiles(
                                                                      [
                                                                        XFile
                                                                            .fromData(
                                                                          buffer
                                                                              .asUint8List(
                                                                            image.offsetInBytes,
                                                                            image.lengthInBytes,
                                                                          ),
                                                                          mimeType:
                                                                              'jpg',
                                                                          name:
                                                                              'usaMiCodigo',
                                                                        )
                                                                      ],
                                                                      subject:
                                                                          '💵💵 Usa mi codigo: $codigo',
                                                                    );
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .share,
                                                                        size: largoActual *
                                                                            0.02,
                                                                        color:
                                                                            colorTextos,
                                                                      ),
                                                                      SizedBox(
                                                                        width: anchoActual *
                                                                            0.02,
                                                                      ),
                                                                      Text(
                                                                        'PUBLÍCALO EN TU ESTADO',
                                                                        style: TextStyle(
                                                                            fontStyle: FontStyle
                                                                                .normal,
                                                                            color:
                                                                                colorTextos,
                                                                            fontSize: largoActual *
                                                                                0.015,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          //BOTON COMPARTE
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  //ANIMACION PALMERAS
                                                  Positioned(
                                                    top: -largoActual * 0.08,
                                                    left: anchoActual * 0.035,
                                                    height: largoActual * 0.23,
                                                    child: Lottie.asset(
                                                        'lib/imagenes/palmeras1.json'),
                                                  ),

                                                  //ANIMACION PLAYERA
                                                  Positioned(
                                                    top: -largoActual * 0.08,
                                                    left: anchoActual * 0.035,
                                                    height: largoActual * 0.23,
                                                    child: Lottie.asset(
                                                        'lib/imagenes/playa1.json'),
                                                  ),
                                                  //ANIMACION PALMERAS
                                                  Positioned(
                                                    top: -largoActual * 0.08,
                                                    left: anchoActual * 0.18,
                                                    height: largoActual * 0.23,
                                                    child: Lottie.asset(
                                                        'lib/imagenes/palmeras1.json'),
                                                  ),

                                                  //IMAGEN DE BIDONCITO BONITO
                                                  Positioned(
                                                    top: -largoActual * 0.15,
                                                    right: -anchoActual * 0.08,
                                                    child: Container(
                                                      height:
                                                          largoActual * 0.30,
                                                      width: anchoActual * 0.5,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      decoration: const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'lib/imagenes/BIDON20.png'),
                                                              fit: BoxFit
                                                                  .scaleDown)),
                                                    ),
                                                  ),
                                                  //BOTON DE CERRADO
                                                  Positioned(
                                                    top: -largoActual * 0.13,
                                                    right: -anchoActual * 0.018,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: const Color
                                                                .fromARGB(11,
                                                                191, 191, 191),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                        height:
                                                            largoActual * 0.05,
                                                        width:
                                                            largoActual * 0.05,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const Pedido()
                                                                  //const Promos()
                                                                  ),
                                                            );
                                                          },
                                                          icon: const Icon(Icons
                                                              .close_rounded),
                                                          color: Colors.white,
                                                          iconSize:
                                                              largoActual *
                                                                  0.030,
                                                        )),
                                                  ),
                                                ]),
                                          );
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Saldo Beneficiario",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: largoActual * 0.021),
                                          ),
                                          Text(
                                            'S/. ${userProvider.user?.saldoBeneficio}0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: largoActual * 0.045),
                                          ),
                                          Text(
                                            'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.016),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: largoActual * 0.04,
                                      ),
                                      Container(
                                          width: largoActual * 0.1,
                                          height: largoActual * 0.13,
                                          decoration: const BoxDecoration(
                                              //color: Colors.amber,
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'lib/imagenes/manita.png')))),
                                    ],
                                  ),
                                )),
                          ),*/
                        ]),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(anchoActual * 0.03),
                      child: Text(
                        'Eventos Especiales',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2.4,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            if (index == 1) {
                              return Card(
                                  elevation: 7,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.height / 3,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 106, 252, 1.000),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "Muy pronto \nmás novedades",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.07,
                                          fontWeight: FontWeight.w600),
                                    )),
                                  )
                                  //SizedBox(height: 15),
                                  );
                            } else {
                              return Card(
                                elevation: 7,
                                color: Color.fromRGBO(0, 106, 252, 1.000),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            image: DecorationImage(
                                                image: CachedNetworkImageProvider(
                                                    '$apiUrl/images/sorteoviaje.png'))),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Más información",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.045,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045,
                                        ),
                                        Container(
                                          height: 38.h,
                                          width: 38.w,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50.r)),
                                          child: IconButton(
                                              onPressed: () {
                                                // Mostrar el diálogo cuando se presiona el botón
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .info_outline_rounded,
                                                            size: 50,
                                                            color: Colors.blue,
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.029),
                                                          Text(
                                                            "Para participar\n del sorteo, realiza\n recargas de bidón.\n A más recargas\n más posibilidades\n de ganar.",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.info_outline,
                                                color: Colors.blue,
                                                size: 20.sp,
                                              )),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                //SizedBox(height: 15),
                              );
                            }
                          },
                        )),
                  ]))),
        ));
  }
}
