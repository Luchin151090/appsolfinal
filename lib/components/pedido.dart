import 'package:appsol_final/components/newdriver1.dart';
import 'package:appsol_final/components/newubicacioncli.dart';
import 'package:appsol_final/components/prefinal.dart';
//import 'package:appsol_final/components/pruebaubicacion.dart';
import 'package:appsol_final/components/ubipersonal.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/promocion_model.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:appsol_final/models/ubicaciones_lista_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/components/fin.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsol_final/provider/user_provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Pedido extends StatefulWidget {
  const Pedido({Key? key}) : super(key: key);
  @override
  State<Pedido> createState() => _PedidoState();
}

class _PedidoState extends State<Pedido> {
  late PedidoModel pedidoMio;
  bool light0 = false;
  int numero = 0;
  double envio = 0.0;
  //EL AHORRO ES IGUAL A 4 SOLES POR CADA BIDON NUEVO
  double ahorro = 0.0;
  double totalProvider = 0.0;
  double tamanoTitulos = 0.0;
  double tamanoTitulosDialogs = 0.0;
  double tamanoContenidoDialogs = 0.0;
  List<dynamic> seleccionadosTodos = [];
  List<Producto> seleccionadosProvider = [];
  List<Promo> selecciondosPromosProvider = [];
  String tipoPedido = "normal";
  TextEditingController notas = TextEditingController();
  TextEditingController _cupon = TextEditingController();
  String notasParaConductor = '';
  int lastPedido = 0;
  Color color = Colors.white;
  Color colorTitulos = const Color.fromARGB(255, 1, 42, 76);
  Color colorContenido = const Color.fromARGB(255, 1, 75, 135);
  Color colorCupon = Colors.white;
  Color colorDireccion = const Color.fromRGBO(234, 51, 98, 1.000);
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  //POR AHORA EL CLIENTE ES MANUAL!!""
  String direccion = 'Av. Las Flores 137 - Cayma';
  String mensajeCodigoExpirado = "";
  DateTime tiempoActual = DateTime.now();
  late DateTime tiempoPeru;
  int ubicacionSelectID = 0;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String codigoverify = '/api/code_cliente';
  String apiPedido = '/api/pedido';
  String apiDetallePedido = '/api/detallepedido';
  int? beneficiadoID;
  String? codigoBeneficio;
  bool existe = false;
  bool buscandoCodigo = false;
  bool hayBidon = false;
  bool hayUbicacion = false;
  bool esPrimeraCompra = false;
  double dctoPrimeraCompra = 0.2;
  int cantidadBidones = 0;
  String? fechaLimiteString = '';
  DateTime fechaLimite = DateTime.now();
  DateTime fechaLimiteCliente = DateTime.now();
  bool almenosuno = false;
  String? _ubicacionSelected;
  List<String> ubicacionesString = [];
  List<UbicacionModel> listUbicacionesObjetos = [];
  String tituloUbicacion = 'Gracias por compartir tu ubicación!';
  String contenidoUbicacion = '¡Disfruta de Agua Sol!';
  late UbicacionModel miUbicacion;
  String? _selectedValue;
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];


Future<void> eliminarUbicacion(int id) async {
  final response = await http.delete(
    Uri.parse('$apiUrl/api/ubicacion/$id'),
    headers: {"Content-type": "application/json"},
  );

  if (response.statusCode == 200) {
    print('Ubicación eliminada correctamente.');
  } else {
    print('Error al eliminar la ubicación: ${response.statusCode}');
  }
}



  bool isLoading = false;

void _showModalBottomSheet(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.21,
                  height: MediaQuery.of(context).size.height / 16,
                  margin: EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormUbi()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 24, 75, 184),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_location_alt_outlined,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Agrega una ubicación",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: const Divider(
                    color: Color.fromARGB(255, 0, 0, 0),
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                Text(
                  "Lista de ubicaciones",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 25),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : listUbicacionesObjetos.isNotEmpty
                          ? ListView(
                              children: listUbicacionesObjetos.map((UbicacionModel ubicacion) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(255, 87, 106, 212),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      ubicacion.direccion,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      onPressed: () async {
                                        // Mostrar el loader
                                        setModalState(() {
                                          isLoading = true;
                                        });

                                        // Eliminar la dirección de la base de datos
                                        await eliminarUbicacion(ubicacion.id);

                                        // Eliminar la ubicación localmente
                                        setState(() {
                                          listUbicacionesObjetos.remove(ubicacion);
                                        });

                                        // Ocultar el loader
                                        setModalState(() {
                                          isLoading = false;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedValue = ubicacion.direccion;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              }).toList(),
                            )
                          : Center(
                              child: Text(
                                'No tienes ubicaciones añadidas',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                ),
                SizedBox(height: 25),
              ],
            ),
          );
        },
      );
    },
  );
}


  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      //print('es string');
      return DateTime.parse(fecha);
    } else {
      //print('no es string');
      return DateTime.now();
    }
  }

  Future<dynamic> datosCreadoPedido(
      clienteId,
      fecha,
      subtotal,
      descuento,
      montoTotal,
      cantidadBidon,
      tipo,
      estado,
      notas,
      codigo,
      ubicacionID) async {
    //print("-----------------------creandoPEDIDOO");
    await http.post(Uri.parse(apiUrl + apiPedido),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "subtotal": subtotal.toDouble(),
          "descuento": descuento.toDouble(),
          "total": montoTotal.toDouble(),
          "fecha": fecha,
          "tipo": tipo,
          "estado": estado,
          "ubicacion_id": ubicacionID,
          "observacion": notas,
          "beneficiado_id": beneficiadoID
        }));
  }

  Future<dynamic> detallePedido(
      clienteId, productoId, cantidad, promoID) async {
    await http.post(Uri.parse(apiUrl + apiDetallePedido),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "producto_id": productoId,
          "cantidad": cantidad,
          "promocion_id": promoID
        }));
  }

  Future<void> crearPedidoyDetallePedido(clienteID, tipo, subtotal, monto,
      descuento, notas, codigo, cantidadBidon) async {
    try {
      DateTime tiempoGMTPeru = tiempoActual.subtract(const Duration(hours: 0));
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
      print("ESTOY DENTRO DE AQUI CREACION DE PEDIDO---------------->");
      print(clienteID);
      print(subtotal);
      //print(ubicacionSelectID);

      /* final ubicacionProvider =
          Provider.of<UbicacionProvider>(context, listen: false);
      String  direccionsellecionada = "Los alamos";

      final ubicacionSelectID = ubicacionProvider.ubicacion?.id ?? 0;*/

      UbicacionModel direccionseleccionada =
          direccionSeleccionada(_selectedValue!);

      print("Ubicacion Select ID: $ubicacionSelectID");
      await datosCreadoPedido(
          clienteID,
          tiempoGMTPeru.toString(),
          subtotal,
          descuento,
          monto,
          cantidadBidon,
          tipo,
          "pendiente",
          notas,
          codigo,
          direccionseleccionada.id);
      /*print(tiempoGMTPeru.toString());
    print(tiempoActual.timeZoneName);
    print("-----------------------------------");
    print("creando detalles de pedidos----------");
    print("-----------------------------------");
    print("longitud de seleccinados--------${seleccionadosTodos.length}");*/
      for (var i = 0; i < seleccionadosTodos.length; i++) {
        if (seleccionadosTodos[i] is Promo) {
          for (Producto producto in seleccionadosTodos[i].listaProductos) {
            await detallePedido(
                clienteID,
                producto.id,
                (seleccionadosTodos[i].cantidad * producto.cantidad),
                producto.promoID);
          }
          //es producto
        } else {
          //es producto
          await detallePedido(clienteID, seleccionadosTodos[i].id,
              seleccionadosTodos[i].cantidad, seleccionadosTodos[i].promoID);
        }
      }
    } catch (e) {
      print('Error al crear el pedido: $e');
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      //print('ES PEDIDOOO');
      setState(() {
        totalProvider = pedido.totalProds;
        seleccionadosProvider = pedido.seleccionados;
        selecciondosPromosProvider = pedido.seleccionadosPromo;
        envio = pedido.envio;
        cantCarrito =
            seleccionadosProvider.length + selecciondosPromosProvider.length;
        if (seleccionadosProvider.isNotEmpty ||
            selecciondosPromosProvider.isNotEmpty) {
          almenosuno = true;
        }
        //se consulta si hay bidones en el pedido
        for (var i = 0; i < seleccionadosProvider.length; i++) {
          //si hay un bidon nuevo en los productos de la lista, solo productos
          //no promociones

          // CUIDADO CON EL ID :1 ES PARA BIDON Y 2 ES PARA RECARGA ...
          if (seleccionadosProvider[i].id == 1) {
            setState(() {
              hayBidon = true;
              cantidadBidones = seleccionadosProvider[i].cantidad;
            });
          }
        }

        setState(() {
          seleccionadosTodos.addAll(seleccionadosProvider);
          seleccionadosTodos.addAll(selecciondosPromosProvider);
        });

        if (pedido.cantidadProd > 0) {
          setState(() {
            colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
          });
        } else {
          setState(() {
            colorCantidadCarrito = Colors.grey;
          });
        }
      });
    } else {
      //print('no es pedido');
      almenosuno = false;
      limpiarVariables();
    }
  }

  void esUbicacion(
      UbicacionModel? ubicacion, UbicacionListaModel? ubicacionList) {
    if (ubicacion is UbicacionModel) {
      //print('ES UBIIIII');
      print("POSIBLE ERROR CON LA UBICACION----->");
      print(ubicacion);
      print(ubicacion.id);
      setState(() {
        hayUbicacion = true;
        miUbicacion = ubicacion;
        ubicacionSelectID = ubicacion.id;
        direccion = ubicacion.direccion;
        colorDireccion = const Color.fromARGB(255, 1, 75, 135);
      });
    } else {
      if (ubicacionList is UbicacionListaModel) {
        // print('no es ubi');
        setState(() {
          direccion = "Seleccione una dirección, por favor";
          ubicacionesString = ubicacionList.listaUbisString;
          listUbicacionesObjetos = ubicacionList.listaUbisObjeto;
        });
      }
    }
  }

  Future<dynamic> cuponExist(cupon) async {
    //print('----------------------entro a cupon Exists');
    var res = await http.post(Uri.parse(apiUrl + codigoverify),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"codigo": cupon}));
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          beneficiadoID = data['id'];
          existe = data['existe'];
          fechaLimiteString = data['fecha_creacion_cuenta'];
          /*print('CORRIO EL COSO');
          print("++++++++++++++ ESTE ES EL EXISTE $existe");*/
        });
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  void codigoPersonalVigente(String fecha) {
    fechaLimiteCliente = mesyAnio(fecha).add(const Duration(days: (30 * 3)));
    if (fechaLimiteCliente.day >= DateTime.now().day &&
        fechaLimiteCliente.month >= DateTime.now().month &&
        fechaLimiteCliente.year >= DateTime.now().year) {
      setState(() {
        mensajeCodigoExpirado =
            'Pero puedes compartir tu codigo con tus amigos para recibir beneficios ;D';
      });
    } else {
      setState(() {
        mensajeCodigoExpirado =
            'Pero puedes compartir la aplicacion con tus amigos, para recibir descuentos con sus codigos ;D';
      });
    }
  }

  void limpiarVariables() {
    setState(() {
      totalProvider = 0;
      seleccionadosProvider = [];
      selecciondosPromosProvider = [];
      seleccionadosTodos = [];
      cantCarrito = 0;
      hayBidon = false;
      cantidadBidones = 0;
      almenosuno = false;
      colorCantidadCarrito = Colors.grey;
      ahorro = 0;
      envio = 0;
    });
  }

  //FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      //almenosUno = true;
      seleccionadosTodos[index].cantidad++;
      obtenerTotal();

      actualizarProviderPedido();
      //print("nUEVO TOTAL PROVIDER ${totalProvider}0");
    });

    /*print("esta es la listA PROMOCIONES");
    print(seleccionadosTodos[index].cantidad);
    print("esta es la PROMOCIONES CONTABILIZADAS");*/
  }

  void disminuir(int index) {
    if (seleccionadosTodos[index].cantidad > 1) {
      setState(() {
        seleccionadosTodos[index].cantidad--;
        obtenerTotal();

        actualizarProviderPedido();
        //print("nUEVO TOTAL PROVIDER ${totalProvider}0");
      });
    }
    //almenosUno =
    //  listPromociones.where((promo) => promo.cantidad > 0).isNotEmpty;
    //print(seleccionadosTodos[index].cantidad);
  }

  void descuentoPrimeraCompra(bool? esnuevo) {
    if (existe && hayBidon) {
      setState(() {
        ahorro = 12.0 * cantidadBidones;
      });
    } else if (esnuevo == true && hayBidon) {
      setState(() {
        dctoPrimeraCompra = 10;
        ahorro = dctoPrimeraCompra * cantidadBidones;
      });
    }
  }

  void actualizarProviderPedido() {
    pedidoMio = PedidoModel(
      seleccionados: seleccionadosProvider,
      seleccionadosPromo: selecciondosPromosProvider,
      cantidadProd: cantCarrito,
      totalProds: totalProvider,
      envio: envio,
    );

    Provider.of<PedidoProvider>(context, listen: false).updatePedido(pedidoMio);
  }

  void obtenerTotal() {
    setState(() {
      totalProvider = 0;
    });
    for (var objeto in seleccionadosTodos) {
      setState(() {
        totalProvider += objeto.cantidad * objeto.precio;
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

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ubicacionProvider = Provider.of<UbicacionProvider>(context);
    final ubicacionListaProvider = Provider.of<UbicacionListProvider>(context);
    fechaLimiteCliente = mesyAnio(userProvider.user?.fechaCreacionCuenta);
    esUbicacion(ubicacionProvider.ubicacion, ubicacionListaProvider.ubicacion);
    print("EN LA VISTA---->>");
    print(ubicacionProvider.ubicacion);
    print(ubicacionListaProvider.ubicacion);
    tamanoTitulos = largoActual * 0.02;
    tamanoTitulosDialogs = largoActual * 0.021;
    tamanoContenidoDialogs = largoActual * 0.018;
    obtenerTotal();
    setState(() {
      seleccionadosTodos = [];
    });
    esVacio(pedidoProvider.pedido);
    descuentoPrimeraCompra(userProvider.user?.esNuevo);
    /*print("SELECCIONADOS TODOS");
    print(seleccionadosTodos);*/
    if (almenosuno) {
      return Scaffold(
        //backgroundColor: Color.fromARGB(255, 169, 168, 168),
        bottomSheet: BottomSheet(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            shadowColor: Colors.black,
            elevation: 10,
            enableDrag: false,
            onClosing: () {},
            builder: (context) {
              return SizedBox(
                height: largoActual * 0.16,
                child: Container(
                  margin: EdgeInsets.only(
                      top: largoActual * 0.02,
                      bottom: largoActual * 0.013,
                      left: anchoActual * 0.069,
                      right: anchoActual * 0.069),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 77, 255, 1),
                                fontWeight: FontWeight.w800,
                                fontSize: largoActual * (17 / 736)),
                          ),
                          Text(
                            'S/.${totalProvider - ahorro + envio}0',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 77, 255, 1),
                                fontWeight: FontWeight.w800,
                                fontSize: largoActual * (17 / 736)),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: largoActual * (8 / 736)),
                        child: SizedBox(
                          width: anchoActual * (400 / 360),
                          child: ElevatedButton(
                            onPressed: totalProvider > 0.0 &&
                                    _selectedValue != null
                                ? () async {
                                    showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Container(
                                              //  color:Colors.amber,
                                              padding: const EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  5.5,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    //color: Colors.amber,
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'lib/imagenes/nuevecito.png'))),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        "¿Estas de acuerdo con tu compra?",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                30,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                2, 101, 182),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            "Cancelar",
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    27,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .purple),
                                                          )),
                                                      TextButton(
                                                          onPressed: () async {
                                                            //final ubicacionProvider = Provider.of<UbicacionProvider>(context, listen: false);
                                                            //ubicacionProvider.updateUbicacionFromJson(ubicacionSelectID);
                                                            await crearPedidoyDetallePedido(
                                                                userProvider
                                                                    .user?.id,
                                                                tipoPedido,
                                                                totalProvider,
                                                                (totalProvider -
                                                                    ahorro +
                                                                    envio),
                                                                ahorro,
                                                                notas.text,
                                                                _cupon.text,
                                                                cantidadBidones);
                                                            limpiarVariables();
                                                            actualizarProviderPedido();
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const Prefinal()),
                                                            );
                                                          },
                                                          child: Text(
                                                            "Si",
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    27,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .blue),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                /*
                                    await crearPedidoyDetallePedido(
                                        userProvider.user?.id,
                                        tipoPedido,
                                        totalProvider,
                                        (totalProvider - ahorro + envio),
                                        ahorro,
                                        notas.text,
                                        _cupon.text,
                                        cantidadBidones);
                                    limpiarVariables();
                                    actualizarProviderPedido();
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Fin()),
                                    );
                                  }*/
                                : null,
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(8),
                              surfaceTintColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 255, 255, 255)),
                              minimumSize: MaterialStatePropertyAll(Size(
                                  anchoActual * (350 / 360),
                                  largoActual * (38 / 736))),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(0, 77, 255, 1)),
                            ),
                            child: const Text(
                              'Confirmar Pedido',
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 25, //largoActual * (14 / 736),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        /* appBar: PreferredSize(
        preferredSize: Size.fromHeight(largoActual * 0.08),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: () {
              actualizarProviderPedido();
              Navigator.of(context).pop();
              Provider.of<UbicacionProvider>(context, listen: false)
                  .updateUbicacion(miUbicacion);
            },
          ),
          
          actions: [
            Container(
              margin: EdgeInsets.only(
                  top: largoActual * 0.018, right: anchoActual * 0.045),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(50)),
              height: largoActual * 0.059,
              width: largoActual * 0.059,
              child: Badge(
                largeSize: 18,
                backgroundColor: colorCantidadCarrito,
                label: Text(cantCarrito.toString(),
                    style: const TextStyle(fontSize: 12)),
                child: IconButton(
                  onPressed: () {
                    limpiarVariables();
                    actualizarProviderPedido();
                  },
                  icon: const Icon(Icons.delete_rounded),
                  color: const Color.fromRGBO(0, 106, 252, 1.000),
                  iconSize: largoActual * 0.035,
                ).animate().shakeY(
                      duration: Duration(milliseconds: 300),
                    ),
              ),
            ),
          ],
        ),
      ),*/
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/imagenes/aguamarina2.png', // Asegúrate de tener la imagen en la carpeta assets y agregarla en pubspec.yaml
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.only(top: 70, right: 5, left: 5, bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: anchoActual * 0.055),
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                            //color: Colors.grey,
                            image: DecorationImage(
                                image: AssetImage('lib/imagenes/nuevito.png'))),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: largoActual * 0.018,
                            right: anchoActual * 0.045),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        height: largoActual * 0.059,
                        width: largoActual * 0.059,
                        child: Badge(
                          largeSize: 18,
                          backgroundColor: colorCantidadCarrito,
                          label: Text(cantCarrito.toString(),
                              style: const TextStyle(fontSize: 12)),
                          child: IconButton(
                            onPressed: () {
                              limpiarVariables();
                              actualizarProviderPedido();
                              /*
              Provider.of<UbicacionProvider>(context, listen: false)
                  .updateUbicacion(miUbicacion);*/
                            },
                            icon: const Icon(Icons.delete_rounded),
                            color: const Color.fromRGBO(0, 106, 252, 1.000),
                            iconSize: largoActual * 0.035,
                          ).animate().shakeY(
                                duration: Duration(milliseconds: 300),
                              ),
                        ),
                      ),
                    ],
                  ),
                  //TU PEDIDO
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.055),
                    child: const Text(
                      "Tu orden está casi lista!",
                      style: TextStyle(
                          color: Colors.white, // colorTitulos,
                          fontWeight: FontWeight.bold,
                          fontSize: 30 //tamanoTitulos
                          ),
                    ),
                  ),
                  SizedBox(
                    height: largoActual * 0.24,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.only(
                          top: largoActual * 0.0068,
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.028,
                          right: anchoActual * 0.028),
                      child: Container(
                        margin: EdgeInsets.all(anchoActual * 0.01),
                        child: ListView.builder(
                            itemCount: seleccionadosTodos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                width: anchoActual,
                                margin: EdgeInsets.only(
                                    top: largoActual * 0.005,
                                    left: anchoActual * 0.013,
                                    right: anchoActual * 0.013),
                                decoration: const BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.black26),
                                )),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: largoActual * 0.01),
                                          height: largoActual * 0.055,
                                          width: anchoActual * 0.13,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    seleccionadosTodos[index]
                                                        .foto),
                                                //fit: BoxFit.cover,
                                              )),
                                        ),
                                        SizedBox(
                                          width: anchoActual * 0.001,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                children:
                                                    (seleccionadosTodos[index]
                                                            is Producto)
                                                        ? [
                                                            Text(
                                                                seleccionadosTodos[
                                                                        index]
                                                                    .nombre
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    color:
                                                                        colorContenido,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800)),
                                                            Text(
                                                                "    S/. ${seleccionadosTodos[index].precio}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    color:
                                                                        colorContenido,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                          ]
                                                        : [
                                                            Text(
                                                                "Prom. ${seleccionadosTodos[index].nombre}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    color:
                                                                        colorContenido,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800)),
                                                            Text(
                                                                "    S/. ${seleccionadosTodos[index].precio}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    color:
                                                                        colorContenido,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                          ]),

                                            //ESPACIOOO

                                            SizedBox(
                                              width: anchoActual * 0.35,
                                              child: Text(
                                                seleccionadosTodos[index]
                                                    .descripcion
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize:
                                                        largoActual * 0.014,
                                                    color: colorContenido),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: anchoActual * 0.09,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                disminuir(index);
                                              });
                                            },
                                            iconSize: largoActual * 0.028,
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Color.fromRGBO(
                                                  0, 170, 219, 1.000),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${seleccionadosTodos[index].cantidad}",
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 4, 62, 107),
                                              fontSize: largoActual * 0.025,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: anchoActual * 0.09,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                incrementar(index);

                                                /*print(
                                                            "incrementar ${seleccionadosTodos[index].cantidad}");*/
                                              });
                                            },
                                            iconSize: largoActual * 0.028,
                                            icon: const Icon(
                                              Icons.add_circle,
                                              color: Color.fromRGBO(
                                                  0, 170, 219, 1.000),
                                            ),
                                          ),
                                        ),
                                        //BOTON DE ELIMINAR EL PRODUCTO
                                        Container(
                                          width: anchoActual * 0.07,
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                /*print("eliminandinnnnn");
                                                        print(index);*/
                                                var variableEliminar =
                                                    seleccionadosTodos[index];
                                                seleccionadosTodos.remove(
                                                    seleccionadosTodos[index]);
                                                seleccionadosProvider
                                                    .removeWhere((element) =>
                                                        element.nombre ==
                                                        variableEliminar
                                                            .nombre);
                                                selecciondosPromosProvider
                                                    .removeWhere((element) =>
                                                        element.nombre ==
                                                        variableEliminar
                                                            .nombre);
                                              });
                                              setState(() {
                                                obtenerTotal();
                                                actualizarProviderPedido();
                                              });

                                              if (seleccionadosTodos.isEmpty) {
                                                setState(() {
                                                  limpiarVariables();
                                                  actualizarProviderPedido();
                                                });
                                              }

                                              //print(seleccionadosTodos);
                                            },
                                            iconSize: largoActual * 0.027,
                                            icon: const Icon(
                                              Icons.delete_rounded,
                                              color:
                                                  Color.fromRGBO(82, 82, 83, 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                  //CUPONES
                  Container(
                    margin: EdgeInsets.only(
                        bottom: largoActual * 0.002, left: anchoActual * 0.055),
                    child: Text(
                      "Código de referencia",
                      style: TextStyle(
                          color: Colors.white, //colorTitulos,
                          fontWeight: FontWeight.bold,
                          fontSize: tamanoTitulos),
                    ),
                  ),
                  Card(
                    surfaceTintColor: colorCupon,
                    color: Colors.white,
                    elevation: 8,
                    margin: EdgeInsets.only(
                        left: anchoActual * 0.028,
                        right: anchoActual * 0.028,
                        bottom: largoActual * 0.013),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: largoActual * 0.0068,
                              bottom: largoActual * 0.0068,
                              left: anchoActual * 0.069),
                          height: largoActual * 0.065,
                          width: anchoActual * 0.13,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Lottie.asset('lib/imagenes/cupon4.json'),
                        ),
                        SizedBox(
                          width: anchoActual * 0.03,
                        ),
                        SizedBox(
                          width: anchoActual * 0.36,
                          child: TextFormField(
                            controller: _cupon,
                            cursorColor:
                                const Color.fromRGBO(0, 106, 252, 1.000),
                            enableInteractiveSelection: false,
                            style: TextStyle(
                                fontSize: largoActual * 0.018,
                                color: colorContenido),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ingresar el código',
                              hintStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 195, 195, 195),
                                  fontSize: largoActual * 0.018,
                                  fontWeight: FontWeight.w400),
                            ),
                            /*validator: (value) {
                
                                  },*/
                          ),
                        ),
                        SizedBox(
                          width: anchoActual * 0.01,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              buscandoCodigo = true;
                            });
                            if (_cupon.text ==
                                userProvider.user?.codigocliente) {
                              setState(() {
                                _cupon.clear();
                                buscandoCodigo = false;
                                colorCupon = Colors.white;
                              });

                              //si es mi codigo
                              showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      title: Text(
                                        'No puedes usar tu propio código :(',
                                        style: TextStyle(
                                            fontSize: tamanoTitulosDialogs),
                                      ),
                                      content: Text(
                                        'Pero todavía puedes compartir tu codigo con tus amigos para recibir beneficios',
                                        style: TextStyle(
                                            fontSize: tamanoContenidoDialogs),
                                      ),
                                    );
                                  });
                            } else {
                              //si no es mi codigfo
                              await cuponExist(_cupon.text);

                              //print(fechaLimite);
                              if (existe) {
                                //EXISTE EL CODIGO
                                // print("codigo válido");
                                setState(() {
                                  fechaLimite = mesyAnio(fechaLimiteString)
                                      .add(const Duration(days: (30 * 3)));
                                });
                                if (fechaLimite.day <= DateTime.now().day &&
                                    fechaLimite.month <= DateTime.now().month &&
                                    fechaLimite.year <= DateTime.now().year) {
                                  setState(() {
                                    _cupon.clear();
                                  });
                                  //print("el codigo ya expiro");
                                  // ignore: use_build_context_synchronously
                                  showDialog(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          title: Text(
                                            'El código que estas usando ya expiró :(',
                                            style: TextStyle(
                                                fontSize: tamanoTitulosDialogs),
                                          ),
                                          content: Text(
                                            'Pero todavía puedes compartir tu codigo con tus amigos para recibir beneficios',
                                            style: TextStyle(
                                                fontSize:
                                                    tamanoContenidoDialogs),
                                          ),
                                        );
                                      });
                                } else {
                                  // print('el codigo esta vigentee');
                                  if (hayBidon) {
                                    //SI HAY BIDONES NUEVOS EN LA LISTA DE PRODUCTOS
                                    //print('hay bidones nuevos');
                                    setState(() {
                                      buscandoCodigo = false;
                                      colorCupon = const Color.fromARGB(
                                          255, 90, 255, 96);
                                      ahorro = 12.0 * cantidadBidones;

                                      // print("ESTE ES EL AHORRO: $ahorro");
                                      actualizarProviderPedido();
                                    });
                                    // Mostrar SnackBar cuando el código es válido
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Código válido'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    //print('no hay bidones');
                                    setState(() {
                                      _cupon.clear();
                                      buscandoCodigo = false;
                                      colorCupon = Colors.white;
                                    });
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            title: Text(
                                              'Este codigo solo es valido para compras de Bidones Nuevos',
                                              style: TextStyle(
                                                  fontSize:
                                                      tamanoTitulosDialogs),
                                            ),
                                            content: Text(
                                              'Agrega un bidón nuevo a tu carrito para acceder a tu descuento ;)',
                                              style: TextStyle(
                                                  fontSize:
                                                      tamanoContenidoDialogs),
                                            ),
                                          );
                                        });
                                    //PONER SEÑAL DE QUE EL CODIGO SOLO EL VALIDO
                                    //DESUCENTO EN BIDONES NUEVOS
                                  }
                                }
                              } else {
                                //PONER UNA SEÑAL DE
                                //QUE EL CODIGO NO EXISTE
                                //print("no existe el codigo");
                                setState(() {
                                  _cupon.clear();
                                  buscandoCodigo = false;
                                  colorCupon = Colors.white;
                                });
                                // ignore: use_build_context_synchronously
                                showDialog(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        title: Text(
                                          'El codigo que ingresaste no existe :(',
                                          style: TextStyle(
                                              fontSize: tamanoTitulosDialogs),
                                        ),
                                        content: Text(
                                          'Revisa el código e intentalo de nuevo',
                                          style: TextStyle(
                                              fontSize: tamanoContenidoDialogs),
                                        ),
                                      );
                                    });
                              }
                            }
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(5),
                            minimumSize: MaterialStatePropertyAll(
                                Size(anchoActual * 0.247, largoActual * 0.052)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(255, 0, 93, 1.000)),
                          ),
                          child: buscandoCodigo
                              ? SizedBox(
                                  height: largoActual * 0.02,
                                  width: largoActual * 0.02,
                                  child: const CircularProgressIndicator(
                                    color: Color.fromRGBO(253, 253, 253, 1),
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  'Validar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: largoActual * 0.018,
                                      fontWeight: FontWeight.w500),
                                ),
                        ),
                      ],
                    ),
                  ),
                  //TIPO DE ENVIO
                  Container(
                    margin: EdgeInsets.only(
                        bottom: largoActual * 0.002, left: anchoActual * 0.055),
                    child: Text(
                      "Tipo de envío",
                      style: TextStyle(
                          color: Colors.white, //,colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: tamanoTitulos),
                    ),
                  ),
                  Card(
                    surfaceTintColor: color,
                    color: Colors.white,
                    elevation: 8,
                    margin: EdgeInsets.only(
                        left: anchoActual * 0.028,
                        right: anchoActual * 0.028,
                        bottom: largoActual * 0.013),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: anchoActual * 0.28,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.042,
                              right: anchoActual * 0.042,
                              top: largoActual * 0.013,
                              bottom: largoActual * 0.013),
                          child: Column(
                            children: [
                              Text(
                                'Normal',
                                style: TextStyle(
                                    fontSize: largoActual * 0.017,
                                    fontWeight: FontWeight.w600,
                                    color: colorContenido),
                              ),
                              Text(
                                'GRATIS',
                                style: TextStyle(
                                    fontSize: largoActual * 0.0125,
                                    color: colorContenido),
                              ),
                              Text(
                                "Si lo pides después de la 4:00 P.M se agenda para mañana.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: largoActual * 0.0125,
                                    color: colorContenido),
                              ).animate().shake(),
                            ],
                          ),
                        ),
                        Switch(
                          activeColor:
                              const Color.fromRGBO(120, 251, 99, 1.000),
                          inactiveTrackColor:
                              const Color.fromARGB(255, 226, 226, 226),
                          inactiveThumbColor:
                              const Color.fromARGB(255, 174, 174, 174),
                          trackOutlineWidth: const MaterialStatePropertyAll(0),
                          trackOutlineColor: const MaterialStatePropertyAll(
                              Colors.transparent),
                          value: light0,
                          onChanged: (bool value) {
                            setState(() {
                              light0 = value;
                              tiempoPeru = tiempoActual
                                  .subtract(const Duration(hours: 0));
                              /* print(value);
                                      print('hora acrtual ${tiempoPeru.hour}');*/
                            });
                            if (light0 == false) {
                              //ES NORMAL
                              setState(() {
                                color = Colors.white;
                                tipoPedido = 'normal';
                                envio = 0;
                                /*print(tipoPedido);
                                        print(envio);*/
                                actualizarProviderPedido();
                              });
                            } else {
                              //ES EXPRESS
                              if (tiempoPeru.hour <= 16) {
                                //print('son menos de las 16');
                                setState(() {
                                  tipoPedido = 'express';
                                  color =
                                      const Color.fromRGBO(120, 251, 99, 1.000);
                                  envio = 4;
                                  //print(tipoPedido);
                                  //print(envio);
                                  actualizarProviderPedido();
                                });
                              } else {
                                //print('son mas de las 16');
                                setState(() {
                                  tipoPedido = 'normal';
                                  light0 = false;
                                  color = Colors.white;
                                  envio = 0;
                                });
                              }
                            }
                          },
                        ),
                        Container(
                          width: anchoActual * 0.28,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.028,
                              right: anchoActual * 0.028,
                              top: largoActual * 0.013,
                              bottom: largoActual * 0.013),
                          child: Column(
                            children: [
                              Text(
                                'Express',
                                style: TextStyle(
                                    fontSize: largoActual * 0.017,
                                    fontWeight: FontWeight.w600,
                                    color: colorContenido),
                              ),
                              Text('+ S/. 4.00',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.0125,
                                      color: colorContenido)),
                              Text(
                                "Recibe tu producto más rapido. Solo hasta las 4:00 P.M.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: largoActual * 0.0125,
                                    color: colorContenido),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //DIRECCION DE ENVIO
                  Container(
                    margin: EdgeInsets.only(
                        bottom: largoActual * 0.002, left: anchoActual * 0.055),
                    child: Text(
                      "Dirección de envío",
                      style: TextStyle(
                          color: Colors.white, //colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: tamanoTitulos),
                    ),
                  ),
                  Row(
                    children: [
                      Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.028,
                            right: anchoActual * 0.028,
                            bottom: largoActual * 0.013),
                        //child: DropdownButton(items: items, onChanged: onChanged)
                        child: GestureDetector(
                          onTap: () => _showModalBottomSheet(context),
                          child: Container(
                            width: anchoActual / 1.1,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              //color: Color.fromARGB(255, 187, 167, 167),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _selectedValue ??
                                              'Agregar una ubicación',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 22, 46, 153),
                                              fontSize: 16),
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: largoActual * 0.0013,
                                    bottom: largoActual * 0.0013,
                                  ),
                                  height: largoActual * 0.061,
                                  width: largoActual * 0.061,
                                  decoration: BoxDecoration(
                                    //  color: Color.fromARGB(0, 78, 27, 27),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Lottie.asset('lib/imagenes/ubi4.json'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        /* child: Container(
                              //height: largoActual * 0.2,
                              margin: EdgeInsets.only(
                                  left: anchoActual * 0.055,
                                  right: anchoActual * 0.055,
                                  top: largoActual * 0.0068,
                                  bottom: largoActual * 0.0068),
                              //AQUI SE PONDRA LA DIRECCION QUE ELIGIO EL CLIENTE
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: hayUbicacion
                                    ? [
                                        SizedBox(
                                          width: anchoActual * 0.62,
                                          child: Text(
                                            direccion,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: largoActual * 0.017,
                                                color: colorDireccion),
                                          ),
                                        ),
                                        SizedBox(
                                          width: anchoActual * 0.013,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: largoActual * 0.0013,
                                            bottom: largoActual * 0.0013,
                                          ),
                                          height: largoActual * 0.061,
                                          width: largoActual * 0.061,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          child: Lottie.asset(
                                              'lib/imagenes/ubi4.json'),
                                        ),
                                      ]
                                    : [ 
                                        Container(
                                          width: anchoActual * 0.65,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 12, right: 5),
                                            child: DropdownButton<String>(
                                              iconEnabledColor: colorContenido,
                                              hint: Text(
                                                direccion,
                                                style: TextStyle(
                                                  color: colorDireccion,
                                                  fontSize: largoActual * 0.017,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: colorContenido,
                                                fontSize: largoActual * 0.017,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              elevation: 20,
                                              dropdownColor: Colors.white,
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
                                                  if (direccionSeleccionada(newValue).zonaID ==
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
                                                      ubicacionSelectID =
                                                          miUbicacion.id;
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: largoActual * 0.0013,
                                            bottom: largoActual * 0.0013,
                                          ),
                                          height: largoActual * 0.061,
                                          width: largoActual * 0.061,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          child: Lottie.asset(
                                              'lib/imagenes/ubi4.json'),
                                        ),
                                      ],
                              ))*/
                      ),

                      /*   Container(
                                    width: MediaQuery.of(context).size.width/9,
                                    height:MediaQuery.of(context).size.width/9,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: IconButton(onPressed: (){
                                      Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Pruebaubicacion()));
                                    },
                                                                   icon: Icon(Icons.add_location_outlined,color: Color.fromARGB(255, 51, 88, 211),
                                                                   size:MediaQuery.of(context).size.width/15)),
                                  )*/
                    ],
                  ),
                  //RESUMEN
                  Container(
                    margin: EdgeInsets.only(
                        bottom: largoActual * 0.002, left: anchoActual * 0.055),
                    child: Text(
                      "Resumen de Pedido",
                      style: TextStyle(
                          color: Colors.white, //colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: tamanoTitulos),
                    ),
                  ),
                  Card(
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    elevation: 8,
                    margin: EdgeInsets.only(
                      left: anchoActual * (10 / 360),
                      right: anchoActual * (10 / 360),
                      bottom: largoActual * (10 / 736),
                    ),
                    child: Container(
                        margin: EdgeInsets.only(
                            left: anchoActual * (20 / 360),
                            right: anchoActual * (20 / 360),
                            bottom: largoActual * (8 / 736),
                            top: largoActual * (8 / 736)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Productos',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w500,
                                      color: colorContenido),
                                ),
                                Text(
                                  'S/.${totalProvider}0',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w500,
                                      color: colorContenido),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Envio',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w500,
                                      color: colorContenido),
                                ),
                                Text(
                                  'S/.${envio}0',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w500,
                                      color: colorContenido),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ahorro',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(
                                          234, 51, 98, 1.000)),
                                ),
                                Text(
                                  'S/.${ahorro}0',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.017,
                                      fontWeight: FontWeight.w700,
                                      color: const Color.fromRGBO(
                                          234, 51, 98, 1.000)),
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                  //NOTAS PARA EL REPARTIDOR
                  Container(
                    margin: EdgeInsets.only(
                        bottom: largoActual * 0.002, left: anchoActual * 0.055),
                    child: Text(
                      "Notas para el repartidor",
                      style: TextStyle(
                          color: Colors.white, //colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: tamanoTitulos),
                    ),
                  ),
                  Card(
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    elevation: 8,
                    margin: EdgeInsets.only(
                        left: anchoActual * 0.028,
                        right: anchoActual * 0.028,
                        bottom: anchoActual * 0.013),
                    child: Container(
                      margin: EdgeInsets.only(
                          left: anchoActual * 0.055,
                          right: anchoActual * 0.055,
                          bottom: largoActual * 0.0068),
                      child: TextFormField(
                        controller: notas,
                        cursorColor: const Color.fromRGBO(0, 106, 252, 1.000),
                        enableInteractiveSelection: false,
                        style: TextStyle(
                            fontSize: largoActual * 0.018,
                            color: colorContenido),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Ej. Casa con porton azúl, tocar tercer piso',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 195, 195, 195),
                              fontSize: largoActual * 0.018,
                              fontWeight: FontWeight.w400),
                        ),
                        /*validator: (value) {
                
                              },*/
                      ),
                    ),
                  ),

                  SizedBox(
                    height: largoActual * (95 / 630),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          toolbarHeight: largoActual * 0.08,
        ),
        body: SafeArea(
            child: Center(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 0),
                height: largoActual * 0.9,
                width: anchoActual * 0.9,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Lottie.asset('lib/imagenes/carritovacio.json'),
              ),
              Positioned(
                  top: anchoActual *
                      0.6, // Ajusta la posición vertical según tus necesidades
                  left: anchoActual * 0.25,
                  child: Text(
                    'Tu carrito esta vacío',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 1, 42, 76),
                        fontWeight: FontWeight.w600,
                        fontSize: largoActual * 0.023),
                  )),
            ],
          ),
        )),
      );
    }
  }
}
