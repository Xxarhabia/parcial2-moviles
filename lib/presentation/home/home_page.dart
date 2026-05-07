import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authRepository = AuthRepository();
  final _productRepository = ProductRepository();

  UserModel? _currentUser;
  List<ProductModel> _products = [];
  bool _loadingProducts = true;
  String? _errorProducts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cuando el usuario cambia a la pestaña de consulta, refresca
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadProducts();
      }
    });

    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = await _authRepository.getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _errorProducts = null;
    });
    try {
      final products = await _productRepository.getProducts();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        setState(() => _errorProducts = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  // Llamado desde el formulario cuando se crea un producto exitosamente
  void _onProductCreated() {
    _tabController.animateTo(1); // Cambia a pestaña de consulta
    _loadProducts();             // Recarga la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlow'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.add_box_rounded, size: 18),
              text: 'Registrar',
            ),
            Tab(
              icon: Icon(Icons.list_alt_rounded, size: 18),
              text: 'Consultar',
            ),
          ],
        ),
      ),
      drawer: AppDrawer(
        currentUser: _currentUser,
        currentRoute: '/home',
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1 — Registro
          _RegisterTab(
            productRepository: _productRepository,
            onProductCreated: _onProductCreated,
          ),
          // Pestaña 2 — Consulta
          _ConsultTab(
            products: _products,
            isLoading: _loadingProducts,
            error: _errorProducts,
            onRefresh: _loadProducts,
            onDelete: (product) async {
              if (product.id == null) return;
              await _productRepository.deleteProduct(product.id!);
              _loadProducts();
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PESTAÑA 1: REGISTRO
// ─────────────────────────────────────────────
class _RegisterTab extends StatefulWidget {
  final ProductRepository productRepository;
  final VoidCallback onProductCreated;

  const _RegisterTab({
    required this.productRepository,
    required this.onProductCreated,
  });

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Electrónica';
  bool _isLoading = false;

  static const _categories = [
    'Electrónica', 'Ropa', 'Hogar',
    'Deportes', 'Libros', 'Otros',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final product = ProductModel(
        name: _nameController.text.trim(),
        price: _priceController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
      );
      await widget.productRepository.createProduct(product);

      // Limpiar formulario
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() => _selectedCategory = 'Electrónica');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: 10),
                Text('Producto registrado exitosamente'),
              ],
            ),
          ),
        );
        widget.onProductCreated();
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Nombre
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Nombre del producto *',
              hintText: 'Ej: iPhone 15 Pro',
              prefixIcon: Icon(Icons.inventory_2_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa el nombre';
              if (v.trim().length < 2) return 'Nombre muy corto';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Precio
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Precio *',
              hintText: 'Ej: 99.99',
              prefixIcon: Icon(Icons.attach_money_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
              if (double.tryParse(v.trim()) == null) return 'Precio inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Categoría
          const Text(
            'Categoría',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Descripción
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Descripción *',
              hintText: 'Describe el producto...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.notes_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa una descripción';
              return null;
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isLoading ? 'Registrando...' : 'Registrar Producto'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PESTAÑA 2: CONSULTA
// ─────────────────────────────────────────────
class _ConsultTab extends StatelessWidget {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final Function(ProductModel) onDelete;

  const _ConsultTab({
    required this.products,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                color: AppColors.textSecondary, size: 52),
            const SizedBox(height: 16),
            const Text(
              'No hay productos registrados',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final product = products[i];
          return _ProductCard(
            product: product,
            onDelete: () => onDelete(product),
          );
        },
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
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(15)),
            child: Image.network(
              product.displayImage,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}