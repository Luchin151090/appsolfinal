import 'package:appsol_final/components/responsiveUI/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:appsol_final/components/prelogin.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:intl/intl.dart';
//import 'package:solvida/componentes/responsiveUI/breakpoint.dart';
//import 'breakpoint.dart';

class Formucli extends StatefulWidget {
  const Formucli({super.key});

  @override
  State<Formucli> createState() => _FormucliState();
}

//copia del archivo original
class _FormucliState extends State<Formucli> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nombres = TextEditingController();
  final TextEditingController _apellidos = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  bool _obscureText = true;
  String? selectedSexo;
  List<String> sexos = ['Masculino', 'Femenino'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCreateUser = '/api/user_cliente';
  int status = 0;
  DateTime tiempoActual = DateTime.now();

  //final _formKey = GlobalKey<FormState>();

//FUTURE DEL ARCHIVO ORIGINAL

  Future<dynamic> registrar(nombre, apellidos, dni, fechaAct, nickname,
      contrasena, email, telefono) async {
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

    try {
      // Parsear la fecha de nacimiento a DateTime
      //DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fecha);

      // Formatear la fecha como una cadena en el formato deseado (por ejemplo, 'yyyy-MM-dd')
      //String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);
      String fechaActual = DateFormat('yyyy-MM-dd').format(fechaAct);
      print(".........");
      print(
          "${nickname},${contrasena},$email,$nombre,$apellidos,$telefono,$fechaAct}");
      var res = await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email,
            "nombre": nombre,
            "apellidos": apellidos,
            "telefono": telefono,
            "ruc": "NA",
            "dni": dni ?? "NA",
            "fecha_nacimiento": fechaActual,
            "fecha_creacion_cuenta": fechaActual,
            "sexo": "NA",
            "direccion_empresa": "NA",
            "suscripcion": "Básico",
            "nombre_empresa": "NA",
            "frecuencia": "NA",
            "quiereretirar": false,
            "medio_retiro": "NA",
            "banco_retiro": "NA",
            "numero_cuenta": "NA"
          }));
      print("res----");
      print(res.body);
      if (res.statusCode == 200) {
        setState(() {
          status = 200;
        });
      } else if (res.statusCode == 401) {
        setState(() {
          status = 401;
        });
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // MAIN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'lib/imagenes/aguamarina2.png', // Asegúrate de tener la imagen en la carpeta assets y agregarla en pubspec.yaml
            fit: BoxFit.cover,
          ),
        ),
        //Text("${tama} ${MediaQuery.of(context).size.width}}"),
        Container(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*  Container(
                      height: 100,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('lib/imagenes/nuevito.png'))),
                    ),*/
                    SizedBox(height: 94.h),
                    Text(
                      'Regístrate y sorprendete',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16.sp),

                    Text(
                      'Vive bien, vive sano',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 25.sp),
                    // FORMULARIO
                    Container(
                      height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r)),
                      child: TextFormField(
                        controller: _nombres,
                        decoration: InputDecoration(
                          labelText: 'Nombres',

                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                          hintText: 'Ingrese sus nombres',
                          isDense: true,
                          border: InputBorder.none,
                          //filled: true,
                          //fillColor: Colors.white.withOpacity(1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r)),
                      child: TextFormField(
                        controller: _apellidos,
                        decoration: InputDecoration(
                          labelText: 'Apellidos',

                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                          hintText: 'Ingrese sus apellidos',
                          isDense: true,
                          border: InputBorder.none,
                          //filled: true,
                          //fillColor: Colors.white.withOpacity(1),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: Colors.white),
                      child: TextFormField(
                        controller: _telefono,
                        maxLength: 9,
                        decoration: InputDecoration(
                            labelText: 'Teléfono',
                             labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                            hintText: 'Ingrese su número',
                            isDense: true,
                            border: InputBorder.none,
                            //filled: true,
                            counterText: ''
                            //fillColor: Colors.white.withOpacity(0.8),
                            ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es obligatorio';
                              }
                              if (value.length != 9) {
                                return 'El número debe tener 9 dígitos';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Solo se permiten números';
                              }
                              return null;
                            },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r)),
                      child: TextFormField(
                        controller: _dni,
                        decoration:  InputDecoration(
                          labelText: 'DNI(Opcional)',
                           labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                          hintText: 'Ingrese su DNI',
                          isDense: true,
                          border: InputBorder.none,
                          //filled: true,
                          //fillColor: Colors.white.withOpacity(1),
                        ),
                        /*validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  }
                                  return null;
                                },*/
                      ),
                    ),
                    //const SizedBox(height: 4),
                    /*DropdownButtonFormField<String>(
                                    value: selectedSexo,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSexo = value;
                                      });
                                    },
                                    items: sexos.map((sexo) {
                                      return DropdownMenuItem<String>(
                                        value: sexo,
                                        child: Text(sexo),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Sexo',
                                      labelStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 43, 48, 170),
                                      ),
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 43, 48, 170),
                                      ),
                                      //hintText: 'Ingrese sus Apellidos',
                                      isDense: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      //fillColor: Colors.white.withOpacity(1),
                                    ),
                                  ),*/
                    SizedBox(height: 20.h),
                    /*TextFormField(
                                    readOnly: true,
                                    controller: _fechaController,
                                    onTap: () async {
                                      // Abre el selector de fechas cuando se hace clic en el campo
                                      DateTime? fechaSeleccionada =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime(2101),
                                      );
                
                                      if (fechaSeleccionada != null) {
                                        // Actualiza el valor del campo de texto con la fecha seleccionada
                                        _fechaController.text =
                                            "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
                                      }
                                    },
                                    //keyboardType: TextInputType.datetime,
                
                                    decoration: InputDecoration(
                                      labelText: 'Fecha nacimiento',
                                      labelStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 43, 48, 170),
                                      ),
                                      hintStyle: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 43, 48, 170),
                                      ),
                                      hintText: 'Fecha nacimiento',
                                      isDense: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      //fillColor: Colors.white.withOpacity(1),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El campo es obligatorio';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.datetime,
                                    keyboardAppearance: Brightness.light,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),*/
                    //const SizedBox(height: 4),
                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: Colors.white),
                      child: TextFormField(
                        controller: _email,
                        decoration:  InputDecoration(
                            labelText: 'E-mail(Opcional)',
                             labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                            hintText: 'Ingresa su email',
                            isDense: true,
                            border: InputBorder.none
                            //filled: true,
                            //fillColor: Colors.white.withOpacity(0.8),
                            ),
                        keyboardType: TextInputType.emailAddress,
                        /* validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El campo es obligatorio';
                                  } else if (value != null &&
                                      !(value.contains('@gmail.com') ||
                                          value.contains('@hotmail.com'))) {
                                    return 'No es un correo válido';
                                  }
                                  return null;
                                },*/
                      ),
                    ),
                   SizedBox(height: 20.h),
                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: Colors.white),
                      child: TextFormField(
                        controller: _username,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                           labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                          hintText: 'Ingrese su usuario',
                          isDense: true,
                          border: InputBorder.none,
                          //filled: true,
                          //fillColor: Colors.white.withOpacity(1),
                        ),
                        inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[^\s]'),
                                  //RegExp(r'[a-zA-Z0-9]')
                                  ),
                            ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Container(
                       height: 48.h,
                      width: 332.w,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r)),
                      child: TextFormField(
                        controller: _password,
                        keyboardType: TextInputType.visiblePassword,
                        // obscureText:_obscureText,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                           labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 92, 92, 92),
                          ),
                          hintText: 'Ingrese una contraseña',
                          isDense: true,
                          border: InputBorder.none,
                          //filled: true,
                          //fillColor: Colors.white.withOpacity(0.8),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Container(
                       height: 48.h,
                      width: 332.w,
                     
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Process data
                            // sexo,fechanacimiento,ruc
                            await registrar(
                                _nombres.text,
                                _apellidos.text,
                                _dni.text,
                                tiempoActual,
                                _username.text,
                                _password.text,
                                _email.text,
                                _telefono.text);

                            if (status == 200) {
                              Navigator.of(context).pop();
                              // print("----entro al 200");
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            height: 17,
                                          ),
                                          Text(
                                            "¡Registro exitoso!",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: const Color.fromARGB(
                                                    255, 2, 100, 181)),
                                          ),
                                          const SizedBox(
                                            height: 19,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Prelogin()),
                                                );
                                              },
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            23,
                                                    color: const Color.fromARGB(
                                                        255, 4, 93, 167)),
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (status == 401) {
                              // print("entro al 40");
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              4.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            "Intente otro usuario por favor.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: const Color.fromARGB(
                                                    255, 2, 100, 181)),
                                          ),
                                          const SizedBox(
                                            height: 19,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            23,
                                                    color: const Color.fromARGB(
                                                        255, 4, 93, 167)),
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(0, 77, 255, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            )),
                        child: Text(
                          "Registrarse",
                          style: GoogleFonts.poppins(
                              fontSize: 17.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Text('¿Ya tienes cuenta?',
                        style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                   
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Prelogin(),
                                ));
                            // Navegar a la página de inicio de sesión
                          },
                          child: Text(
                            'Inicia sesión',
                            style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(84, 226, 132, 1)),
                          ),
                        ),
                     
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
