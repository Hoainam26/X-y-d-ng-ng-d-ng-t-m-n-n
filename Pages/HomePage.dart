import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Widgets/AppBarWidget.dart';
import '../Widgets/CategoriesWidget.dart';
import '../Widgets/DrawerWidget.dart';
import '../Widgets/NewestItemWidget.dart';
import '../Widgets/PopularItemsWidget.dart';
import 'MenuPage.dart';
import 'CartPage.dart'; // Import trang giỏ hàng

class HomePage extends StatefulWidget {
  final String userId;
  final Function(Map<String, dynamic>) addToCart;
  final List<Map<String, dynamic>> cartItems;
  final Function(String) removeFromCart;
  final List<Map<String, dynamic>> orderHistory;

  const HomePage({
    Key? key,
    required this.userId,
    required this.addToCart,
    required this.cartItems,
    required this.removeFromCart,
    required this.orderHistory,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  void _searchAndNavigate() {
    String query = _searchController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPage(
          addToCart: widget.addToCart,
          cartItems: widget.cartItems,       // Thêm tham số cartItems
          removeFromCart: widget.removeFromCart, // Thêm tham số removeFromCart
          searchQuery: query.isNotEmpty ? query : "",
        ),
      ),
    );
  }


  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: widget.cartItems,
          removeFromCart: widget.removeFromCart,
          orderHistory: widget.orderHistory,
        ),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Cập nhật UI để số giỏ hàng thay đổi
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          AppBarWidget(
            cartItems: widget.cartItems,
            orderHistory: widget.orderHistory,
            removeFromCart: widget.removeFromCart,
            cartItemCount: widget.cartItems.length,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.search, color: Colors.red),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _searchController,
                              onFieldSubmitted: (value) => _searchAndNavigate(),
                              decoration: const InputDecoration(
                                hintText: "Bạn muốn ăn gì hôm nay?",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 10),
            child: Text(
              "Thể Loại",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          CategoriesWidget(),
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 10),
            child: Text(
              "Phổ biến",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          PopularItemsWidget(addToCart: widget.addToCart),
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 10),
            child: Text(
              "Món Mới",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          NewestItemWidget(addToCart: widget.addToCart),
        ],
      ),
      drawer: DrawerWidget(
        userId: widget.userId,
        cartItems: widget.cartItems,
        removeFromCart: widget.removeFromCart,
        orderHistory: widget.orderHistory,
      ),
    );
  }
}
