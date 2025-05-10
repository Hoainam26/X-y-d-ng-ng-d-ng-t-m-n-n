import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CartPage.dart'; // Import CartPage để hiển thị giỏ hàng
import '../Widgets/ProductDetailPage.dart';

class MenuPage extends StatefulWidget {
  final Function(Map<String, dynamic>) addToCart;
  final List<Map<String, dynamic>> cartItems; // Thêm giỏ hàng vào MenuPage
  final Function(String) removeFromCart;
  final String searchQuery;

  MenuPage({
    required this.addToCart,
    required this.cartItems,
    required this.removeFromCart,
    required this.searchQuery,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final CollectionReference foodCollection =
  FirebaseFirestore.instance.collection('Food_menu');

  late TextEditingController _searchController;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    searchQuery = widget.searchQuery.toLowerCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thực đơn", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cartItems: widget.cartItems, // Truyền giỏ hàng sang CartPage
                        removeFromCart: widget.removeFromCart,
                        orderHistory: [],
                      ),
                    ),
                  );
                },
              ),
              if (widget.cartItems.isNotEmpty) // Hiển thị số lượng món trong giỏ
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.cartItems.length.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Tìm kiếm món ăn...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: foodCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có món ăn nào"));
          }

          var filteredFoods = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> food = doc.data() as Map<String, dynamic>;
            return food['name'].toString().toLowerCase().contains(searchQuery);
          }).toList();

          if (filteredFoods.isEmpty) {
            return Center(child: Text("Không tìm thấy món ăn phù hợp"));
          }

          return ListView(
            padding: EdgeInsets.all(12),
            children: filteredFoods.map((doc) {
              Map<String, dynamic> food = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food['image'] ?? 'https://via.placeholder.com/150',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    food['name'] ?? "Tên món",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${food['price']?.toString() ?? '0'}₫",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                    onPressed: () {
                      final cartItem = {
                        'id': doc.id, // Lưu ID để xoá nếu cần
                        'name': food['name'],
                        'image': food['image'],
                        'price': food['price'],
                        'quantity': 1,
                      };

                      widget.addToCart(cartItem);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("✅ Đã thêm ${food['name']} vào giỏ hàng!")),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: food,
                          addToCart: widget.addToCart,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
