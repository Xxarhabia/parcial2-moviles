import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/data/models/product_model.dart';
import 'package:segundo_parcial/presentation/products/detail/product_detail_page.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/auth/login/login_page.dart';
import '../../presentation/auth/register/register_page.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/profile/profile_page.dart';

class AppRouter {
  static final _authRepository = AuthRepository();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final isLoggedIn = await _authRepository.isLoggedIn();
      final isPublicRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Usuario no autenticado intenta acceder a ruta protegida
      if (!isLoggedIn && !isPublicRoute) return '/login';

      // Usuario autenticado intenta acceder a login/register
      if (isLoggedIn && isPublicRoute) return '/home';

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
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/products/detail',
        name: 'product-detail',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailPage(product: product);
        },
      ),
    ],
  );
}