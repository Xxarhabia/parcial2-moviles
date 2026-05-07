import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:segundo_parcial/core/theme/app_theme.dart';
import 'package:segundo_parcial/data/models/product_model.dart';
import 'package:segundo_parcial/data/models/user_model.dart';
import 'package:segundo_parcial/data/repositories/auth_repository.dart';
import 'package:segundo_parcial/data/repositories/product_repository.dart';
import 'package:segundo_parcial/presentation/widgets/app_drawer.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productRepository = ProductRepository();
  final _authRepository = AuthRepository();
 
  UserModel? _currentUser;
  String _selectedCategory = 'Electrónica';
  bool _isLoading = false;
 
  static const _categories = [
    'Electrónica',
    'Ropa',
    'Hogar',
    'Deportes',
    'Libros',
    'Alimentos',
    'Juguetes',
    'Otros',
  ];
 
  @override
  void initState() {
    super.initState();
    _authRepository.getCurrentUser().then((u) {
      if (mounted) setState(() => _currentUser = u);
    });
  }
 
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
 
      await _productRepository.createProduct(product);
 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Text('${product.name} creado exitosamente'),
              ],
            ),
          ),
        );
        context.go('/products');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/products'),
        ),
      ),
      drawer: AppDrawer(
        currentUser: _currentUser,
        currentRoute: '/products/create',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header ilustrativo
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.accent.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_box_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Completa los datos del producto',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
            const SizedBox(height: 28),
 
            _SectionLabel(label: 'Información básica'),
            const SizedBox(height: 12),
 
            // Nombre
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Nombre del producto *',
                hintText: 'Ej: iPhone 15 Pro',
                prefixIcon: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
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
                prefixIcon: Icon(
                  Icons.attach_money_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
                if (double.tryParse(v.trim()) == null) return 'Precio inválido';
                if (double.parse(v.trim()) < 0) return 'El precio no puede ser negativo';
                return null;
              },
            ),
 
            const SizedBox(height: 24),
 
            _SectionLabel(label: 'Categoría'),
            const SizedBox(height: 12),
 
            // Selector de categorías
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
                      horizontal: 14,
                      vertical: 8,
                    ),
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
 
            const SizedBox(height: 24),
 
            _SectionLabel(label: 'Descripción'),
            const SizedBox(height: 12),
 
            // Descripción
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Describe las características del producto...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(
                    Icons.notes_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa una descripción';
                if (v.trim().length < 5) return 'Descripción muy corta';
                return null;
              },
            ),
 
            const SizedBox(height: 32),
 
            // Botón crear
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isLoading ? 'Creando...' : 'Crear Producto'),
              ),
            ),
 
            const SizedBox(height: 12),
 
            // Botón cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/products'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}