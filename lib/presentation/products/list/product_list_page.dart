import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/core/theme/app_theme.dart';
import 'package:segundo_parcial/data/models/product_model.dart';
import 'package:segundo_parcial/data/models/user_model.dart';
import 'package:segundo_parcial/data/repositories/auth_repository.dart';
import 'package:segundo_parcial/data/repositories/product_repository.dart';
import 'package:segundo_parcial/presentation/widgets/app_drawer.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _productRepository = ProductRepository();
  final _authRepository = AuthRepository();
  final _searchController = TextEditingController();
 
  UserModel? _currentUser;
  List<ProductModel> _products = [];
  List<ProductModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
 
  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProducts);
  }
 
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
 
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _authRepository.getCurrentUser();
      final products = await _productRepository.getProducts();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _products = products;
          _filtered = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }
 
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    });
  }
 
  Future<void> _deleteProduct(ProductModel product) async {
    if (product.id == null) return;
 
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar producto?',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        content: Text(
          'Se eliminará "${product.name}" permanentemente.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
 
    if (confirm != true) return;
 
    try {
      await _productRepository.deleteProduct(product.id!);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => context.go('/products/create'),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.background,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        currentUser: _currentUser,
        currentRoute: '/products',
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
 
          const SizedBox(height: 8),
 
          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                ? _ErrorView(error: _error!, onRetry: _loadData)
                : _filtered.isEmpty
                ? _EmptyView(
                    hasSearch: _searchController.text.isNotEmpty,
                    onAdd: () => context.go('/products/create'),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final product = _filtered[i];
                        return _ProductCard(
                          product: product,
                          onDelete: () => _deleteProduct(product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onDelete;
 
  const _ProductCard({required this.product, required this.onDelete});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            child: Image.network(
              product.displayImage,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: AppColors.surfaceElevated,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
 
          const SizedBox(width: 14),
 
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
 
          // Delete
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
 
  const _ErrorView({required this.error, required this.onRetry});
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _EmptyView extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onAdd;
 
  const _EmptyView({required this.hasSearch, required this.onAdd});
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              color: AppColors.textSecondary,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'Sin resultados para esa búsqueda'
                  : 'No hay productos aún',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}