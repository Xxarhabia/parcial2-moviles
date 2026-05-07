import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/core/theme/app_theme.dart';
import 'package:segundo_parcial/data/models/user_model.dart';
import 'package:segundo_parcial/data/repositories/auth_repository.dart';

class AppDrawer extends StatelessWidget {
  final UserModel? currentUser;
  final String currentRoute;
  
  const AppDrawer({
    super.key,
    this.currentUser,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // header con info del usuario
          _DrawerHeader(user: currentUser,),

          const SizedBox(height: 8,),

          // Navegacion
          _DrawerItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            isActive: currentRoute == '/home',
            onTab: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          _DrawerItem(
            icon: Icons.inventory_2_rounded, 
            label: 'Productos', 
            isActive: currentRoute == '/products', 
            onTab: () {
              Navigator.pop(context);
              context.go('/products');
            },
          ),
          _DrawerItem(
            icon: Icons.add_box_rounded,
            label: 'Nuevo Producto',
            isActive: currentRoute == '/products/create',
            onTab: () {
              Navigator.pop(context);
              context.go('/products/create');
            },
          ),

          const Spacer(),

          const Divider(height: 1,),
          const SizedBox(height: 8,),

          //Cerrar sesion
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesion',
            isActive: false,
            isDestructive: true,
            onTab: () async {
              Navigator.pop(context);
              await AuthRepository().logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final UserModel? user;
  const _DrawerHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true
                  ? user!.name[0].toUpperCase()
                  : 'U',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14,),
          Text(
            user?.name ?? 'Usuario',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700
            ),
          ),
          const SizedBox(height: 2,),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTab;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTab,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
      ? AppColors.error
      : isActive
      ? AppColors.primary
      : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive
          ? AppColors.primary.withOpacity(0.12)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTab,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20,),
                const SizedBox(width: 14,),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}