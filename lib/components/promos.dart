import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/promocion_model.dart';
import 'package:appsol_final/models/producto_promocion_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Promos extends StatefulWidget {
  const Promos({super.key});
  @override
  State<Promos> createState() => _PromosState();
}

class _PromosState extends State<Promos> {
  late PedidoModel pedidoMio;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiProdProm = '/api/prod_prom';
  DateTime fechaLim = DateTime.now();
  List<Producto> productosProvider = [];
  List<Promo> promosProvider = [];
  List<Promo> listPromociones = [];
  List<Producto> listProducto = [];
  double totalProvider = 0.0;
  List<ProductoPromocion> listProdProm = [];
  bool almenosUno = false;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  double envio = 0.0;
  //Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  Color colorTextos = Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  DateTime mesyAnio(String fecha) {
    fechaLim = DateTime.parse(fecha);
    return fechaLim;
  }

  Future<void> _initialize() async {
    //print('1) INITIALIZE-------------');
    await getTodosProductoPromocion();
    await getProducts();
    await getPromociones();
  }

  Future<dynamic> getTodosProductoPromocion() async {
    //print("--------------get productos promos----");
    var res = await http.get(
      Uri.parse(apiUrl + apiProdProm),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<ProductoPromocion> tempProductoPromocion =
            data.map<ProductoPromocion>((mapa) {
          return ProductoPromocion(
            promocionId: mapa['promocion_id'],
            productoId: mapa['producto_id'],
            cantidadProd: mapa['cantidad'],
            cantidadPromo: 0,
          );
        }).toList();

        setState(() {
          listProdProm = tempProductoPromocion;
        });
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getProducts() async {
    //print("---------------get productos-----------------------");
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
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        if (mounted) {
          setState(() {
            tempProducto.removeWhere((element) => (element.id == 6));
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

  Future<dynamic> getPromociones() async {
    //print("---------------get promos ----------------");
    var res = await http.get(
      Uri.parse('$apiUrl/api/promocion'),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Promo> tempPromocion = data.map<Promo>((mapa) {
          return Promo(
              id: mapa['id'],
              nombre: mapa['nombre'],
              precio: mapa['precio'].toDouble(),
              descripcion: mapa['descripcion'],
              fechaLimite: mapa['fecha_limite'],
              foto: '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}');
        }).toList();

        if (mounted) {
          setState(() {
            listPromociones = tempPromocion;
          });
          for (var i = 0; i < listPromociones.length; i++) {
            for (var j = 0; j < listProdProm.length; j++) {
              if (listPromociones[i].id == listProdProm[j].promocionId) {
                for (var t = 0; t < listProducto.length; t++) {
                  if (listProdProm[j].productoId == listProducto[t].id) {
                    setState(() {
                      listProducto[t].promoID = listProdProm[j].promocionId;
                      listProducto[t].cantidad = listProdProm[j].cantidadProd;
                      listPromociones[i].listaProductos.add(listProducto[t]);
                    });
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

//este nel PASTEL
  void obtenerPromos() {
    /*print("-------------------------");
    print("obtiene PRODUCTOS");*/

    List<Promo> listTemp = promosProvider +
        listPromociones.where((promocion) => promocion.cantidad > 0).toList();

    var seen = <String>{};
    List<Promo> uniquelist =
        listTemp.where((promo) => seen.add(promo.nombre)).toList();

    setState(() {
      promosProvider = uniquelist;
    });

    //SE CALCULA EL PRECIO TOTAL DE PRODUCTOS YPROMOSSS
    double totalproductos = 0;
    double totalpromos = 0;
    for (var productos in productosProvider) {
      totalproductos += productos.cantidad * productos.precio;
    }
    for (var promo in promosProvider) {
      totalpromos += promo.cantidad * promo.precio;
    }
    setState(() {
      totalProvider = totalproductos + totalpromos;
    });
  }

//FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      almenosUno = true;
      listPromociones[index].cantidad++;
    });
    /*print("esta es la listA PROMOCIONES");
    print(listPromociones[index].cantidad);
    print("esta es la PROMOCIONES CONTABILIZADAS");*/
  }

  void disminuir(int index) {
    if (listPromociones[index].cantidad > 0) {
      setState(() {
        listPromociones[index].cantidad--;
      });
    }
    almenosUno =
        listPromociones.where((promo) => promo.cantidad > 0).isNotEmpty;
    //print(listPromociones[index].cantidad);
  }

  double obtenerTotal() {
    double stotal = 0;

    List promocionesContabilizadas =
        listPromociones.where((promo) => promo.cantidad > 0).toList();
    for (var promo in promocionesContabilizadas) {
      stotal += promo.cantidad * promo.precio;
    }

    return stotal;
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      //print('ES PEDIDOOO');
      productosProvider = pedido.seleccionados;
      //COMO HACER AHHHHH
      promosProvider = pedido.seleccionadosPromo;
      totalProvider = pedido.totalProds;
      envio = pedido.envio;
      cantCarrito = productosProvider.length + promosProvider.length;

      if (cantCarrito > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      //print('no es pedido');
      setState(() {
        cantCarrito = 0;
        productosProvider = [];
        promosProvider = [];
        colorCantidadCarrito = Colors.grey;
        totalProvider = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = obtenerTotal();
    //final TabController _tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = context.watch<PedidoProvider>();
    esVacio(pedidoProvider.pedido);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: largoActual * 0.08,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: anchoActual * 0.15,
                  margin: EdgeInsets.only(top: largoActual * 0.018),
                  child: Text(
                    'VER CARRITO',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: colorTextos,
                        fontSize: largoActual * 0.015,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  width: anchoActual * 0.02,
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: largoActual * 0.018, right: anchoActual * 0.045),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 106, 252, 1.000),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pedido()
                              //const Promos()
                              ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_rounded),
                      color: Colors.white,
                      iconSize: largoActual * 0.030,
                    ).animate().shakeY(
                          duration: Duration(milliseconds: 300),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: largoActual * 0.01,
                      ),
                      Container(
                        //color: Colors.grey,
                        margin:
                            EdgeInsets.only(top: 0, left: anchoActual * 0.055),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                               
                                decoration:const BoxDecoration(
                                  //color:Colors.grey,
                                  image: DecorationImage(
                                    image: AssetImage('lib/imagenes/nuevecito.png')
                                  )
                                ),
                              ),
                              SizedBox(
                                    width: anchoActual * 0.045,
                                  ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¡Escoge tu promoción",
                                style: TextStyle(
                                    color: colorTextos,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    fontSize: largoActual* 0.024),
                              ),
                              Text(
                                "favorita!",
                                style: TextStyle(
                                    color: colorTextos,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    fontSize: largoActual * 0.024),
                              ),
                              /*Container(
                                margin:
                                    EdgeInsets.only(left: anchoActual * 0.055),
                                //color:Colors.grey,
                                //height:100,
                                child: Text(
                                  "están hechos para ti!",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 1, 46, 84),
                                      fontSize: largoActual * 0.025,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),*/
                            ],
                          ),
                            ]),
                      ),

                      //CONTAINER CON LIST BUILDER
                      SizedBox(
                          height: largoActual * 0.57,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listPromociones.length,
                            itemBuilder: (context, index) {
                              Promo promocion = listPromociones[index];
                              return Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                elevation: 8,
                                margin: EdgeInsets.only(
                                    top: largoActual * 0.027,
                                    left: anchoActual * 0.028,
                                    right: anchoActual * 0.028,
                                    bottom: largoActual * 0.041),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: largoActual * 0.26,
                                      width: anchoActual * 0.5,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image:
                                                  CachedNetworkImageProvider(promocion.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    Container(
                                      width: anchoActual * 0.53,
                                      //height: largoActual * 0.149,
                                      margin: EdgeInsets.only(
                                          top: largoActual * 0.013,
                                          right: anchoActual * 0.042,
                                          left: anchoActual * 0.042),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Promoción ${promocion.nombre}".toUpperCase(),
                                            style: TextStyle(
                                                                                           fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.02,
                                                color: colorTextos),
                                            textAlign: TextAlign.center,
                                          ),
                                          Flex(
                                            direction: Axis.vertical,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                promocion.descripcion,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize:
                                                        largoActual * 0.0145,
                                                    color: colorTextos),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Val. Hasta: ${mesyAnio(promocion.fechaLimite).day.toString()}/${mesyAnio(promocion.fechaLimite).month.toString()}/${mesyAnio(promocion.fechaLimite).year.toString()}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: largoActual * 0.012,
                                                color: colorTextos),
                                          ),
                                          Text(
                                            "S/.${promocion.precio}0",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.022,
                                                color: colorTextos),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    disminuir(index);
                                                    /*print(
                                                        "disminuir ${promocion.cantidad}");*/
                                                  });
                                                },
                                                iconSize: largoActual * 0.041,
                                                color: colorTextos,
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                              Text(
                                                "${promocion.cantidad}",
                                                style: TextStyle(
                                                    color: colorTextos,
                                                    fontSize:
                                                        largoActual * 0.034,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    incrementar(index);
                                                    /*print(
                                                        "incrementar ${promocion.cantidad}");*/
                                                  });
                                                },
                                                iconSize: largoActual * 0.041,
                                                color: const Color.fromARGB(
                                                    255, 0, 49, 89),
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: largoActual * 0.01),
                          padding: EdgeInsets.only(left: anchoActual * 0.05,top:anchoActual * 0.02, bottom:anchoActual * 0.02),
                          width: anchoActual*0.4,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                        0, 106, 252, 1.000),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  
                                  //margin:EdgeInsets.only(left: anchoActual * 0.055),
                                  child: Text(
                                    "Subtotal:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.021,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                ),
                                Container(
                                  //margin:EdgeInsets.only(left: anchoActual * 0.055),
                                  child: Text(
                                    "S/.${total}0",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: largoActual * 0.029,
                                        color: Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                ),



                                
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(right: anchoActual * 0.035),
                                child: Text(
                                  "Agregar al carrito",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: largoActual * 0.02,
                                      color:
                                          Colors.black),
                                ),
                              ),
                              SizedBox(
                              height: largoActual*0.007,
                            ),
                              Container(
                                width: largoActual*0.072,
                              height: largoActual*0.072,
                              //color: Colors.grey,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              margin:
                                  EdgeInsets.only(right: anchoActual * 0.035),
                                child: IconButton(
                                  onPressed: almenosUno
                                          ? () async {
                                              obtenerPromos();
                                  
                                              pedidoMio = PedidoModel(
                                                seleccionados: productosProvider,
                                                seleccionadosPromo:
                                                    promosProvider,
                                                cantidadProd:
                                                    productosProvider.length +
                                                        promosProvider.length,
                                                totalProds: totalProvider,
                                                envio: envio,
                                              );
                                              Provider.of<PedidoProvider>(context,
                                                      listen: false)
                                                  .updatePedido(pedidoMio);
                                            }
                                          : null,
                                 icon: Icon(Icons.add_shopping_cart_sharp,color: Colors.white,size: anchoActual*0.065,)) /* ElevatedButton(
                                      onPressed: almenosUno
                                          ? () async {
                                              obtenerPromos();
                                  
                                              pedidoMio = PedidoModel(
                                                seleccionados: productosProvider,
                                                seleccionadosPromo:
                                                    promosProvider,
                                                cantidadProd:
                                                    productosProvider.length +
                                                        promosProvider.length,
                                                totalProds: totalProvider,
                                                envio: envio,
                                              );
                                              Provider.of<PedidoProvider>(context,
                                                      listen: false)
                                                  .updatePedido(pedidoMio);
                                            }
                                          : null,
                                      style: ButtonStyle(
                                          elevation: MaterialStateProperty.all(8),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromRGBO(58, 182, 0, 1))),
                                      child: Icon(
                                          Icons.add_shopping_cart_rounded,
                                          color: Colors.white,
                                          size: anchoActual*0.073,
                                      )),*/
                                
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]))));
  }
}
