import 'package:go_router/go_router.dart';

import 'package:ecustock/core/services/app_session.dart';
import 'package:ecustock/presentation/screens/bodega_scanner_page.dart';
import 'package:ecustock/presentation/screens/home_page.dart';
import 'package:ecustock/presentation/screens/login_screen.dart';
import 'package:ecustock/presentation/screens/products/add_product_page.dart';
import 'package:ecustock/presentation/screens/products/products_list_page.dart';
import 'package:ecustock/presentation/screens/roles/roles_permissions_screen.dart';
import 'package:ecustock/presentation/screens/sedes/sedes_list_screen.dart';
import 'package:ecustock/presentation/screens/usuarios/usuarios_list_screen.dart';
import 'package:ecustock/presentation/views/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isAuthenticated = AppSession().isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';
    final isSplashRoute = state.matchedLocation == '/';

    if (!isAuthenticated && !isLoginRoute && !isSplashRoute) {
      return '/login';
    }

    if (isAuthenticated && isLoginRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(title: 'EcuStock'),
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
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsListPage(),
    ),
    GoRoute(
      path: '/products/add',
      builder: (context, state) => const AddProductPage(),
    ),
    GoRoute(
      path: '/bodega-scanner',
      builder: (context, state) => const BodegaScannerPage(),
    ),
  ],
);
