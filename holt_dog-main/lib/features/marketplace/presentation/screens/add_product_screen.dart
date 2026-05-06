import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holt_dog/core/constants/app_colors.dart';
import 'package:holt_dog/core/constants/app_typography.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
import '../../data/models/product_model.dart';
import '../../data/models/marketplace_category.dart';
import '../manager/marketplace_cubit.dart';
import '../manager/marketplace_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  MarketplaceCategory _selectedCategory = MarketplaceCategory.food;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _executeAddProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthCubit>().state;
      String retailerId = '';
      if (authState is Authenticated) {
        retailerId = authState.user.id;
      }

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        imageUrl: _imageUrlController.text.isEmpty
            ? 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&q=80'
            : _imageUrlController.text,
        category: _selectedCategory,
        retailerId: retailerId,
      );

      context.read<MarketplaceCubit>().addProduct(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product', style: AppTypography.h3),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textOnPurple,
      ),
      body: BlocListener<MarketplaceCubit, MarketplaceState>(
        listener: (context, state) {
          if (state is MarketplaceProductAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully!')),
            );
            Navigator.pop(context);
          } else if (state is MarketplaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Product Title',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _priceController,
                  label: 'Price (EGP)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter price';
                    if (int.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Image URL (Optional)',
                  hint: 'Paste a web link to an image',
                ),
                SizedBox(height: 20.h),
                Text('Category', style: AppTypography.bodyLarge),
                SizedBox(height: 8.h),
                _buildCategoryDropdown(),
                SizedBox(height: 32.h),
                BlocBuilder<MarketplaceCubit, MarketplaceState>(
                  builder: (context, state) {
                    final isLoading = state is MarketplaceProductAdding;
                    return FilledButton(
                      onPressed: isLoading ? null : _executeAddProduct,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Add Product', style: AppTypography.buttonLabel),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyLarge),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.backgroundGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MarketplaceCategory>(
          value: _selectedCategory,
          isExpanded: true,
          onChanged: (value) {
            if (value != null) setState(() => _selectedCategory = value);
          },
          items: MarketplaceCategory.values
              .where((c) => c != MarketplaceCategory.all)
              .map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
