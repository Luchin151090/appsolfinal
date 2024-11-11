import 'package:appsol_final/components/newregistroconductor.dart';
import 'package:appsol_final/components/responsiveUI/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:appsol_final/components/preregistro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
class Registroelegir extends StatefulWidget {
  const Registroelegir({super.key});

  @override
  State<Registroelegir> createState() => _RegistroelegirState();
}

class _RegistroelegirState extends State<Registroelegir> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Tamaño de la cuadrícula, puedes ajustar esto según lo que necesites
  final double gridSize = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'lib/imagenes/aguamarina2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Grid de guía (puedes eliminar este widget más tarde)
          /*CustomPaint(
            size: MediaQuery.of(context).size,
            painter: GridPainter(gridSize: gridSize),
          ),*/
          Container(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 267.h),
                Container(
                  width: 156.w,
                  height: 127.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/imagenes/nuevito.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
                Center(
                  child: Text(
                    'Regístrate como',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 50.h),
                Container(
                  width: 331.w,
                  height: 39.h,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Formucli()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r))),
                      child: Text(
                        "Cliente",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 31, 28, 190),
                            fontSize: 18.sp),
                      )),
                ),
                SizedBox(height: 30.h),
                Container(
                  width: 331.w,
                  height: 39.h,
                  child: ElevatedButton(
                      onPressed: () {
                        // Acción para el botón "Conductor"
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 131, 132, 133),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r))),
                      child: Text(
                        "Conductor",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18.sp),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para dibujar el grid
class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 4;

    // Dibuja las líneas horizontales
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dibuja las líneas verticales
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}