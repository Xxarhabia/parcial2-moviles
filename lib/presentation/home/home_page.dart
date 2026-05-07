import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/core/theme/app_theme.dart';
import 'package:segundo_parcial/data/models/user_model.dart';
import 'package:segundo_parcial/data/repositories/auth_repository.dart';
import 'package:segundo_parcial/data/repositories/product_repository.dart';
import 'package:segundo_parcial/presentation/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authRepository = AuthRepository();
  final _productRepository = ProductRepository();
  UserModel? _currentUser;
  int _productCount = 0;
  bool _loadingCount = true;
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  Future<void> _loadData() async {
    final user = await _authRepository.getCurrentUser();
    final products = await _productRepository.getProducts().catchError((_) => []);
    if (mounted) {
      setState(() {
        _currentUser = user;
        _productCount = products.length;
        _loadingCount = false;
      });
    }
  }
 
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _currentUser?.name.isNotEmpty == true
                        ? _currentUser!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        currentUser: _currentUser,
        currentRoute: '/home',
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceElevated,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            const SizedBox(height: 8),
 
            // Saludo
            Text(
              _getGreeting(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentUser?.name ?? 'Usuario',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
 
            const SizedBox(height: 28),
 
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Productos',
                    value: _loadingCount ? '...' : _productCount.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    label: 'Miembro desde',
                    value: _currentUser != null
                        ? '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}'
                        : '-',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
 
            const SizedBox(height: 28),
 
            // Acciones rápidas
            const Text(
              'Acciones rápidas',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
 
            _QuickActionCard(
              icon: Icons.add_box_rounded,
              title: 'Nuevo producto',
              subtitle: 'Agrega un producto a tu catálogo',
              onTap: () => context.go('/products/create'),
            ),
            const SizedBox(height: 10),
            _QuickActionCard(
              icon: Icons.list_alt_rounded,
              title: 'Ver catálogo',
              subtitle: 'Gestiona tus productos registrados',
              onTap: () => context.go('/products'),
            ),
 
            const SizedBox(height: 28),
 
            // Info de la cuenta
            const Text(
              'Mi cuenta',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Nombre',
                    value: _currentUser?.name ?? '-',
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Correo',
                    value: _currentUser?.email ?? '-',
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.shield_outlined,
                    label: 'Seguridad',
                    value: 'Contraseña encriptada SHA-256',
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
 
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
 
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
 
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
 
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}