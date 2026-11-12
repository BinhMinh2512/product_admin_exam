import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/cloudinary_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  final ProductService productService = ProductService();
  final CloudinaryService cloudinaryService = CloudinaryService();
  final ImagePicker imagePicker = ImagePicker();

  XFile? selectedImage;
  String imageUrl = '';
  bool isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    if (product != null) {
      nameController.text = product.name;
      priceController.text = product.price.toString();
      quantityController.text = product.soluong.toString();
      imageUrl = product.image;
    }
  }

  Future<void> pickImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image != null && mounted) {
      setState(() => selectedImage = image);
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (selectedImage != null) {
        imageUrl = (await cloudinaryService.uploadImage(selectedImage!)) ?? '';
      }

      if (imageUrl.isEmpty) {
        throw Exception('Vui lòng chọn hình ảnh sản phẩm!');
      }

      final product = ProductModel(
        id: widget.product?.id,
        name: nameController.text.trim(),
        price: double.parse(priceController.text.trim()),
        soluong: int.parse(quantityController.text.trim()),
        image: imageUrl,
      );

      if (isEditing) {
        await productService.updateProduct(widget.product!.id!, product);
      } else {
        await productService.addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Cập nhật sản phẩm thành công!'
                : 'Thêm sản phẩm thành công!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'SỬA SẢN PHẨM' : 'THÊM SẢN PHẨM')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: selectedImage != null
                          ? FutureBuilder(
                              future: selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          : imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 55,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Nhấn để chọn hình ảnh'),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                      prefixIcon: Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên sản phẩm!';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Giá sản phẩm',
                      suffixText: 'VNĐ',
                      prefixIcon: Icon(Icons.payments),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');

                      if (price == null || price <= 0) {
                        return 'Giá phải lớn hơn 0!';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final quantity = int.tryParse(value ?? '');

                      if (quantity == null || quantity < 0) {
                        return 'Số lượng không hợp lệ!';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : saveProduct,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(isLoading ? 'ĐANG LƯU...' : 'LƯU SẢN PHẨM'),
                    ),
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
