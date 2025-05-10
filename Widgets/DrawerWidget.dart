import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Pages/LoginScreen.dart';
import '../Pages/OrderHistoryPage.dart';
import '../Pages/MenuPage.dart';

class DrawerWidget extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> cartItems;
  final Function(String) removeFromCart;
  final List<Map<String, dynamic>> orderHistory;

  DrawerWidget({
    required this.userId,
    required this.cartItems,
    required this.removeFromCart,
    required this.orderHistory,
  });

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _name = "Người Dùng";
  String _email = "Chưa có email";
  String _avatarUrl = "assets/images/avatar.jpg";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.userId.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          print("🔥 Dữ liệu người dùng từ Firestore: $userData");

          if (mounted) {
            setState(() {
              _name = userData['name'] ?? "Người Dùng";
              _email = (userData.containsKey('email') && userData['email'] != null)
                  ? userData['email']
                  : "Không có email";
              _avatarUrl = userData['avatar'] ?? _avatarUrl;
            });
          }
        } else {
          print("❌ Không tìm thấy dữ liệu người dùng!");
        }
      } catch (e) {
        print("⚠️ Lỗi tải dữ liệu người dùng: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              accountName: Text(
                _name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                _email,
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _avatarUrl.startsWith("http")
                    ? NetworkImage(_avatarUrl)
                    : AssetImage(_avatarUrl) as ImageProvider,
              ),
            ),
          ),
          _buildDrawerItem(CupertinoIcons.home, "Trang Chủ", () => Navigator.pop(context)),
          _buildDrawerItem(Icons.restaurant_menu, "Menu", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPage(
                  addToCart: (item) {}, // Placeholder function
                  cartItems: [], // Truyền danh sách rỗng hoặc giá trị phù hợp
                  removeFromCart: (id) {}, // Placeholder function
                  searchQuery: "", // Giá trị mặc định
                ),
              ),
            );
          }),

          _buildDrawerItem(Icons.favorite, "My Wish List", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderHistoryPage()),
            );
          }),
          _buildDrawerItem(Icons.settings, "Settings", () {}),
          _buildDrawerItem(Icons.support, "Hỗ Trợ Khách Hàng", () {
            print("Người dùng đã nhấn vào Hỗ Trợ Khách Hàng");
          }),
          Divider(),
          _buildDrawerItem(Icons.exit_to_app, "Đăng Xuất", _logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
