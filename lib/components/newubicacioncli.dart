/*

import 'package:flutter/material.dart';


class FormUbi extends StatefulWidget {
  const FormUbi({Key? key}) : super(key: key);
  @override
  State<FormUbi> createState() => _FormUbiState();
}

class _FormUbiState extends State<FormUbi> {


Map<String, List<String>> provinciasPorDepartamento = {
  'Amazonas': ['Chachapoyas', 'Bagua', 'Bongará', 'Condorcanqui', 'Luya', 'Rodríguez de Mendoza', 'Utcubamba'],
  'Áncash': ['Huaraz', 'Aija', 'Antonio Raymondi', 'Asunción', 'Bolognesi', 'Carhuaz', 'Carlos Fermín Fitzcarrald', 'Casma', 'Corongo', 'Huari', 'Huarmey', 'Huaylas', 'Mariscal Luzuriaga', 'Ocros', 'Pallasca', 'Pomabamba', 'Recuay', 'Santa', 'Sihuas', 'Yungay'],
  'Apurímac': ['Abancay', 'Andahuaylas', 'Antabamba', 'Aymaraes', 'Cotabambas', 'Chincheros', 'Grau'],
  'Arequipa': ['Arequipa', 'Camaná', 'Caravelí', 'Castilla', 'Caylloma', 'Condesuyos', 'Islay', 'La Unión'],
  'Ayacucho': ['Huamanga', 'Cangallo', 'Huanca Sancos', 'Huanta', 'La Mar', 'Lucanas', 'Parinacochas', 'Páucar del Sara Sara', 'Sucre', 'Víctor Fajardo', 'Vilcas Huamán'],
  'Cajamarca': ['Cajamarca', 'Cajabamba', 'Celendín', 'Chota', 'Contumazá', 'Cutervo', 'Hualgayoc', 'Jaén', 'San Ignacio', 'San Marcos', 'San Miguel', 'San Pablo', 'Santa Cruz'],
  'Cusco': ['Cusco', 'Acomayo', 'Anta', 'Calca', 'Canas', 'Canchis', 'Chumbivilcas', 'Espinar', 'La Convención', 'Paruro', 'Paucartambo', 'Quispicanchi', 'Urubamba'],
  'Huancavelica': ['Huancavelica', 'Acobamba', 'Angaraes', 'Castrovirreyna', 'Churcampa', 'Huaytará', 'Tayacaja'],
  'Huánuco': ['Huánuco', 'Ambo', 'Dos de Mayo', 'Huacaybamba', 'Huamalíes', 'Leoncio Prado', 'Marañón', 'Pachitea', 'Puerto Inca', 'Lauricocha', 'Yarowilca'],
  'Ica': ['Ica', 'Chincha', 'Nazca', 'Palpa', 'Pisco'],
  'Junín': ['Huancayo', 'Concepción', 'Chanchamayo', 'Jauja', 'Junín', 'Satipo', 'Tarma', 'Yauli', 'Chupaca'],
  'La Libertad': ['Trujillo', 'Ascope', 'Bolívar', 'Chepén', 'Gran Chimú', 'Julcán', 'Otuzco', 'Pacasmayo', 'Pataz', 'Sánchez Carrión', 'Santiago de Chuco', 'Virú'],
  'Lambayeque': ['Chiclayo', 'Ferreñafe', 'Lambayeque'],
  'Lima': ['Huaral', 'Cajatambo', 'Canta', 'Cañete', 'Huarochirí', 'Huaura', 'Oyón', 'Yauyos'],
  'Loreto': ['Maynas', 'Alto Amazonas', 'Datem del Marañón', 'Loreto', 'Mariscal Ramón Castilla', 'Putumayo', 'Requena', 'Ucayali'],
  'Madre de Dios': ['Tambopata', 'Manu', 'Tahuamanu'],
  'Moquegua': ['Mariscal Nieto', 'General Sánchez Cerro', 'Ilo'],
  'Pasco': ['Pasco', 'Daniel Alcides Carrión', 'Oxapampa'],
  'Piura': ['Piura', 'Ayabaca', 'Huancabamba', 'Morropón', 'Paita', 'Sechura', 'Sullana', 'Talara'],
  'Puno': ['Puno', 'Azángaro', 'Carabaya', 'Chucuito', 'El Collao', 'Huancané', 'Lampa', 'Melgar', 'Moho', 'San Antonio de Putina', 'San Román', 'Sandia', 'Yunguyo'],
  'San Martín': ['Moyobamba', 'Bellavista', 'El Dorado', 'Huallaga', 'Lamas', 'Mariscal Cáceres', 'Picota', 'Rioja', 'San Martín', 'Tocache'],
  'Tacna': ['Tacna', 'Candarave', 'Jorge Basadre', 'Tarata'],
  'Tumbes': ['Tumbes', 'Contralmirante Villar', 'Zarumilla'],
  'Ucayali': ['Coronel Portillo', 'Atalaya', 'Padre Abad', 'Purús'],
};

Map<String, List<String>> distritosPorProvincia = {
  // AREQUIPA
  'Arequipa': ['Arequipa', 'Alto Selva Alegre', 'Cayma', 'Cerro Colorado', 'Characato', 'Chiguata', 'Jacobo Hunter', 'La Joya', 'Mariano Melgar', 'Miraflores', 'Mollebaya', 'Paucarpata', 'Pocsi', 'Polobaya', 'Quequeña', 'Sabandía', 'Sachaca', 'San Juan de Siguas', 'San Juan de Tarucani', 'Santa Isabel de Siguas', 'Santa Rita de Siguas', 'Socabaya', 'Tiabaya', 'Uchumayo', 'Vitor', 'Yanahuara', 'Yarabamba', 'Yura'],
  'Camana': ['Camaná', 'José María Quimper', 'Mariano Nicolás Valcárcel', 'Mariscal Cáceres', 'Nicolás de Piérola', 'Ocoña', 'Quilca', 'Samuel Pastor'],
  'Caravelí': ['Caravelí', 'Acarí', 'Atico', 'Atiquipa', 'Bella Unión', 'Cahuacho', 'Chala', 'Chaparra', 'Huanuhuanu', 'Jaqui', 'Lomas', 'Quicacha', 'Yauca'],
  'Castilla': ['Aplao', 'Andagua', 'Ayo', 'Chachas', 'Chilcaymarca', 'Choco', 'Huancarqui', 'Machaguay', 'Orcopampa', 'Pampacolca', 'Tipan', 'Uñon', 'Uraca', 'Viraco'],
  'Caylloma': ['Chivay', 'Achoma', 'Cabanaconde', 'Callalli', 'Caylloma', 'Coporaque', 'Huambo', 'Huanca', 'Ichupampa', 'Lari', 'Lluta', 'Maca', 'Madrigal', 'San Antonio de Chuca', 'Sibayo', 'Tapay', 'Tisco', 'Tuti', 'Yanque', 'Majes'],
  'Condesuyos': ['Chuquibamba', 'Andaray', 'Cayarani', 'Chichas', 'Iray', 'Río Grande', 'Salamanca', 'Yanaquihua'],
  'Islay': ['Mollendo', 'Cocachacra', 'Dean Valdivia', 'Islay', 'Mejía', 'Punta de Bombón'],
  'La Unión': ['Cotahuasi', 'Alca', 'Charcana', 'Huaynacotas', 'Pampamarca', 'Puyca', 'Quechualla', 'Sayla', 'Tauría', 'Tomepampa', 'Toro'],

  // LIMA
  'Lima': ['Lima', 'Ancón', 'Ate', 'Barranco', 'Breña', 'Carabayllo', 'Chaclacayo', 'Chorrillos', 'Cieneguilla', 'Comas', 'El Agustino', 'Independencia', 'Jesús María', 'La Molina', 'La Victoria', 'Lince', 'Los Olivos', 'Lurigancho', 'Lurín', 'Magdalena del Mar', 'Miraflores', 'Pachacamac', 'Pucusana', 'Pueblo Libre', 'Puente Piedra', 'Punta Hermosa', 'Punta Negra', 'Rímac', 'San Bartolo', 'San Borja', 'San Isidro', 'San Juan de Lurigancho', 'San Juan de Miraflores', 'San Luis', 'San Martín de Porres', 'San Miguel', 'Santa Anita', 'Santa María del Mar', 'Santa Rosa', 'Santiago de Surco', 'Surquillo', 'Villa El Salvador', 'Villa María del Triunfo'],
  'Barranca': ['Barranca', 'Paramonga', 'Pativilca', 'Supe', 'Supe Puerto'],
  'Cajatambo': ['Cajatambo', 'Copa', 'Gorgor', 'Huancapón', 'Manás'],
  'Canta': ['Canta', 'Arahuay', 'Huamantanga', 'Huaros', 'Lachaqui', 'San Buenaventura', 'Santa Rosa de Quives'],
  'Cañete': ['San Vicente de Cañete', 'Asia', 'Calango', 'Cerro Azul', 'Chilca', 'Coayllo', 'Imperial', 'Lunahuaná', 'Mala', 'Nuevo Imperial', 'Pacarán', 'Quilmaná', 'San Antonio', 'San Luis', 'Santa Cruz de Flores', 'Zúñiga'],
  'Huaral': ['Huaral', 'Atavillos Alto', 'Atavillos Bajo', 'Aucallama', 'Chancay', 'Ihuarí', 'Lampian', 'Pacaraos', 'San Miguel de Acos', 'Santa Cruz de Andamarca', 'Sumbilca', 'Veintisiete de Noviembre'],
  'Huarochirí': ['Matucana', 'Antioquía', 'Callahuanca', 'Carampoma', 'Chicla', 'Cuenca', 'Huachupampa', 'Huanza', 'Huarochirí', 'Lahuaytambo', 'Langa', 'Laraos', 'Mariatana', 'Ricardo Palma', 'San Andrés de Tupicocha', 'San Antonio', 'San Bartolomé', 'San Damian', 'San Juan de Iris', 'San Juan de Tantaranche', 'San Lorenzo de Quinti', 'San Mateo', 'San Mateo de Otao', 'San Pedro de Casta', 'San Pedro de Huancayre', 'Sangallaya', 'Santa Cruz de Cocachacra', 'Santa Eulalia', 'Santiago de Anchucaya', 'Santiago de Tuna', 'Santo Domingo de Los Olleros', 'Surco'],
  'Huaura': ['Huacho', 'Ambar', 'Caleta de Carquín', 'Checras', 'Hualmay', 'Huaura', 'Leoncio Prado', 'Paccho', 'Santa Leonor', 'Santa María', 'Sayán', 'Vegueta'],
  'Oyón': ['Oyón', 'Andajes', 'Caujul', 'Cochamarca', 'Naván', 'Pachangara'],
  'Yauyos': ['Yauyos', 'Alis', 'Ayauca', 'Ayaviri', 'Azángaro', 'Cacra', 'Carania', 'Catahuasi', 'Chocos', 'Cochas', 'Colonia', 'Hongos', 'Huampara', 'Huancaya', 'Huangáscar', 'Huantán', 'Huañec', 'Laraos', 'Lincha', 'Madean', 'Miraflores', 'Omas', 'Putinza', 'Quinches', 'Quinocay', 'San Joaquín', 'San Pedro de Pilas', 'Tanta', 'Tauripampa', 'Tomas', 'Tupe', 'Viñac', 'Vitis'],

// MOQUEGUA
  'Mariscal Nieto': ['Moquegua', 'Carumas', 'Cuchumbaya', 'Samegua', 'San Cristóbal', 'Torata'],
  'General Sánchez Cerro': ['Omate', 'Chojata', 'Coalaque', 'Ichuña', 'La Capilla', 'Lloque', 'Matalaque', 'Puquina', 'Quinistaquillas', 'Ubinas', 'Yunga'],
  'Ilo': ['Ilo', 'El Algarrobal', 'Pacocha'],



};
   String? departamentoSeleccionado;
  String? provinciaSeleccionada;
  String? distritoSeleccionado;

  List<String> provincias = [];
  List<String> distritos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Departamento
          DropdownButtonFormField<String>(
            value: departamentoSeleccionado,
            hint: Text('Selecciona un departamento'),
            items: provinciasPorDepartamento.keys
                .map((departamento) => DropdownMenuItem<String>(
                      value: departamento,
                      child: Text(departamento),
                    ))
                .toList(),
            onChanged: (valor) {
              setState(() {
                departamentoSeleccionado = valor;
                provinciaSeleccionada = null;
                distritoSeleccionado = null;
                provincias = provinciasPorDepartamento[valor!]!;
                distritos = [];
              });
            },
          ),
          
          // Provincia
          DropdownButtonFormField<String>(
            value: provinciaSeleccionada,
            hint: Text('Selecciona una provincia'),
            items: provincias
                .map((provincia) => DropdownMenuItem<String>(
                      value: provincia,
                      child: Text(provincia),
                    ))
                .toList(),
            onChanged: (valor) {
              setState(() {
                provinciaSeleccionada = valor;
                distritoSeleccionado = null;
                distritos = distritosPorProvincia[valor!]!;
              });
            },
          ),
          
          // Distrito
          DropdownButtonFormField<String>(
            value: distritoSeleccionado,
            hint: Text('Selecciona un distrito'),
            items: distritos
                .map((distrito) => DropdownMenuItem<String>(
                      value: distrito,
                      child: Text(distrito),
                    ))
                .toList(),
            onChanged: (valor) {
              setState(() {
                distritoSeleccionado = valor;
              });
            },
          ),
        ],
      ),
    );
  }

}*/

import 'package:appsol_final/components/confirmarubi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart'; // Necesario para los inputFormatters

class FormUbi extends StatefulWidget {
  const FormUbi({Key? key}) : super(key: key);

  @override
  State<FormUbi> createState() => _FormUbiState();
}

class _FormUbiState extends State<FormUbi> {
  // Mapas de provincias y distritos
  final Map<String, List<String>> provinciasPorDepartamento = {
    'Arequipa': [
      'Arequipa',
      'Camaná',
      'Caravelí',
      'Castilla',
      'Caylloma',
      'Condesuyos',
      'Islay',
      'La Unión'
    ],
    'Lima': [
      'Lima',
      'Barranca',
      'Huaral',
      'Cajatambo',
      'Canta',
      'Cañete',
      'Huarochirí',
      'Huaura',
      'Oyón',
      'Yauyos'
    ],
    'Moquegua': ['Mariscal Nieto', 'General Sánchez Cerro', 'Ilo'],

    // Agrega más departamentos y provincias según sea necesario
  };

  final Map<String, List<String>> distritosPorProvincia = {
    // LIMA
    'Lima': [
      'Lima',
      'Ancón',
      'Ate',
      'Barranco',
      'Breña',
      'Carabayllo',
      'Chaclacayo',
      'Chorrillos',
      'Cieneguilla',
      'Comas',
      'El Agustino',
      'Independencia',
      'Jesús María',
      'La Molina',
      'La Victoria',
      'Lince',
      'Los Olivos',
      'Lurigancho',
      'Lurín',
      'Magdalena del Mar',
      'Miraflores',
      'Pachacamac',
      'Pucusana',
      'Pueblo Libre',
      'Puente Piedra',
      'Punta Hermosa',
      'Punta Negra',
      'Rímac',
      'San Bartolo',
      'San Borja',
      'San Isidro',
      'San Juan de Lurigancho',
      'San Juan de Miraflores',
      'San Luis',
      'San Martín de Porres',
      'San Miguel',
      'Santa Anita',
      'Santa María del Mar',
      'Santa Rosa',
      'Santiago de Surco',
      'Surquillo',
      'Villa El Salvador',
      'Villa María del Triunfo'
    ],
    'Barranca': ['Barranca', 'Paramonga', 'Pativilca', 'Supe', 'Supe Puerto'],
    'Cajatambo': ['Cajatambo', 'Copa', 'Gorgor', 'Huancapón', 'Manás'],
    'Canta': [
      'Canta',
      'Arahuay',
      'Huamantanga',
      'Huaros',
      'Lachaqui',
      'San Buenaventura',
      'Santa Rosa de Quives'
    ],
    'Cañete': [
      'San Vicente de Cañete',
      'Asia',
      'Calango',
      'Cerro Azul',
      'Chilca',
      'Coayllo',
      'Imperial',
      'Lunahuaná',
      'Mala',
      'Nuevo Imperial',
      'Pacarán',
      'Quilmaná',
      'San Antonio',
      'San Luis',
      'Santa Cruz de Flores',
      'Zúñiga'
    ],
    'Huaral': [
      'Huaral',
      'Atavillos Alto',
      'Atavillos Bajo',
      'Aucallama',
      'Chancay',
      'Ihuarí',
      'Lampian',
      'Pacaraos',
      'San Miguel de Acos',
      'Santa Cruz de Andamarca',
      'Sumbilca',
      'Veintisiete de Noviembre'
    ],
    'Huarochirí': [
      'Matucana',
      'Antioquía',
      'Callahuanca',
      'Carampoma',
      'Chicla',
      'Cuenca',
      'Huachupampa',
      'Huanza',
      'Huarochirí',
      'Lahuaytambo',
      'Langa',
      'Laraos',
      'Mariatana',
      'Ricardo Palma',
      'San Andrés de Tupicocha',
      'San Antonio',
      'San Bartolomé',
      'San Damian',
      'San Juan de Iris',
      'San Juan de Tantaranche',
      'San Lorenzo de Quinti',
      'San Mateo',
      'San Mateo de Otao',
      'San Pedro de Casta',
      'San Pedro de Huancayre',
      'Sangallaya',
      'Santa Cruz de Cocachacra',
      'Santa Eulalia',
      'Santiago de Anchucaya',
      'Santiago de Tuna',
      'Santo Domingo de Los Olleros',
      'Surco'
    ],
    'Huaura': [
      'Huacho',
      'Ambar',
      'Caleta de Carquín',
      'Checras',
      'Hualmay',
      'Huaura',
      'Leoncio Prado',
      'Paccho',
      'Santa Leonor',
      'Santa María',
      'Sayán',
      'Vegueta'
    ],
    'Oyón': ['Oyón', 'Andajes', 'Caujul', 'Cochamarca', 'Naván', 'Pachangara'],
    'Yauyos': [
      'Yauyos',
      'Alis',
      'Ayauca',
      'Ayaviri',
      'Azángaro',
      'Cacra',
      'Carania',
      'Catahuasi',
      'Chocos',
      'Cochas',
      'Colonia',
      'Hongos',
      'Huampara',
      'Huancaya',
      'Huangáscar',
      'Huantán',
      'Huañec',
      'Laraos',
      'Lincha',
      'Madean',
      'Miraflores',
      'Omas',
      'Putinza',
      'Quinches',
      'Quinocay',
      'San Joaquín',
      'San Pedro de Pilas',
      'Tanta',
      'Tauripampa',
      'Tomas',
      'Tupe',
      'Viñac',
      'Vitis'
    ],

// MOQUEGUA
    'Mariscal Nieto': [
      'Moquegua',
      'Carumas',
      'Cuchumbaya',
      'Samegua',
      'San Cristóbal',
      'Torata'
    ],
    'General Sánchez Cerro': [
      'Omate',
      'Chojata',
      'Coalaque',
      'Ichuña',
      'La Capilla',
      'Lloque',
      'Matalaque',
      'Puquina',
      'Quinistaquillas',
      'Ubinas',
      'Yunga'
    ],
    'Ilo': ['Ilo', 'El Algarrobal', 'Pacocha'],

    // AREQUIPA
    'Arequipa': [
      'Arequipa',
      'Alto Selva Alegre',
      'Cayma',
      'Cerro Colorado',
      'Characato',
      'Chiguata',
      'Jacobo Hunter',
      'José Luis Bustamante y Rivero',
      'La Joya',
      'Mariano Melgar',
      'Miraflores',
      'Mollebaya',
      'Paucarpata',
      'Pocsi',
      'Polobaya',
      'Quequeña',
      'Sabandía',
      'Sachaca',
      'San Juan de Siguas',
      'San Juan de Tarucani',
      'Santa Isabel de Siguas',
      'Santa Rita de Siguas',
      'Socabaya',
      'Tiabaya',
      'Uchumayo',
      'Vitor',
      'Yanahuara',
      'Yarabamba',
      'Yura'
    ],
    'Camaná': [
      'Camaná',
      'José María Quimper',
      'Mariano Nicolás Valcárcel',
      'Mariscal Cáceres',
      'Nicolás de Piérola',
      'Ocoña',
      'Quilca',
      'Samuel Pastor'
    ],
    'Caravelí': [
      'Caravelí',
      'Acarí',
      'Atico',
      'Atiquipa',
      'Bella Unión',
      'Cahuacho',
      'Chala',
      'Chaparra',
      'Huanuhuanu',
      'Jaqui',
      'Lomas',
      'Quicacha',
      'Yauca'
    ],
    'Castilla': [
      'Aplao',
      'Andagua',
      'Ayo',
      'Chachas',
      'Chilcaymarca',
      'Choco',
      'Huancarqui',
      'Machaguay',
      'Orcopampa',
      'Pampacolca',
      'Tipan',
      'Uñon',
      'Uraca',
      'Viraco'
    ],
    'Caylloma': [
      'Chivay',
      'Achoma',
      'Cabanaconde',
      'Callalli',
      'Caylloma',
      'Coporaque',
      'Huambo',
      'Huanca',
      'Ichupampa',
      'Lari',
      'Lluta',
      'Maca',
      'Madrigal',
      'San Antonio de Chuca',
      'Sibayo',
      'Tapay',
      'Tisco',
      'Tuti',
      'Yanque',
      'Majes'
    ],
    'Condesuyos': [
      'Chuquibamba',
      'Andaray',
      'Cayarani',
      'Chichas',
      'Iray',
      'Río Grande',
      'Salamanca',
      'Yanaquihua'
    ],
    'Islay': [
      'Mollendo',
      'Cocachacra',
      'Dean Valdivia',
      'Islay',
      'Mejía',
      'Punta de Bombón'
    ],
    'La Unión': [
      'Cotahuasi',
      'Alca',
      'Charcana',
      'Huaynacotas',
      'Pampamarca',
      'Puyca',
      'Quechualla',
      'Sayla',
      'Tauría',
      'Tomepampa',
      'Toro'
    ],

    // Agrega más provincias y distritos según sea necesario
  };

  String? selectedDepartamento;
  String? selectedProvincia;
  String? selectedDistrito; // Variable para almacenar el distrito seleccionado
  List<String> provincias = [];
  List<String> distritos = [];

  @override
  void initState() {
    super.initState();
    // Inicializar la lista de provincias según el departamento seleccionado
    provincias = provinciasPorDepartamento.keys.toList();
  }

  void _onDepartamentoChanged(String? newValue) {
    setState(() {
      selectedDepartamento = newValue;
      selectedProvincia = null; // Reinicia la provincia seleccionada
      selectedDistrito = null; // Reinicia el distrito seleccionado
      // Actualiza la lista de provincias de acuerdo al nuevo departamento seleccionado
      provincias = provinciasPorDepartamento[newValue] ?? [];
      distritos = []; // Limpia los distritos porque se cambió la provincia
    });
  }

  List<String> obtenerDistritosPorProvincia(String? provincia) {
    if (provincia == null) {
      return [];
    }
    return distritosPorProvincia[provincia] ?? [];
  }

  void _onProvinciaChanged(String? newValue) {
    setState(() {
      selectedProvincia = newValue;
      selectedDistrito = null; // Reinicia el distrito seleccionado
      // Aquí deberías actualizar los distritos en base a la provincia seleccionada
      distritos = obtenerDistritosPorProvincia(
          newValue); // Método que devuelve los distritos de la provincia
    });
  }

  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _numero = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('¿Dónde quieres recibir el pedido?',style:TextStyle(fontSize:19.sp))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Departamento'),
                value: selectedDepartamento,
                items: provinciasPorDepartamento.keys
                    .map((departamento) => DropdownMenuItem<String>(
                          value: departamento,
                          child: Text(departamento),
                        ))
                    .toList(),
                onChanged: _onDepartamentoChanged,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Provincia'),
                value: selectedProvincia,
                items: selectedDepartamento == null
                    ? []
                    : provincias
                        .map((provincia) => DropdownMenuItem<String>(
                              value: provincia,
                              child: Text(provincia),
                            ))
                        .toList(),
                onChanged: _onProvinciaChanged,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              DropdownButtonFormField<String>(
                decoration:const InputDecoration(labelText: 'Distrito'),
                value: selectedDistrito,
                items: selectedProvincia == null
                    ? []
                    : distritos
                        .map((distrito) => DropdownMenuItem<String>(
                              value: distrito,
                              child: Text(distrito),
                            ))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDistrito = value;
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(
                  labelText:
                      'Avenida/Calle/Jirón', // Etiqueta que siempre estará visible
                  hintText: 'Ingresa el nombre correcto/calle/jirón de la calle',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Color.fromARGB(
                        255, 53, 53, 53), // Color del texto de la etiqueta
                  ),
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Color del texto hint
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior
                      .always, // Siempre mostrar la etiqueta arriba
                  /*focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),*/
                ),
                /*inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Solo letras y espacios
  ],*/
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              TextFormField(
                controller: _numero,
                //keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número/Lote/Manzana', // Etiqueta que siempre estará visible
                  hintText: 'Ingresa el número correcto/lote/manzana del domicilio',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Color.fromARGB(
                        255, 53, 53, 53), // Color del texto de la etiqueta
                  ),
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey, // Color del texto hint
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior
                      .always, // Siempre mostrar la etiqueta arriba
                  /*focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),*/
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.05,
                child: ElevatedButton(
                  onPressed: () {
                    // Verificar que los campos no estén vacíos
                  if (selectedDepartamento != null &&
                        selectedProvincia != null &&
                        selectedDistrito != null &&
                        _direccion.text.isNotEmpty &&
                        _numero.text.isNotEmpty) {
                      final departamento = selectedDepartamento;
                      final provincia = selectedProvincia;
                      final distrito = selectedDistrito;

                      // Haz lo que necesites con estos valores
                      print(
                          "${departamento},${provincia},${distrito},${_direccion.text},${_numero.text}");
                      print("${departamento}");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Confirmarubi(
                            direccion:
                                "${provincia},${distrito},${_direccion.text},${_numero.text}",
                          ),
                        ),
                      );
                    } else {
                      // Mostrar un mensaje de error si algún campo está vacío
                      ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                          content:
                              Text('Por favor, completa todos los campos.'),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 47, 33, 243)),
                  ),
                  child: Text(
                    'Confirmar dirección',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
