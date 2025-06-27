import 'package:flutter/material.dart';
import 'trabajador.dart';
import 'trabajador_database.dart';
import 'trabajador_details_view.dart';

class TrabajadoresView extends StatefulWidget {
  const TrabajadoresView({super.key});

  @override
  State<TrabajadoresView> createState() => _TrabajadoresViewState();
}

class _TrabajadoresViewState extends State<TrabajadoresView> with TickerProviderStateMixin {
  // ✅ Singleton instance
  final TrabajadorDatabase trabajadorDatabase = TrabajadorDatabase.instance;
  
  List<TrabajadorModel> trabajadores = [];
  String filtroActual = 'todos';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    refreshTrabajadores();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    trabajadorDatabase.close();
    super.dispose();
  }

  refreshTrabajadores() async {
    List<TrabajadorModel> result;
    
    switch (filtroActual) {
      case 'mayores':
        result = await trabajadorDatabase.readByEdad(18);
        break;
      case 'altoSueldo':
        result = await trabajadorDatabase.readBySueldo(2000);
        break;
      default:
        result = await trabajadorDatabase.readAll();
    }
    
    setState(() {
      trabajadores = result;
    });
    _animationController.forward();
  }

  goToTrabajadorDetailsView({int? id}) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TrabajadorDetailsView(trabajadorId: id),
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
    _animationController.reset();
    refreshTrabajadores();
  }

  Color getSueldoColor(double sueldo) {
    if (sueldo < 1000) return Colors.red[100]!;
    if (sueldo < 2000) return Colors.orange[100]!;
    if (sueldo < 5000) return Colors.green[100]!;
    return Colors.blue[100]!;
  }

  Widget buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(  // ✅ Agregamos Center aquí
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ Centrado horizontal también
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No hay trabajadores registrados',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Agrega tu primer trabajador para comenzar',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => goToTrabajadorDetailsView(),
              icon: Icon(Icons.add),
              label: Text('Agregar Primer Trabajador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Gestión de Trabajadores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filtroActual = value;
              });
              _animationController.reset();
              refreshTrabajadores();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'todos', child: Text('Todos')),
              PopupMenuItem(value: 'mayores', child: Text('Mayores de edad')),
              PopupMenuItem(value: 'altoSueldo', child: Text('Sueldo > \$2000')),
            ],
            icon: Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[850]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: trabajadores.isEmpty
            ? buildEmptyState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: trabajadores.length,
                  itemBuilder: (context, index) {
                    final trabajador = trabajadores[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            50 * (1 - _animationController.value) * (index * 0.1 + 1),
                          ),
                          child: Opacity(
                            opacity: _animationController.value,
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () => goToTrabajadorDetailsView(id: trabajador.id),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [getSueldoColor(trabajador.sueldo), Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trabajador.nombreCompleto,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[600],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  trabajador.categoriaSueldo,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[600],
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '\$${trabajador.sueldo.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cake,
                                                size: 16,
                                                color: Colors.blue[600],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Edad: ${trabajador.edad} años',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blue[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (trabajador.createdTime != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text(
                                              'Registrado: ${trabajador.createdTime!.day}/${trabajador.createdTime!.month}/${trabajador.createdTime!.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => goToTrabajadorDetailsView(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: Text(
            'Agregar Trabajador',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}