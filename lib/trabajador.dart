class TrabajadorFields {
  static const List<String> values = [
    id,
    nombres,
    apellidos,
    fechaNacimiento,
    sueldo,
    createdTime,
  ];
  
  static const String tableName = 'trabajadores';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String realType = 'REAL NOT NULL';
  
  static const String id = '_id';
  static const String nombres = 'nombres';
  static const String apellidos = 'apellidos';
  static const String fechaNacimiento = 'fecha_nacimiento';
  static const String sueldo = 'sueldo';
  static const String createdTime = 'created_time';
}

class TrabajadorModel {
  int? id;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final double sueldo;
  final DateTime? createdTime;

  TrabajadorModel({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.sueldo,
    this.createdTime,
  });

  Map<String, Object?> toJson() => {
        TrabajadorFields.id: id,
        TrabajadorFields.nombres: nombres,
        TrabajadorFields.apellidos: apellidos,
        TrabajadorFields.fechaNacimiento: fechaNacimiento.toIso8601String(),
        TrabajadorFields.sueldo: sueldo,
        TrabajadorFields.createdTime: createdTime?.toIso8601String(),
      };

  factory TrabajadorModel.fromJson(Map<String, Object?> json) => TrabajadorModel(
        id: json[TrabajadorFields.id] as int?,
        nombres: json[TrabajadorFields.nombres] as String,
        apellidos: json[TrabajadorFields.apellidos] as String,
        fechaNacimiento: DateTime.parse(json[TrabajadorFields.fechaNacimiento] as String),
        sueldo: (json[TrabajadorFields.sueldo] as num).toDouble(),
        createdTime: DateTime.tryParse(
            json[TrabajadorFields.createdTime] as String? ?? ''),
      );

  TrabajadorModel copy({
    int? id,
    String? nombres,
    String? apellidos,
    DateTime? fechaNacimiento,
    double? sueldo,
    DateTime? createdTime,
  }) =>
      TrabajadorModel(
        id: id ?? this.id,
        nombres: nombres ?? this.nombres,
        apellidos: apellidos ?? this.apellidos,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        sueldo: sueldo ?? this.sueldo,
        createdTime: createdTime ?? this.createdTime,
      );
      
  // Método para obtener el nombre completo
  String get nombreCompleto => '$nombres $apellidos';
  
  // Método para calcular la edad
  int get edad {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month || 
        (ahora.month == fechaNacimiento.month && ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }
  
  // Método para verificar si es mayor de edad
  bool get esMayorDeEdad => edad >= 18;
  
  // Método para categorizar por sueldo
  String get categoriaSueldo {
    if (sueldo < 1000) return 'Básico';
    if (sueldo < 2000) return 'Intermedio';
    if (sueldo < 5000) return 'Alto';
    return 'Ejecutivo';
  }
}