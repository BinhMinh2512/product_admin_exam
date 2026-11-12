import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  // Thêm sản phẩm
  Future<void> addProduct(ProductModel product) async {
    await products.add(product.toMap());
  }

  // Hiển thị danh sách sản phẩm theo thời gian mới nhất
  Stream<List<ProductModel>> getProducts() {
    return products.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(String id, ProductModel product) async {
    await products.doc(id).update(product.toMap());
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }
}
