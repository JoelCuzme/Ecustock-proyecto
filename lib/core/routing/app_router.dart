import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../presentation/screens/login_page.dart';
import '../../presentation/screens/roles/roles_permissions_screen.dart';
import '../../presentation/screens/sedes/sedes_list_screen.dart';
import '../../presentation/screens/usuarios/usuarios_list_screen.dart';

class AppRouter {
  AppRouter(this.authBloc);

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isPrivateRoute = state.matchedLocation != '/login';

      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      if (!isAuthenticated && isPrivateRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MyHomePage(title: 'EcuStock'),
      ),
      GoRoute(
        path: '/roles-permissions',
        builder: (context, state) => const RolesPermissionsScreen(),
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UsuariosListScreen(),
      ),
      GoRoute(
        path: '/sedes',
        builder: (context, state) => const SedesListScreen(),
      ),
    ],
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    Future<void> handleLogout() async {
      context.read<AuthBloc>().add(LogoutRequested());
      if (!mounted) return;
      context.go('/login');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_circle, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    user?.nombre ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Sin correo',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rol: ${user?.rol ?? 'Sin rol'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
