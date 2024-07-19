import 'package:appsol_final/components/formulario.dart';
import 'package:appsol_final/components/preregistro.dart';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/prepermisos.dart';
import 'package:appsol_final/components/ubicacion.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl/intl.dart';
import 'package:appsol_final/components/recuperacion.dart';

class Prelogin extends StatefulWidget {
  const Prelogin({super.key});

  @override
  State<Prelogin> createState() => _PreloginState();
}

class _PreloginState extends State<Prelogin> {
  //FUNCION ORIGINAL LOGIN
  bool _obscureText1 = true;
  double opacity = 0.0;
  String apiLogin = '/api/login';
  String apiLastPedido = '/api/pedido_last/';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  late int status = 0;
  late int rol = 0;
  late int id = 0;
  late UserModel userData;
  bool yaTieneUbicaciones = false;
  bool noTienePedidosEsNuevo = false;
  /*final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth __auth = FirebaseAuth.instance;*/
  String apiCreateUser = '/api/user_cliente';
  String rolIdKey = "rol_id";
  String nicknameKey = "nickname";
  String contrasenaKey = "contrasena";
  String emailKey = "email";
  String nombreKey = "nombre";
  String apellidosKey = "apellidos";
  String telefonoKey = "telefono";
  String rucKey = "ruc";
  String dniKey = "dni";
  String fechaNacimientoKey = "fecha_nacimiento";
  String fechaCreacionCuentaKey = "fecha_creacion_cuenta";
  String sexoKey = "sexo";
  String numrecargas = "";

  Future<dynamic> getBidonCliente(clienteID) async {
    try {
      var res = await http.get(
        Uri.parse(apiUrl + '/api/clientebidones/' + clienteID.toString()),
        headers: {"Content-type": "application/json"},
      );
      SharedPreferences bidonCliente = await SharedPreferences.getInstance();

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        // print("data si hay bidon o no");
        //print(data);
        if (data == null) {
          //print("no hay dta");
          setState(() {
            bidonCliente.setBool('comproBidon', false);
          });
        } else {
          //print("si hay data");
          setState(() {
            bidonCliente.setBool('comproBidon', true);
          });
        }
      }
    } catch (e) {
      throw Exception("Error ${e}");
    }
  }

  Future<dynamic> registrar(
      String? nombre,
      String? fecha,
      fechaAct,
      String? nickname,
      String? contrasena,
      String? email,
      String? telefono) async {
    try {
      print("aqui?");
      await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email,
            "nombre": nombre,
            "apellidos": '',
            "telefono": telefono ?? '',
            "ruc": '',
            "dni": '',
            "fecha_nacimiento": fecha,
            "fecha_creacion_cuenta": fechaAct,
            "sexo": ''
          }));
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  void initState() {
    super.initState();
    //getUsers();
    // Iniciar la animación de la opacidad después de 500 milisegundos
    Timer(Duration(milliseconds: 900), () {
      setState(() {
        opacity = 1;
      });
    });
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
          setState(() {
            numrecargas = data['recargas'];
          });
        } else {
          setState(() {
            numrecargas = '0';
          });
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> loginsol(username, password) async {
    try {
      /*print("------loginsool");
      print(username);*/

      var res = await http.post(Uri.parse(apiUrl + apiLogin),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"nickname": username, "contrasena": password}));
      /*print("why");
      print(res);*/
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        // CLIENTE

        if (data['usuario']['rol_id'] == 4) {
          /*print("dentro del cliente");
          print("userDataCopy");*/
          SharedPreferences userDataCopy =
              await SharedPreferences.getInstance();
          userDataCopy.setString('token', data['token']);
          userDataCopy.setInt('idcopy', data['usuario']['id']);
          userDataCopy.setString('nombrecopy', data['usuario']['nombre']);
          userDataCopy.setString('apellidoscopy', data['usuario']['apellidos']);
          userDataCopy.setDouble('saldoBeneficiocopy',
              data['usuario']['saldo_beneficios'].toDouble() ?? 0.00);
          userDataCopy.setString(
              'codigoclientecopy', data['usuario']['codigo'] ?? 'Sin código');
          /*print("codigo-----------------------------");
          print(data['usuario']['codigo']);*/
          userDataCopy.setString('fechaCreacionCuentacopy',
              data['usuario']['fecha_creacion_cuenta']);
          userDataCopy.setString('sexocopy', data['usuario']['sexo']);
          userDataCopy.setString(
              'frecuenciacopy', data['usuario']['frecuencia']);
          userDataCopy.setBool(
              'quiereRetirarcopy', data['usuario']['quiereretirar']);
          userDataCopy.setString('suscripcioncopy',
              data['usuario']['suscripcion'] ?? 'Sin suscripción');
          /*print(userDataCopy);
          print("-----------------------------------------------------------");
          print("cli");
          print("userData");
          // data['usuario']['nombre']
          print(data['usuario']['id']);*/
          await recargas(data['usuario']['id']);
          // await getBidonCliente(data['usuario']['id']);
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos'],
              saldoBeneficio:
                  data['usuario']['saldo_beneficios'].toDouble() ?? 0.00,
              codigocliente: data['usuario']['codigo'] ?? 'Sin código',
              fechaCreacionCuenta: data['usuario']['fecha_creacion_cuenta'],
              sexo: data['usuario']['sexo'],
              frecuencia: data['usuario']['frecuencia'],
              quiereRetirar: data['usuario']['quiereretirar'],
              suscripcion: data['usuario']['suscripcion'] ?? 'Sin suscripción',
              token: data['token'],
              rolid: data['usuario']['rol_id'],
              recargas: numrecargas);
          /*print(userData);
          print("-----------------------------------------------------------");*/
          setState(() {
            status = 200;
            rol = 4;
            id = userData.id!;
          });
        }
        //CONDUCTOR
        else if (data['usuario']['rol_id'] == 5) {
          //print("conductor");
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombres'],
              apellidos: data['usuario']['apellidos'],
              rolid: data['usuario']['rol_id']);

          setState(() {
            status = 200;
            rol = 5;
            id = userData.id!;
          });
        }
        // GERENTE
        else if (data['usuario']['rol_id'] == 3) {
          //print("gerente");
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos'],
              rolid: data['usuario']['rol_id']);

          setState(() {
            status = 200;
            rol = 3;
            id = userData.id!;
          });
        }

        // ACTUALIZAMOS EL ESTADO DEL PROVIDER, PARA QUE SE PUEDA USAR DE MANERA GLOBAL
        Provider.of<UserProvider>(context, listen: false).updateUser(userData);
        SharedPreferences userPreference =
            await SharedPreferences.getInstance();
        userPreference.setInt("userID", id);
        //print(id);
      } else if (res.statusCode == 401) {
        var data400 = json.decode(res.body);
        //print("data400");
        //print(data400);
        setState(() {
          status = 401;
        });
      } else if (res.statusCode == 404) {
        var data404 = json.decode(res.body);
        //print("data 404");
        //print(data404);
        setState(() {
          status = 404;
        });
      } else {
        throw Exception("Codigo de estado desconocido ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Excepcion $e");
    }
  }

  Future<dynamic> tieneUbicaciones(clienteID) async {
    //print("-------get ubicaciones---------");
    //print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        //print("-------entro al try de get ubicaciones---------");
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
              zonaID: mapa['zona_trabajo_id']);
        }).toList();
        setState(() {
          if (tempUbicacion.isEmpty) {
            //print("${tempUbicacion.length}");
            //NOT TIENE UBIS
            yaTieneUbicaciones = false;
          } else {
            //SI TIENE UBISSS
            yaTieneUbicaciones = true;
          }
        });
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> tienePedidos(clienteID) async {
    //print("-------get pedidossss---------");
    var res = await http.get(
      Uri.parse(apiUrl + apiLastPedido + clienteID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        //print("-------entro al try de get pedidossss---------");
        var data = json.decode(res.body);
        //print(data);
        if (data == null) {
          setState(() {
            noTienePedidosEsNuevo = true;
          });
        } else {
          setState(() {
            noTienePedidosEsNuevo = false;
          });
        }
      }
    } catch (e) {
      //print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  //ESTA ES LA VISTA PRINCIPAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 230, 230, 230),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'lib/imagenes/diseño_final_flutter.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage('lib/imagenes/nuevito.png'))),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Inicia Sesión",
                                style: TextStyle(
                                    fontSize: 36,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "Llevando vida a tu hogar!",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextFormField(
                                        controller: _usuario,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        decoration: const InputDecoration(
                                            //necesario para login

                                            labelText: 'Usuario',
                                            hintText: 'Usuario',
                                            border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                            hintStyle: TextStyle(
                                                fontSize: 17,
                                                color: Colors.grey),
                                            prefixIcon: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            )),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, ingrese su usuario';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextFormField(
                                        controller: _contrasena,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText: _obscureText1,
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          hintText: 'Contraseña',
                                          border: InputBorder.none,
                                          labelStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                          hintStyle:const TextStyle(
                                              fontSize: 17, color: Colors.grey),
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _obscureText1 = !_obscureText1;
                                              });
                                            },
                                            child: Icon(
                                              _obscureText1
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        //VALIDACION DE CONTRASEÑA ORIGINAL
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Por favor, ingrese una contraseña';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              //color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 2.2),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Recuperacion()),
                                );
                              },

                              //RECUPERACION DE CONTRASEÑA DEL ARCHIVO ORIGINAL
                              child: Text(
                                "¿Olvidaste contraseña?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              )),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        Center(
                          child: Container(
                            width: 500,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () async {
                                  //INICIAR SESIÓN DEL ARCHIVO ORIGINAL

                                  if (_formKey.currentState!.validate()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          );
                                        });
                                    try {
                                      await loginsol(
                                          _usuario.text, _contrasena.text);

                                      if (status == 200) {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el primer AlertDialog

                                        //SI ES CLIENTE
                                        if (rol == 4) {
                                          await tieneUbicaciones(userData.id);
                                          await tienePedidos(userData.id);
                                          if (noTienePedidosEsNuevo) {
                                            setState(() {
                                              userData.esNuevo = true;
                                            });
                                          } else {
                                            setState(() {
                                              userData.esNuevo = false;
                                            });
                                          }
                                          //SI YA TIENE UBICACIONES INGRESA DIRECTAMENTE A LA BARRA DE AVEGACION
                                          if (yaTieneUbicaciones == true) {
                                            //print("YA tiene unibicaciones");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BarraNavegacion(
                                                          indice: 0,
                                                          subIndice: 0)),
                                            );
                                            //SI NO TIENE UBICACIONES INGRESA A UBICACION
                                          } else {
                                            //print("NO tiene unibicaciones");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LocationPermissionScreen()),
                                            );
                                          }

                                          //SI ES CONDUCTOR
                                        } else if (rol == 5) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HolaConductor()),
                                          );

                                          //SI ES GERENTE
                                        } else if (rol == 3) {
                                          //por cmabiar
                                        }
                                        //SI NO ESTA REGISTRADO
                                      } else if (status == 401) {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el primer AlertDialog

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'lib/imagenes/nuevecito.png'))),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    Text(
                                                      "Credenciales inválidas.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              25,
                                                          color: const Color
                                                              .fromARGB(255, 2,
                                                              100, 181)),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 24,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  4, 93, 167)),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else if (status == 404) {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'lib/imagenes/nuevecito.png'))),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    Text(
                                                      "Usuario no existente. Intente de nuevo.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              25,
                                                          color: const Color
                                                              .fromARGB(255, 2,
                                                              100, 181)),
                                                    ),
                                                    const SizedBox(
                                                      height: 19,
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          "OK",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 24,
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  4, 93, 167)),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    } catch (e) {
                                      /*print(
                                  "Excepción durante el inicio de sesión: $e");*/
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 3, 107, 192),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "¿Todavía no tienes cuenta?",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Formucli()),
                                  );
                                },
                                child: const Text(
                                  "Registrarse",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 208, 255, 1),
                                  ),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}