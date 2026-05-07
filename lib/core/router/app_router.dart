import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/data/repositories/auth_repository.dart';
import 'package:segundo_parcial/presentation/auth/login/login_page.dart';
import 'package:segundo_parcial/presentation/auth/register/register_page.dart';
import 'package:segundo_parcial/presentation/home/home_page.dart';
import 'package:segundo_parcial/presentation/products/create/create_product_page.dart';
import 'package:segundo_parcial/presentation/products/list/product_list_page.dart';

class AppRouter {
  static final _authRepository = AuthRepository();
 
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final isLoggedIn = await _authRepository.isLoggedIn();
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
 
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: '/products/create',
        name: 'create-product',
        builder: (context, state) => const CreateProductPage(),
      ),
    ],
  );
}