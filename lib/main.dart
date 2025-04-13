import 'package:flutter/material.dart';
import 'package:flutter_1st_test/views/views.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Índice que controla qué vista mostrar
  String _currentTitle = 'DME con varianza conocida';

  // Lista de vistas
  final List<Widget> _pages = [
    const SDMWithKnownVariance(), // La vista para DMM con varianza conocida
    const SDMWithUnknownVariance(), // La vista para DMM con varianza desconocida
    const SDDMWithKnownVariance(), // La vista para DMDM con varianza conocida
    const SDDMWithUnknownVariance(), // La vista para DMDM con varianza desconocida
    const AboutPage(), // Otras vistas, como Acerca de
  ];

  final List<String> _titles = [
    'DMM con varianza conocida',  // Título para la DMM con varianza conocida
    'DMM con varianza desconocida', // Título para la DMM con varianza desconocida
    'DMDM con varianza conocida', // Título para la DMDM con varianza conocida
    'DMDM con varianza desconocida', // Título para la DMDM con varianza desconocida
    'Acerca de',       // Título para la vista "Acerca de"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentTitle = _titles[index]; // Cambia el título según la vista seleccionada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_currentTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Menú Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('DMM con varianza conocida'),
              onTap: () {
                _onItemTapped(0); // Cambiar a la vista de DMM con varianza conocida
                Navigator.pop(context); // Cerrar el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('DMM con varianza desconocida'),
              onTap: () {
                _onItemTapped(1); // Cambiar a la vista de DMM con varianza desconocida
                Navigator.pop(context); // Cerrar el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('DMDM con varianza conocida'),
              onTap: () {
                _onItemTapped(2); // Cambiar a la vista de DMDM con varianza conocida
                Navigator.pop(context); // Cerrar el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('DMDM con varianza desconocida'),
              onTap: () {
                _onItemTapped(3); // Cambiar a la vista de DMDM con varianza desconocida
                Navigator.pop(context); // Cerrar el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                _onItemTapped(4); // Cambiar a la vista "Acerca de"
                Navigator.pop(context); // Cerrar el drawer
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Aquí definimos las vistas que se mostrarán
      ),
    );
  }
}
