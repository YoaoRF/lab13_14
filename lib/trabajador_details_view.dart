import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'trabajador.dart';
import 'trabajador_database.dart';

class TrabajadorDetailsView extends StatefulWidget {
  const TrabajadorDetailsView({super.key, this.trabajadorId});
  final int? trabajadorId;

  @override
  State<TrabajadorDetailsView> createState() => _TrabajadorDetailsViewState();
}

class _TrabajadorDetailsViewState extends State<TrabajadorDetailsView> {
  // ✅ Singleton instance
  final TrabajadorDatabase trabajadorDatabase = TrabajadorDatabase.instance;

  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController sueldoController = TextEditingController();

  late TrabajadorModel trabajador;
  bool isLoading = false;
  bool isNewTrabajador = false;
  DateTime? fechaNacimiento;

  @override
  void initState() {
    refreshTrabajador();
    super.initState();
  }

  refreshTrabajador() {
    if (widget.trabajadorId == null) {
      setState(() {
        isNewTrabajador = true;
      });
      return;
    }
    
    trabajadorDatabase.read(widget.trabajadorId!).then((value) {
      setState(() {
        trabajador = value;
        nombresController.text = trabajador.nombres;
        apellidosController.text = trabajador.apellidos;
        sueldoController.text = trabajador.sueldo.toString();
        fechaNacimiento = trabajador.fechaNacimiento;
      });
    });
  }

  createTrabajador() async {
    if (nombresController.text.isEmpty || 
        apellidosController.text.isEmpty || 
        sueldoController.text.isEmpty ||
        fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final model = TrabajadorModel(
      nombres: nombresController.text,
      apellidos: apellidosController.text,
      fechaNacimiento: fechaNacimiento!,
      sueldo: double.tryParse(sueldoController.text) ?? 0.0,
      createdTime: DateTime.now(),
    );

    try {
      if (isNewTrabajador) {
        await trabajadorDatabase.create(model);
      } else {
        final updatedModel = model.copy(id: trabajador.id);
        await trabajadorDatabase.update(updatedModel);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trabajador guardado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  deleteTrabajador() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Trabajador'),
        content: Text('¿Estás seguro de que quieres eliminar este trabajador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await trabajadorDatabase.delete(trabajador.id!);
      Navigator.pop(context);
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento ?? DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(isNewTrabajador ? 'Nuevo Trabajador' : 'Editar Trabajador'),
        actions: [
          Visibility(
            visible: !isNewTrabajador,
            child: IconButton(
              onPressed: deleteTrabajador,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
          IconButton(
            onPressed: createTrabajador,
            icon: const Icon(Icons.save, color: Colors.blue),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Nombres
                      TextField(
                        controller: nombresController,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                        decoration: const InputDecoration(
                          labelText: 'Nombres',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Campo Apellidos
                      TextField(
                        controller: apellidosController,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                        decoration: const InputDecoration(
                          labelText: 'Apellidos',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Campo Sueldo
                      TextField(
                        controller: sueldoController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Sueldo',
                          prefixText: '\$ ',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      // Selector de Fecha de Nacimiento
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fechaNacimiento == null
                                  ? 'Seleccionar fecha de nacimiento'
                                  : 'Fecha: ${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: selectDate,
                            icon: Icon(Icons.calendar_today),
                            label: Text('Seleccionar'),
                          ),
                        ],
                      ),
                      
                      // Mostrar edad si hay fecha
                      if (fechaNacimiento != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Edad: ${DateTime.now().year - fechaNacimiento!.year} años',
                            style: TextStyle(color: Colors.blue[300], fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
