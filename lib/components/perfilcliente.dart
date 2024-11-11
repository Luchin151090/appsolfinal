import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  State<PerfilCliente> createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  late UserModel clienteUpdate;
  Color colorTitulos = const Color.fromARGB(255, 3, 34, 60);
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorInhabilitado = const Color.fromARGB(255, 130, 130, 130);
  bool estaHabilitado = false;
  String mensajeBanco = 'Numero de celular, cuenta o CCI';
  List<String> mediosString = ['Yape', 'Plin', 'Transferencia'];
  List<String> bancosString = ['BCP', 'BBVA', 'Caja Arequipa', 'Otros'];
  bool esYape = false;
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _cuenta = TextEditingController();
  String telefono_ = '';
  String cuenta_ = '';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCliente = '/api/cliente/';
  DateTime fechaLimite = DateTime.now();
  TextEditingController numeroDeCuenta = TextEditingController();
  String numrecargas = '';
  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      //print('es string');
      return DateTime.parse(fecha);
    } else {
      //print('no es string');
      return DateTime.now();
    }
  }

  Future<dynamic> recargas(clienteID) async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + '/api/cliente/recargas/' + clienteID.toString()),
        headers: {"Content-type": "application/json"},
      );
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (data != null) {
          if (mounted) {
            setState(() {
              numrecargas = data['recargas'];
            });
          }
        } else {
          if (mounted) {
            setState(() {
              numrecargas = '0';
            });
          }
        }
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> updateCliente(saldoBeneficios, suscripcion, frecuencia,
      quiereretirar, clienteID, medioretiro, bancoretiro, numerocuenta) async {
    /* print("2.- UPDAE CLEINTE---");

    print("cliente----------------------------------------------");
    print(clienteID);
    print("end point URI------------------------------------------------");
    print(apiUrl + apiCliente + clienteID.toString());
    print("quiereretirar");
    print(quiereretirar);
    print("saldo bene");
    print(saldoBeneficios);
    print("frencua............");
    print(frecuencia);*/
    await http.put(Uri.parse(apiUrl + apiCliente + clienteID.toString()),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "saldo_beneficios": saldoBeneficios,
          "suscripcion": suscripcion,
          "frecuencia": frecuencia,
          "quiereretirar": quiereretirar,
          "medio_retiro": medioretiro,
          "banco_retiro": bancoretiro,
          "numero_cuenta": numerocuenta
        }));
  }

  void _showTransferDialog(BuildContext context, String type) {
    final TextEditingController numberController = TextEditingController();
    final TextEditingController bankController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            type == 'Otros'
                ? 'Ingrese datos de transferencia'
                : 'Ingrese número de $type',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: type == 'Otros'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de cuenta',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bankController,
                      decoration: const InputDecoration(
                        labelText: 'Banco de procedencia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                )
              : TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número de destino',
                    //border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Obtener los datos actuales del usuario desde el Provider
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final currentUser = userProvider.user;

                if (currentUser != null) {
                  try {
                    // Actualizar los datos en la base de datos
                    await updateCliente(
                      currentUser.saldoBeneficio,
                      currentUser.suscripcion,
                      'NA',
                      true, // quiereretirar
                      currentUser.id,
                      type, // medioretiro
                      type == 'Otros'
                          ? bankController.text
                          : type, // bancoretiro
                      numberController.text, // numerocuenta
                    );

                    // Luego actualizar el Provider
                    actualizarProviderCliente(
                      currentUser.id,
                      currentUser.nombre,
                      currentUser.apellidos,
                      currentUser.saldoBeneficio,
                      currentUser.codigocliente,
                      currentUser.fechaCreacionCuenta,
                      currentUser.sexo,
                      'NA',
                      currentUser.suscripcion,
                      type, // medio_retiro
                      type == 'Otros'
                          ? bankController.text
                          : type, // banco_retiro
                      numberController.text, // numero_cuenta
                    );

                    Navigator.pop(context);

                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Información de transferencia actualizada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Mostrar mensaje de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error al actualizar la información: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Confirmar',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required double width,
    required double height,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width * 0.25,
      height: height * 0.05,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: height * 0.016,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void actualizarProviderCliente(
      clienteid,
      name,
      lastname,
      saldo,
      codigo,
      fechaCreacion,
      sexo,
      frecuencia,
      suscrip,
      medioretiro,
      bancoretiro,
      numerocuenta) async {
    //  print("1 .- ---actualizar Provider");

    clienteUpdate = UserModel(
        id: clienteid,
        nombre: name,
        apellidos: lastname,
        saldoBeneficio: saldo,
        codigocliente: codigo,
        fechaCreacionCuenta: fechaCreacion,
        sexo: sexo,
        frecuencia: frecuencia,
        quiereRetirar: true,
        suscripcion: suscrip,
        rolid: 4);
    // print("${clienteUpdate}");

    Provider.of<UserProvider>(context, listen: false).updateUser(clienteUpdate);

    await updateCliente(saldo, suscrip, frecuencia, true, clienteid,
        medioretiro, bancoretiro, numerocuenta);
  }

  String capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto[0].toUpperCase()}${texto.substring(1).toLowerCase()}';
  }

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final idcliente = userProvider.user?.id;
    recargas(idcliente);
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    //TYJYUJY
    return Scaffold(
        backgroundColor: Colors.white,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          /*appBar: AppBar(
        backgroundColor: Colors.white,
      ),*/
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.all(anchoActual * 0.04),
            child: ListView(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: largoActual * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //FOTO DEL CLIENTE
                          Container(
                            margin: EdgeInsets.only(left: anchoActual * 0.035),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 220, 220, 220),
                                borderRadius: BorderRadius.circular(50)),
                            height: largoActual * 0.085,
                            width: anchoActual * 0.18,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              //poner un if por aqui por si es hombre o mujer
                              child: userProvider.user?.sexo == 'Femenino'
                                  ? Icon(
                                      Icons.face_3_rounded,
                                      color: colorTitulos,
                                      size: anchoActual * 0.14,
                                    )
                                  : Icon(
                                      Icons.face_6_rounded,
                                      color: colorTitulos,
                                      size: anchoActual * 0.14,
                                    ),
                            ),
                          ),

                          SizedBox(
                            width: anchoActual * 0.03,
                          ),
                          Container(
                            width: anchoActual * 0.45,
                            child: Column(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Nombre
                                Text(
                                  capitalizarPrimeraLetra(
                                      userProvider.user?.nombre ?? ''),
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: largoActual * 0.023,
                                    color: colorTitulos,
                                  ),
                                ),

                                SizedBox(height: largoActual * 0.005),
                                // Ícono de estrella

                              

                                //Correo
                                /*
                                  Text(
                                    'Codigo: ${userProvider.user?.codigocliente}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: largoActual * 0.02,
                                        color: colorTitulos),
                                  ),
                                  */

                                /*
                                  //Numero
                                  Text(
                                    '${userProvider.user?.suscripcion}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: largoActual * 0.018,
                                        color: colorTitulos),
                                  ),
                                  */
                              ],
                            ),
                          ),
                          //SizedBox(width: anchoActual * 0.02),
                        ],
                      ),
                      /*
                      Container(
                        width: anchoActual * 0.1,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: largoActual * 0.03,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            // Acción cuando se hace clic en el ícono de lápiz
                          },
                        ),
                      ),*/
                    ],
                  ),

                  /*  
                  SizedBox(
                    height: largoActual * 0.02,),
              */
                  //CARDS DE INFOPERSONAL MEMBRE SOL CUPONES
                  /*Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(anchoActual * 0.03),
                    /*
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    */
              
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Cambiado para alinear al inicio
                      children: [
                        Column(
                          children: [
                            Text(
                              'Eventos Especiales',
                              style: GoogleFonts.poppins(
                                fontSize: largoActual * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),*/
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),

                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        //flex: 2,
                        width: double.infinity,
                        height: largoActual / 5,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          surfaceTintColor: Colors.white,
                          color: Colors.white,
                          elevation: 8,
                          /*
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  barrierColor: Colors.grey.withOpacity(0.41),
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(
                                            16), // Espaciado interno
                                        width: 150,
                                        height: 230,
                                        child: Column(
                                          mainAxisSize: MainAxisSize
                                              .min, // Ajusta el tamaño del dialog
                                          children: [
                                            // Texto que se mostrará en el modal
                                            const Text(
                                              "A más recargas \n más\n oportunidades\nganar.",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                height:
                                                    16), // Espacio entre el texto y el botón
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cerrar el diálogo
                                              },
                                              child: Text('Cerrar'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },*/
                          child: Column(
                            children: [
                              Container(
                                height: largoActual * 0.18,
                                width: anchoActual * 0.39,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        '$apiUrl/images/sorteoviaje.png'), // Imagen del sorteo
                                    fit: BoxFit.fitWidth,
                                    opacity: 0.69,
                                  ),
                                ),
                              ),
                              /*SizedBox(
                                width: anchoActual * 0.034,
                              ),*/
                              /*
                                Container(
                                    //color: Colors.amber,
                                    padding:
                                        EdgeInsets.only(left: anchoActual * 0.04),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                        text: "${numrecargas}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.06,
                                          color: colorTitulos,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "\nRecargas",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: largoActual * 0.016,
                                            color: colorTitulos,
                                            height: 0.2),
                                      ),
                                      TextSpan(
                                        text: "\nu oportunidades",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: largoActual * 0.016,
                                            color: colorTitulos),
                                      ),
                                      TextSpan(
                                        text: "\nPulsa aquí.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.016,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ]))),*/
                              SizedBox(
                                width: anchoActual * 0.034,
                              ),
              /*
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor: Colors.grey.withOpacity(0.41),
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              16), // Espaciado interno
                                          width: 150,
                                          height: 230,
                                          child: Column(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ajusta el tamaño del dialog
                                            children: [
                                              // Texto que se mostrará en el modal
                                              Text(
                                                'A más recargas\nmás\noportunidades\nganar.',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                  height:
                                                      16), // Espacio entre el texto y el botón
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Cerrar el diálogo
                                                },
                                                child: Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              
                              /*
                                  Container(
                                      height: largoActual * 0.08,
                                      width: anchoActual * 0.24,
                                      //color: Colors.grey,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        /*gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(0, 106,
                                                                252, 1.000),
                                                            Color.fromRGBO(0, 106,
                                                                252, 1.000),
                                                            Color.fromRGBO(0, 106,
                                                                252, 1.000),
                                                            Color.fromRGBO(
                                                                150, 198, 230, 1),
                                                            Colors.white,
                                                            Colors.white,
                                                          ],
                                                          begin:
                                                              Alignment.topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                        ),*/
                                        //color: Colors.transparent,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$apiUrl/images/sorteoviaje.png'), // Cambiado a NetworkImage
                                          fit: BoxFit.cover,
                                          opacity: 0.69,
                                        ),
                                      )
                                      /*child: Lottie.asset(
                                    'lib/imagenes/Animation - 1718738830493.json',
                                  ),*/
                                      ),*/
                            */
                            ],
                          ),
                          //),
                        ),
                      ),
              
                      //CARD DE INFO PERSONAL
                      /*
                    Expanded(
                      flex: 1,
                      child: Card(
                          margin: EdgeInsets.only(left: anchoActual * 0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          //surfaceTintColor: Colors.white,
                          color: Colors.white,
                          elevation: 8,
                          child: Container(
                            margin: EdgeInsets.all(anchoActual * 0.02),
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    //ACA ACCIONES
                                  },
                                  icon: Icon(
                                    Icons.person_2_outlined,
                                    color: colorLetra,
                                    size: anchoActual * 0.11,
                                  ),
                                ),
                                Text(
                                  'Info. Personal',
                                  style: TextStyle(
                                      color: colorLetra,
                                      fontWeight: FontWeight.w400,
                                      fontSize: largoActual * 0.015),
                                ),
                              ],
                            ),
                          )),
                    ),
                    */
                    ],
                  ),*/
                  // SizedBox(height: largoActual * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(anchoActual * 0.03),
                    /*
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    */

                    child: /*Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Cambiado para alinear al inicio
                      children: [
                        Column(
                          children: [*/
                        Text(
                      'Resumen',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //  ],
                    // ),
                    //  ],
                    //   ),
                  ),

                  // Resumen Section
                  Container(
                    width: double.infinity,
                    /*
                    padding: EdgeInsets.symmetric(
                      horizontal: anchoActual * 0.04,
                      vertical: anchoActual * 0.03,
                    ),
              */

                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: anchoActual * 0.35,
                          child: Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: largoActual * 0.02,
                                vertical: largoActual * 0.015,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: Colors.blue.shade700,
                                    size: largoActual * 0.03,
                                  ),
                                  SizedBox(height: largoActual * 0.01),
                                  Text(
                                    'S/. ${userProvider.user?.saldoBeneficio}0',
                                    style: GoogleFonts.poppins(
                                      fontSize: largoActual * 0.025,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Soles',
                                    style: GoogleFonts.poppins(
                                      fontSize: largoActual * 0.016,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Retiralo hasta: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.016),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: largoActual * 0.06,
                          width: 1.5,
                          color: Colors.grey.shade200,
                        ),
                        SizedBox(
                          width: anchoActual * 0.35,
                          child: Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: largoActual * 0.02,
                                vertical: largoActual * 0.015,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.work,
                                    color: Colors.blue.shade700,
                                    size: largoActual * 0.03,
                                  ),
                                  SizedBox(height: largoActual * 0.01),
                                  Text(
                                    '${numrecargas}',
                                    style: GoogleFonts.poppins(
                                      fontSize: largoActual * 0.025,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Recargas',
                                    style: GoogleFonts.poppins(
                                      fontSize: largoActual * 0.016,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //SizedBox(height: largoActual * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(anchoActual * 0.03),
                    /*
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    */
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Cambiado para alinear al inicio
                      children: [
                        Column(
                          children: [
                            Text(
                              'Código',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Código Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: anchoActual * 0.04,
                          vertical: largoActual * 0.015,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            // <- Aquí se añade la sombra
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.3), // Color de la sombra
                              spreadRadius: 1, // Qué tanto se expande
                              blurRadius: 5, // Qué tan borrosa es
                              offset: const Offset(
                                  0, 2), // Posición (horizontal, vertical)
                            ),
                          ],
                          color:
                              Colors.white, // Importante añadir color de fondo
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${userProvider.user?.codigocliente}',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Válido por 3 meses',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            )

                            /*
                            IconButton(
                              icon: Icon(
                                Icons.share,
                                size: largoActual * 0.025,
                                color: Colors.grey,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),

                  //SizedBox(height: largoActual * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(anchoActual * 0.03),
                    /*
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    */
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Cambiado para alinear al inicio
                      children: [
                        Column(
                          children: [
                            Text(
                              'Escoge el tipo de retiro',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                        context: context,
                        text: 'Yape',
                        width: anchoActual,
                        height: largoActual,
                        onPressed: () => _showTransferDialog(context, 'Yape'),
                      ),
                      _buildButton(
                        context: context,
                        text: 'Plin',
                        width: anchoActual,
                        height: largoActual,
                        onPressed: () => _showTransferDialog(context, 'Plin'),
                      ),
                      _buildButton(
                        context: context,
                        text: 'Otros',
                        width: anchoActual,
                        height: largoActual,
                        onPressed: () => _showTransferDialog(context, 'Otros'),
                      ),
                    ],
                  ),
                ],

                //BILLETERA SOL
                /*
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.045),
                          child: Text(
                            "Billetera Sol",
                            style: TextStyle(
                                color: colorTitulos,
                                fontWeight: FontWeight.w600,
                                fontSize: largoActual * (16 / 760)),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.17,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              surfaceTintColor:
                                  Color.fromRGBO(246, 224, 128, 1.000),
                              color: Colors.white,
                              elevation: 8,
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: anchoActual * 0.1,
                                  right: anchoActual * 0.1,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'S/. ${userProvider.user?.saldoBeneficio}0',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w700,
                                              fontSize: largoActual * 0.045),
                                        ),
                                        Text(
                                          'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w400,
                                              fontSize: largoActual * 0.016),
                                        ),
                                        SizedBox(
                                          height: largoActual * 0.01,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  (168 / 375),
                                          height:
                                              MediaQuery.of(context).size.height *
                                                  0.03,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  String _selectedItem =
                                                      'Seleccione su metodo';
                                                  String _otroItem =
                                                      'Ingrese su banco';
                                                  return Dialog(
                                                    child: StatefulBuilder(
                                                      builder: (BuildContext
                                                              context,
                                                          StateSetter setState) {
                                                        return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                          decoration:
                                                              BoxDecoration(
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
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            margin: EdgeInsets.all(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.04),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  'Selecciona el metodo que prefieras',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .height *
                                                                        0.028,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                      onChanged:
                                                                          (String?
                                                                              newValue) {
                                                                        setState(
                                                                            () {
                                                                          _selectedItem =
                                                                              newValue!;
                                                                          /*print(
                                                                          'valor: $_selectedItem');*/
                                                                        });
                                                                      },
                                                                      value:
                                                                          _selectedItem,
                                                                      items:
                                                                          <String>[
                                                                        'Seleccione su metodo',
                                                                        'Transferencia',
                                                                        'Yape o plin',
                                                                      ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child: Text(
                                                                              value),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          _selectedItem ==
                                                                              'Transferencia',
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          DropdownButtonFormField<
                                                                              String>(
                                                                            onChanged:
                                                                                (String? newValue) {
                                                                              setState(() {
                                                                                _otroItem = newValue!;
                                                                              });
                                                                            },
                                                                            value:
                                                                                _otroItem,
                                                                            items:
                                                                                <String>[
                                                                              'Ingrese su banco',
                                                                              'BBVA',
                                                                              'BCP',
                                                                              'Caja Arequipa',
                                                                              'Otros',
                                                                            ].map<DropdownMenuItem<String>>((String value) {
                                                                              return DropdownMenuItem<String>(
                                                                                value: value,
                                                                                child: Text(value),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                          TextFormField(
                                                                            controller:
                                                                                _cuenta,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintText:
                                                                                  'Ingrese su numero de cuenta',
                                                                              border:
                                                                                  InputBorder.none,
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null ||
                                                                                  value.isEmpty) {
                                                                                return 'Por favor, ingrese su numero de cuenta';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              /*  print("-----N CUENTA BANCO-");
                                                                              print("Provider");
                                                                              print("${userProvider.user?.id}");
                                                                             print("${userProvider.user?.frecuencia}");
                                                                              print("${userProvider.user?.codigocliente}");
                                                                             print("${userProvider.user?.sexo}");
                                                                              print("${userProvider.user?.suscripcion}");
                                                                             print("${userProvider.user?.fechaCreacionCuenta}");
                                                                             print("${_selectedItem}");
                                                                             print("${_otroItem}");
                                                                             print("${_cuenta.text}");*/
              
                                                                              actualizarProviderCliente(
                                                                                  userProvider.user?.id,
                                                                                  userProvider.user?.nombre,
                                                                                  userProvider.user?.apellidos,
                                                                                  userProvider.user?.saldoBeneficio,
                                                                                  userProvider.user?.codigocliente,
                                                                                  userProvider.user?.fechaCreacionCuenta,
                                                                                  userProvider.user?.sexo,
                                                                                  userProvider.user?.frecuencia,
                                                                                  userProvider.user?.suscripcion,
                                                                                  _selectedItem,
                                                                                  _otroItem,
                                                                                  _cuenta.text);
                                                                              cuenta_ =
                                                                                  _cuenta.text;
                                                                              _cuenta.text =
                                                                                  '';
                                                                              Navigator.of(context).pop();
                                                                              _showThankYouDialog(context);
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              elevation:
                                                                                  MaterialStateProperty.all(8),
                                                                              surfaceTintColor:
                                                                                  MaterialStateProperty.all(Colors.white),
                                                                              backgroundColor:
                                                                                  MaterialStateProperty.all(Colors.white),
                                                                            ),
                                                                            child:
                                                                                const Text(
                                                                              "Aceptar",
                                                                              style:
                                                                                  TextStyle(
                                                                                color: Color.fromRGBO(0, 106, 252, 1.000),
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible:
                                                                          _selectedItem ==
                                                                              'Yape o plin',
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          TextFormField(
                                                                            controller:
                                                                                _telefono,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintText:
                                                                                  'Ingrese su numero de telefono',
                                                                              border:
                                                                                  InputBorder.none,
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null ||
                                                                                  value.isEmpty) {
                                                                                return 'Por favor, ingrese su numero';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              /*    print("-----YAPE-");
                                                                              print("Provider");
                                                                              print("${userProvider.user?.id}");
                                                                             print("${userProvider.user?.frecuencia}");
                                                                              print("${userProvider.user?.codigocliente}");
                                                                             print("${userProvider.user?.sexo}");
                                                                              print("${userProvider.user?.suscripcion}");
                                                                             print("${userProvider.user?.fechaCreacionCuenta}");
                                                                             print("${_selectedItem}");
                                                                             print("${_otroItem}");
                                                                             print("${_cuenta.text}");*/
              
                                                                              actualizarProviderCliente(
                                                                                  userProvider.user?.id,
                                                                                  userProvider.user?.nombre,
                                                                                  userProvider.user?.apellidos,
                                                                                  userProvider.user?.saldoBeneficio,
                                                                                  userProvider.user?.codigocliente,
                                                                                  userProvider.user?.fechaCreacionCuenta,
                                                                                  userProvider.user?.sexo,
                                                                                  userProvider.user?.frecuencia,
                                                                                  userProvider.user?.suscripcion,
                                                                                  _selectedItem,
                                                                                  null,
                                                                                  _telefono.text);
                                                                              telefono_ =
                                                                                  _telefono.text;
                                                                              _telefono.text =
                                                                                  '';
                                                                              Navigator.of(context).pop();
                                                                              _showThankYouDialog(context);
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              elevation:
                                                                                  MaterialStateProperty.all(8),
                                                                              surfaceTintColor:
                                                                                  MaterialStateProperty.all(Colors.white),
                                                                              backgroundColor:
                                                                                  MaterialStateProperty.all(Colors.white),
                                                                            ),
                                                                            child:
                                                                                const Text(
                                                                              "Aceptar",
                                                                              style:
                                                                                  TextStyle(
                                                                                color: Color.fromRGBO(0, 106, 252, 1.000),
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all(1),
                                              minimumSize:
                                                  MaterialStatePropertyAll(Size(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.28,
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.01)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      const Color.fromRGBO(
                                                          0, 106, 252, 1.000)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Retirar dinero",
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.02,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: largoActual * (80 / 760),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        //color: Colors.amberAccent,
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      child: Lottie.asset(
                                          'lib/imagenes/billetera1.json'),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
              
              
                    */
                //SizedBox(height: largoActual * 0.03),

                //CONFIGURACION
                /*
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.045),
                          child: Text(
                            "Configuración",
                            style: TextStyle(
                                color: colorTitulos,
                                fontWeight: FontWeight.w600,
                                fontSize: largoActual * (16 / 760)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: estaHabilitado
                              ? () {
                                  //aca se debe ver la info de notificaciones del cliente
                                }
                              : null,
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize:
                                const MaterialStatePropertyAll(Size(350, 38)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 221, 221, 221)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    color: colorInhabilitado,
                                    size: anchoActual * 0.065,
                                  ),
                                  SizedBox(
                                    width: anchoActual * 0.025,
                                  ),
                                  Text(
                                    'Muy pronto',
                                    //'Notificaciones',
                                    style: TextStyle(
                                        color: colorInhabilitado,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.018),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_right_rounded,
                                color: colorInhabilitado,
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: estaHabilitado
                              ? () {
                                  //aca se puede va a implementar el libro de reclamaciones
                                }
                              : null,
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize:
                                const MaterialStatePropertyAll(Size(350, 38)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 221, 221, 221)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    size: anchoActual * 0.065,
                                    color: colorInhabilitado,
                                  ),
                                  SizedBox(
                                    width: anchoActual * 0.025,
                                  ),
                                  Text(
                                    'Muy pronto',
                                    //'Libro de reclamaciones',
                                    style: TextStyle(
                                        color: colorInhabilitado,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.018),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_right_rounded,
                                color: colorInhabilitado,
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: estaHabilitado
                              ? () {
                                  //aca se puede agregar la informacion de la tienda
                                }
                              : null,
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize:
                                const MaterialStatePropertyAll(Size(350, 38)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 221, 221, 221)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.storefront_rounded,
                                    size: anchoActual * 0.065,
                                    color: colorInhabilitado,
                                  ),
                                  SizedBox(
                                    width: anchoActual * 0.025,
                                  ),
                                  Text(
                                    'Muy pronto',
                                    //'Registra tu tienda',
                                    style: TextStyle(
                                        color: colorInhabilitado,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.018),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_right_rounded,
                                color: colorInhabilitado,
                              )
                            ],
                          ),
                        ),
                        //CERRAR SESION
                        ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove('user');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Solvida()),
                            );
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize:
                                const MaterialStatePropertyAll(Size(350, 38)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outlined,
                                    size: anchoActual * 0.065,
                                    color: colorLetra,
                                  ),
                                  SizedBox(
                                    width: anchoActual * 0.025,
                                  ),
                                  Text(
                                    'Cerrar sesion',
                                    style: TextStyle(
                                        color: colorLetra,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.018),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.exit_to_app_rounded,
                                color: colorLetra,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    */
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.085,
              ),
              Container(
                  child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('user');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Solvida()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Borde recto (sin radio)
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15), // Ajuste del tamaño del botón
                  backgroundColor: Colors.blue, // Color de fondo del botón
                ),
                child: Text(
                  'Cerrar sesión',
                  style: GoogleFonts.poppins(
                      fontSize: largoActual * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              )),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.085,
              ),
            ]),
          )),
        ));
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gracias'),
          content: const Text(
              'Se realizará el depósito mediante el método de pago que eligió dentro del plazo de una semana'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/*import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  State<PerfilCliente> createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  late UserModel clienteUpdate;
  Color colorTitulos = const Color.fromARGB(255, 3, 34, 60);
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorInhabilitado = const Color.fromARGB(255, 130, 130, 130);
  bool estaHabilitado = false;
  String mensajeBanco = 'Numero de celular, cuenta o CCI';
  List<String> mediosString = ['Yape', 'Plin', 'Transferencia'];
  List<String> bancosString = ['BCP', 'BBVA', 'Caja Arequipa', 'Otros'];
  bool esYape = false;
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _cuenta = TextEditingController();
  String telefono_ = '';
  String cuenta_ = '';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCliente = '/api/cliente/';
  DateTime fechaLimite = DateTime.now();
  TextEditingController numeroDeCuenta = TextEditingController();
  String numrecargas = '';
  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      //print('es string');
      return DateTime.parse(fecha);
    } else {
      //print('no es string');
      return DateTime.now();
    }
  }

  Future<dynamic> recargas(clienteID) async {
  try {
    var res = await http.get(
      Uri.parse(apiUrl + '/api/cliente/recargas/' + clienteID.toString()),
      headers: {"Content-type": "application/json"},
    );
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      if (data != null) {
        if (mounted) {
          setState(() {
            numrecargas = data['recargas'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            numrecargas = '0';
          });
        }
      }
    }
  } catch (e) {
    throw Exception('Error en la solicitud: $e');
  }
}


  Future<dynamic> updateCliente(saldoBeneficios, suscripcion, frecuencia,
      quiereretirar, clienteID, medioretiro, bancoretiro, numerocuenta) async {
    print("2.- UPDAE CLEINTE---");

    print("cliente----------------------------------------------");
    print(clienteID);
    print("end point URI------------------------------------------------");
    print(apiUrl + apiCliente + clienteID.toString());
    print("quiereretirar");
    print(quiereretirar);
    print("saldo bene");
    print(saldoBeneficios);
    print("frencua............");
    print(frecuencia);
    await http.put(Uri.parse(apiUrl + apiCliente + clienteID.toString()),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "saldo_beneficios": saldoBeneficios,
          "suscripcion": suscripcion,
          "frecuencia": frecuencia,
          "quiereretirar": quiereretirar,
          "medio_retiro": medioretiro,
          "banco_retiro": bancoretiro,
          "numero_cuenta": numerocuenta
        }));
  }

  void actualizarProviderCliente(
      clienteid,
      name,
      lastname,
      saldo,
      codigo,
      fechaCreacion,
      sexo,
      frecuencia,
      suscrip,
      medioretiro,
      bancoretiro,
      numerocuenta) async {
      //  print("1 .- ---actualizar Provider");

    clienteUpdate = UserModel(
        id: clienteid,
        nombre: name,
        apellidos: lastname,
        saldoBeneficio: saldo,
        codigocliente: codigo,
        fechaCreacionCuenta: fechaCreacion,
        sexo: sexo,
        frecuencia: frecuencia,
        quiereRetirar: true,
        suscripcion: suscrip,
        rolid: 4);
       // print("${clienteUpdate}");

    Provider.of<UserProvider>(context, listen: false).updateUser(clienteUpdate);

    await updateCliente(saldo, suscrip, frecuencia, true, clienteid,
        medioretiro, bancoretiro, numerocuenta);
  }
  
  @override
  void initState(){
    super.initState();
    final userProvider = context.read<UserProvider>();
    final idcliente = userProvider.user?.id;
    recargas(idcliente);
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    //TYJYUJY
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
      /*appBar: AppBar(
        backgroundColor: Colors.white,
      ),*/
      child: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(anchoActual * 0.04),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: largoActual*0.02,),
              Row(
                children: [
                  //FOTO DEL CLIENTE
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.035),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 220, 220, 220),
                        borderRadius: BorderRadius.circular(50)),
                    height: largoActual * 0.085,
                    width: anchoActual * 0.18,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      //poner un if por aqui por si es hombre o mujer
                      child: userProvider.user?.sexo == 'Femenino'
                          ? Icon(
                              Icons.face_3_rounded,
                              color: colorTitulos,
                              size: anchoActual * 0.14,
                            )
                          : Icon(
                              Icons.face_6_rounded,
                              color: colorTitulos,
                              size: anchoActual * 0.14,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: anchoActual * 0.05,
                  ),

                  SizedBox(
                    width: anchoActual * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Nombre
                        Text(
                          '${userProvider.user?.nombre} ${userProvider.user?.apellidos}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: largoActual * 0.023,
                              color: colorTitulos),
                        ),
                        //Correo
                        Text(
                          'Codigo: ${userProvider.user?.codigocliente}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: largoActual * 0.02,
                              color: colorTitulos),
                        ),
                        //Numero
                        Text(
                          '${userProvider.user?.suscripcion}',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: largoActual * 0.018,
                              color: colorTitulos),
                        ),
                      ],
                    ),
                  ), /*
                  */
                ],
              ),
              SizedBox(height: largoActual*0.02,),
              //CARDS DE INFOPERSONAL MEMBRE SOL CUPONES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierColor: Colors.grey.withOpacity(0.41),
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      padding: EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30)
                                      ),
                                      child: Container(
                                        
                                        width: MediaQuery.of(context).size.width/1.3,
                                        height: MediaQuery.of(context).size.width/1.3,
                                        decoration: BoxDecoration(
                                          
                                          borderRadius: BorderRadius.circular(30),
                                          image: DecorationImage(
                                            image:NetworkImage('$apiUrl/images/sorteoviaje.png'),
                                            fit: BoxFit.cover
                                             )
                                        ),
                                        //child: Image.network('$apiUrl/images/sorteoviaje.png'),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Row(
                            children: [
                              Container(
                                  //color: Colors.amber,
                                  padding:
                                      EdgeInsets.only(left: anchoActual * 0.04),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: "${numrecargas}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: largoActual * 0.06,
                                        color: colorTitulos,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "\nRecargas",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.016,
                                          color: colorTitulos,
                                          height: 0.2),
                                    ),
                                    TextSpan(
                                      text: "\nu oportunidades",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: largoActual * 0.016,
                                          color: colorTitulos),
                                    ),
                                      TextSpan(
                                      text: "\nPulsa aquí.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: largoActual * 0.016,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ]))),
                                  SizedBox(width: anchoActual*0.034,),
                              Container(
                                height: largoActual * 0.08,
                                width: anchoActual * 0.24,
                                //color: Colors.grey,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  /*gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(
                                                              150, 198, 230, 1),
                                                          Colors.white,
                                                          Colors.white,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),*/
                                  //color: Colors.transparent,
                                  image:const DecorationImage(
                                    image: AssetImage('lib/imagenes/playa.jpg'),
                                    fit: BoxFit.cover,
                                    opacity: 0.69,
                                    )
                                ),
                                /*child: Lottie.asset(
                                  'lib/imagenes/Animation - 1718738830493.json',
                                ),*/
                              ),
                            ],
                          )),
                    ),
                  ),

                  //CARD DE INFO PERSONAL
                  Expanded(
                    flex: 1,
                    child: Card(
                        margin: EdgeInsets.only(left: anchoActual * 0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        //surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        child: Container(
                          margin: EdgeInsets.all(anchoActual * 0.02),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  //ACA ACCIONES
                                },
                                icon: Icon(
                                  Icons.person_2_outlined,
                                  color: colorLetra,
                                  size: anchoActual * 0.11,
                                ),
                              ),
                              Text(
                                'Info. Personal',
                                style: TextStyle(
                                    color: colorLetra,
                                    fontWeight: FontWeight.w400,
                                    fontSize: largoActual * 0.015),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(height: largoActual*0.03,),
              //BILLETERA SOL
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.045),
                    child: Text(
                      "Billetera Sol",
                      style: TextStyle(
                          color: colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: largoActual * (16 / 760)),
                    ),
                  ),
                  SizedBox(
                    height: largoActual * 0.17,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        surfaceTintColor: Color.fromRGBO(246, 224, 128, 1.000),
                        color: Colors.white,
                        elevation: 8,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: anchoActual * 0.1,
                            right: anchoActual * 0.1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'S/. ${userProvider.user?.saldoBeneficio}0',
                                    style: TextStyle(
                                        color: colorLetra,
                                        fontWeight: FontWeight.w700,
                                        fontSize: largoActual * 0.045),
                                  ),
                                  Text(
                                    'Retíralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                    style: TextStyle(
                                        color: colorLetra,
                                        fontWeight: FontWeight.w400,
                                        fontSize: largoActual * 0.016),
                                  ),
                                  SizedBox(
                                    height: largoActual * 0.01,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        (168 / 375),
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String _selectedItem =
                                                'Seleccione su método';
                                            String _otroItem =
                                                'Ingrese su banco';
                                            return Dialog(
                                              child: StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(0, 106,
                                                              252, 1.000),
                                                          Color.fromRGBO(
                                                              150, 198, 230, 1),
                                                          Colors.white,
                                                          Colors.white,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Selecciona el método que prefieras',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.028,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          Column(
                                                            children: [
                                                              DropdownButtonFormField<
                                                                  String>(
                                                                onChanged: (String?
                                                                    newValue) {
                                                                  setState(() {
                                                                    _selectedItem =
                                                                        newValue!;
                                                                    /*print(
                                                                        'valor: $_selectedItem');*/
                                                                  });
                                                                },
                                                                value:
                                                                    _selectedItem,
                                                                items: <String>[
                                                                  'Seleccione su método',
                                                                  'Transferencia',
                                                                  'Yape o plin',
                                                                ].map<
                                                                    DropdownMenuItem<
                                                                        String>>((String
                                                                    value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    _selectedItem ==
                                                                        'Transferencia',
                                                                child: Column(
                                                                  children: [
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                      onChanged:
                                                                          (String?
                                                                              newValue) {
                                                                        setState(
                                                                            () {
                                                                          _otroItem =
                                                                              newValue!;
                                                                        });
                                                                      },
                                                                      value:
                                                                          _otroItem,
                                                                      items:
                                                                          <String>[
                                                                        'Ingrese su banco',
                                                                        'BBVA',
                                                                        'BCP',
                                                                        'Caja Arequipa',
                                                                        'Otros',
                                                                      ].map<DropdownMenuItem<String>>((String
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child:
                                                                              Text(value),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                    TextFormField(
                                                                      controller:
                                                                          _cuenta,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        hintText:
                                                                            'Ingrese su numero de cuenta',
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Por favor, ingrese su numero de cuenta';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                          /*  print("-----N CUENTA BANCO-");
                                                                            print("Provider");
                                                                            print("${userProvider.user?.id}");
                                                                           print("${userProvider.user?.frecuencia}");
                                                                            print("${userProvider.user?.codigocliente}");
                                                                           print("${userProvider.user?.sexo}");
                                                                            print("${userProvider.user?.suscripcion}");
                                                                           print("${userProvider.user?.fechaCreacionCuenta}");
                                                                           print("${_selectedItem}");
                                                                           print("${_otroItem}");
                                                                           print("${_cuenta.text}");*/

                                                                        actualizarProviderCliente(
                                                                            userProvider.user?.id,
                                                                            userProvider.user?.nombre,
                                                                            userProvider.user?.apellidos,
                                                                            userProvider.user?.saldoBeneficio,
                                                                            userProvider.user?.codigocliente,
                                                                            userProvider.user?.fechaCreacionCuenta,
                                                                            userProvider.user?.sexo,
                                                                            userProvider.user?.frecuencia,
                                                                            userProvider.user?.suscripcion,
                                                                            _selectedItem,
                                                                            _otroItem,
                                                                            _cuenta.text);
                                                                        cuenta_ =
                                                                            _cuenta.text;
                                                                        _cuenta.text =
                                                                            '';
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _showThankYouDialog(
                                                                            context);
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        elevation:
                                                                            MaterialStateProperty.all(8),
                                                                        surfaceTintColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Aceptar",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000),
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    _selectedItem ==
                                                                        'Yape o plin',
                                                                child: Column(
                                                                  children: [
                                                                    TextFormField(
                                                                      controller:
                                                                          _telefono,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        hintText:
                                                                            'Ingrese su numero de telefono',
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Por favor, ingrese su numero';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {

                                                                         /*    print("-----YAPE-");
                                                                            print("Provider");
                                                                            print("${userProvider.user?.id}");
                                                                           print("${userProvider.user?.frecuencia}");
                                                                            print("${userProvider.user?.codigocliente}");
                                                                           print("${userProvider.user?.sexo}");
                                                                            print("${userProvider.user?.suscripcion}");
                                                                           print("${userProvider.user?.fechaCreacionCuenta}");
                                                                           print("${_selectedItem}");
                                                                           print("${_otroItem}");
                                                                           print("${_cuenta.text}");*/

                                                                        actualizarProviderCliente(
                                                                            userProvider.user?.id,
                                                                            userProvider.user?.nombre,
                                                                            userProvider.user?.apellidos,
                                                                            userProvider.user?.saldoBeneficio,
                                                                            userProvider.user?.codigocliente,
                                                                            userProvider.user?.fechaCreacionCuenta,
                                                                            userProvider.user?.sexo,
                                                                            userProvider.user?.frecuencia,
                                                                            userProvider.user?.suscripcion,
                                                                            _selectedItem,
                                                                            null,
                                                                            _telefono.text);
                                                                        telefono_ =
                                                                            _telefono.text;
                                                                        _telefono.text =
                                                                            '';
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        _showThankYouDialog(
                                                                            context);
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        elevation:
                                                                            MaterialStateProperty.all(8),
                                                                        surfaceTintColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "Aceptar",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000),
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(1),
                                        minimumSize: MaterialStatePropertyAll(
                                            Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.28,
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01)),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    0, 106, 252, 1.000)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Retirar dinero",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: largoActual * (80 / 760),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  //color: Colors.amberAccent,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Lottie.asset(
                                    'lib/imagenes/billetera1.json'),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(height: largoActual*0.03,),
              //CONFIGURACION
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: anchoActual * 0.045),
                    child: Text(
                      "Configuración",
                      style: TextStyle(
                          color: colorTitulos,
                          fontWeight: FontWeight.w600,
                          fontSize: largoActual * (16 / 760)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se debe ver la info de notificaciones del cliente
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: colorInhabilitado,
                              size: anchoActual * 0.065,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Notificaciones',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se puede va a implementar el libro de reclamaciones
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: anchoActual * 0.065,
                              color: colorInhabilitado,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Libro de reclamaciones',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: estaHabilitado
                        ? () {
                            //aca se puede agregar la informacion de la tienda
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 221, 221, 221)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: anchoActual * 0.065,
                              color: colorInhabilitado,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Muy pronto',
                              //'Registra tu tienda',
                              style: TextStyle(
                                  color: colorInhabilitado,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: colorInhabilitado,
                        )
                      ],
                    ),
                  ),
                  //CERRAR SESION
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('user');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Solvida()),
                      );
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      surfaceTintColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(350, 38)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              size: anchoActual * 0.065,
                              color: colorLetra,
                            ),
                            SizedBox(
                              width: anchoActual * 0.025,
                            ),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                  color: colorLetra,
                                  fontWeight: FontWeight.w400,
                                  fontSize: largoActual * 0.018),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.exit_to_app_rounded,
                          color: colorLetra,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ]),
      )),
    ));
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gracias'),
          content:const Text(
              'Se realizará el depósito mediante el método de pago que eligió dentro del plazo de una semana'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
*/