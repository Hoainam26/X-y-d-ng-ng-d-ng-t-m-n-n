import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Đảm bảo bạn có file này được tạo từ Firebase CLI
import 'Pages/HomePage.dart';
import 'Pages/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  void _checkUserLogin() {
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  // Giữ nguyên logic cũ: nếu sản phẩm đã có (so sánh theo 'name') tăng số lượng, nếu không thêm mới với số lượng là 1
  void addToCart(Map<String, dynamic> item) {
    setState(() {
      int index = cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
      if (index != -1) {
        cartItems[index]['quantity'] += 1;
      } else {
        cartItems.add({...item, 'quantity': 1});
      }
    });
    print("Cart Items: $cartItems");
  }

  // Giữ nguyên logic cũ: xoá món hàng theo 'name'
  void removeFromCart(String itemName) {
    setState(() {
      cartItems.removeWhere((item) => item['name'] == itemName);
    });
    print("After removal, Cart Items: $cartItems");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Food_App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: _user == null
          ? LoginScreen()
          : HomePage(
        userId: _user!.uid,
        addToCart: addToCart,
        cartItems: cartItems,
        removeFromCart: removeFromCart,
        orderHistory: [],
      ),
    );
  }
}
