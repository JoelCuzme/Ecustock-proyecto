import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ecustock/core/network/auth_secure_storage.dart';
import 'package:ecustock/core/services/app_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _logout() async {
    await AuthSecureStorage().clearTokens();
    AppSession().clear();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${AppSession().currentUser?.nombre ?? 'Usuario'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Has presionado el botón esta cantidad de veces:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/usuarios'),
              child: const Text('Ver Usuarios'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/sedes'),
              child: const Text('Ver Sedes'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/roles-permissions'),
              child: const Text('Roles y Permisos'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/products'),
              child: const Text('Ver Productos'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
