import 'package:appsol_final/components/newregistroelegir.dart';
import 'package:appsol_final/components/preregistro.dart';
import 'package:appsol_final/components/prelogin.dart';
import 'package:appsol_final/components/responsiveUI/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:solvida/componentes/responsiveUI/breakpoint.dart';

class Solvida extends StatefulWidget {
  const Solvida({super.key});

  @override
  State<Solvida> createState() => _SolvidaState();
}

class _SolvidaState extends State<Solvida> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(61, 85, 212, 1),
                /* gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Colors.blue,
                   // const Color(0xFF3179D2),
                  
                ),*/

                image: DecorationImage(
                  image: AssetImage('lib/imagenes/aguamarina2.png'),
                  fit: BoxFit
                      .cover, // Cambiado a BoxFit.cover para que cubra todo el Container
                ),
              ),
            ),
            Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 128.h,
                ),
                // IMAGENES
                Center(
                    child: Container(
                  width: 156.w,
                  height: 127.h, //MediaQuery.of(context).size.height/3,
                  decoration: const BoxDecoration(
                    //color: Colors.grey,
                    image: DecorationImage(
                      image: AssetImage('lib/imagenes/nuevito.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                )),
                SizedBox(
                  height: 84.h,
                ),
                Center(
                  child: Text('Bienvenido a la gran',
                      style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                Center(
                  child: Text(
                    "familia SOL VIDA",
                    style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 32.h,
                ),
                Container(
                  height: 63.h,
                  width: 330.w,
                  //color: Colors.grey,
                  child: Text(
                    "Descubre todas nuestras \nnovedades",
                    
                    style: GoogleFonts.poppins(
                     
                        fontSize: 19.sp,
                        letterSpacing: 0.05*20.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fade(duration: 1500.ms).slideY(),
                SizedBox(
                  height: 48.h,
                ),
                // BOTONES

                Container(
                  width: 331.w,
                  height: 39.h,
                 // color: Colors.grey,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Prelogin()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 77, 255, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r))),
                      child: Text(
                        "Iniciar sesión",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      )),
                ).animate().fade(delay: 0.9.ms).slideY(),
                SizedBox(
                  height: 26.h,
                ),
                Container(
                 width: 331.w,
                  height: 39.h,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Registroelegir() //Formucli()
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r))),
                      child: Text(
                        "Registrarse",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: const Color.fromRGBO(0, 77, 255, 1),
                            fontWeight: FontWeight.w600),
                      )),
                ).animate().fade(delay: 0.9.ms).slideY(),

                SizedBox(
                  height: 80.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
