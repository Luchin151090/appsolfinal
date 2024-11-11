/*import 'dart:convert';

import 'package:appsol_final/components/conductorinit.dart';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:appsol_final/provider/residuosprovider.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'firebase_options.dart';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:upgrader/upgrader.dart';

late List<CameraDescription> camera;
//late SocketService socketService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  //await Upgrader.clearSavedSettings();
  //print("userJson main ---------------------------------");
  //print(userJson);
  bool estalogeado = userJson != null; //false = nologeado, true = logeado
  //print("estalogeado------------------------");
  //print(estalogeado);
  var prueba = UserModel();
  //print(prueba.rolid);
  //prefs.remove('user');
  int rol = 0;
  if (estalogeado == true) {
    rol = jsonDecode(userJson!)['rolid'];
  }
  //print(rol);
  await dotenv.load(fileName: ".env");
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/

  // Inicializamos el UserProvider y cargamos el usuario
  UserProvider userProvider = UserProvider();
  await userProvider.initUser();

    // Inicializar el servicio de Socket.IO
 // SocketService();
  // Inicializamos el servicio de Socket.IO
  SocketService socketService = SocketService();

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => PedidoProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionListProvider()),
        ChangeNotifierProvider(create: (context) => RutaProvider()),
        ChangeNotifierProvider(create: (context) => CardpedidoProvider()),
        ChangeNotifierProvider(create: (context) => ResiduoProvider()),
        ChangeNotifierProvider(create: (context) => PedidoconductorProvider()),
       // ChangeNotifierProvider(create: (context) => SocketService())
        Provider<SocketService>.value(value: socketService), // Proveer el SocketService aquí
      ],
      child: MyApp(estalogeado: estalogeado, rol: rol),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool estalogeado;
  final int rol;
  const MyApp({Key? key, required this.estalogeado, required this.rol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', ''), // Español
        ],
        //home: estalogeado && rol == 4 ? BarraNavegacion(indice: 0,subIndice: 0,) : (estalogeado && rol == 5 ? HolaConductor() :Login()),
        home: UpgradeAlert(
          
          child: estalogeado
              ? (rol == 4
                  ? const BarraNavegacion(
                      indice: 0,
                      subIndice: 0,
                    )
                  : (rol == 5 ? const Driver() : const Solvida()))
              : const Solvida(),
        ),
      
    );
  }
}
*/
import 'dart:convert';

import 'package:appsol_final/components/conductorinit.dart';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/newdriver.dart';
import 'package:appsol_final/components/preinicios.dart';
import 'package:appsol_final/components/socketcentral/socketcentral.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/card_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/pedidoruta_provider.dart';
import 'package:appsol_final/provider/residuosprovider.dart';
import 'package:appsol_final/provider/ruta_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/provider/ubicaciones_list_provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';

late List<CameraDescription> camera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  bool estalogeado = userJson != null;
  int rol = 0;

  if (estalogeado) {
    rol = jsonDecode(userJson)['rolid'];
  }

  await dotenv.load(fileName: ".env");

  // Inicializamos el UserProvider y cargamos el usuario
  UserProvider userProvider = UserProvider();
  await userProvider.initUser();

  // Inicializamos el servicio de Socket.IO
  SocketService socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider(create: (context) => PedidoProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionProvider()),
        ChangeNotifierProvider(create: (context) => UbicacionListProvider()),
        ChangeNotifierProvider(create: (context) => RutaProvider()),
        ChangeNotifierProvider(create: (context) => CardpedidoProvider()),
        ChangeNotifierProvider(create: (context) => ResiduoProvider()),
        ChangeNotifierProvider(create: (context) => PedidoconductorProvider()),
        Provider<SocketService>.value(value: socketService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 917), // Tamaño de diseño base (puedes ajustar según tu diseño)
      minTextAdapt: true, // Para adaptar el texto automáticamente
      splitScreenMode: true, // Para soportar split screen
      
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', ''), // Español
          ],
          home: const MainAppScreen(),
        );
      },
    );
  }
}
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool isLoading = true; // Estado de carga inicial
  bool estalogeado = false;
  int rol = 0;
  late PackageInfo packageInfo;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPackageInfo();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    setState(() {
      estalogeado = userJson != null;
      if (estalogeado) {
        rol = jsonDecode(userJson!)['rolid'];
      }
      isLoading = false; // Cambia el estado de carga
    });
  }

  Future<void> _loadPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child:
              CircularProgressIndicator()); // Muestra un indicador de carga mientras se obtienen los datos
    }

    // Compara la versión actual con la versión mínima requerida
    const minVersion = '3.2.0';
    final showUpgradeAlert = _compareVersions(currentVersion, minVersion) < 0;

    Widget mainContent = estalogeado
        ? (rol == 4
            ? const BarraNavegacion(
                indice: 0,
                subIndice: 0,
              )
            : (rol == 5 ? const Driver() : const Solvida()))
        : const Solvida();

    if (showUpgradeAlert) {
      return UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(days: 1),
          countryCode: 'PE',
          debugDisplayAlways: false,
          debugLogging: true,
          messages: SpanishMessages(),
          minAppVersion: minVersion,
        ),
        child: mainContent, // Usa el contenido principal de la app aquí
      );
    } else {
      return mainContent;
    }
  }

  // Función para comparar versiones
  int _compareVersions(String v1, String v2) {
    try {
      final v1Parts = v1.split('.').map(int.parse).toList();
      final v2Parts = v2.split('.').map(int.parse).toList();
      final length =
          [v1Parts.length, v2Parts.length].reduce((a, b) => a > b ? a : b);

      for (int i = 0; i < length; i++) {
        final part1 = i < v1Parts.length ? v1Parts[i] : 0;
        final part2 = i < v2Parts.length ? v2Parts[i] : 0;
        if (part1 != part2) {
          return part1.compareTo(part2);
        }
      }
      return 0;
    } catch (e) {
      // Manejo de error en caso de que el formato de la versión sea inválido
      print('Error al comparar versiones: $e');
      return 0; // Considerar como la misma versión en caso de error
    }
  }
}

class SpanishMessages extends UpgraderMessages {
  @override
  String get title => 'Actualización disponible';

  @override
  String get body =>
      '¿Deseas actualizar la aplicación a la versión más reciente?';

  @override
  String get prompt => 'Por favor actualiza ahora.';

  @override
  String get buttonTitleUpdate => 'Actualizar Ahora';

  @override
  String get buttonTitleIgnore => 'No ahora';

  @override
  String get buttonTitleLater => 'Más tarde';

  @override
  String get releaseNotes => 'Notas de la versión';
}
