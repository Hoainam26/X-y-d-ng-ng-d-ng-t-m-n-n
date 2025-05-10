import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'OrderHistoryPage.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(String) removeFromCart;
  final List<Map<String, dynamic>> orderHistory;

  CartPage({required this.cartItems, required this.removeFromCart, required this.orderHistory});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String paymentMethod = "Tiền mặt";

  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      double price = (item['price'] ?? 0).toDouble();
      int quantity = (item['quantity'] ?? 1);
      total += price * quantity;
    }
    return total;
  }

  String formatCurrency(double price) {
    final formatCurrency = NumberFormat.currency(
        locale: 'vi_VN', symbol: '', decimalDigits: 0);
    return "${formatCurrency.format(price)} VND";
  }

  // Hàm chuyển đổi link Google Drive thành link hiển thị trực tiếp
  String getGoogleDriveDirectLink(String url) {
    final RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)|id=([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    final fileId = match?.group(1) ?? match?.group(2);
    return fileId != null
        ? "https://drive.google.com/uc?export=view&id=$fileId"
        : url;
  }

  Future<void> placeOrder() async {
    if (widget.cartItems.isEmpty) return;

    await FirebaseFirestore.instance.collection('orders').add({
      'items': widget.cartItems,
      'totalPrice': getTotalPrice(),
      'timestamp': Timestamp.now(),
      'name': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'paymentMethod': paymentMethod,
    });

    setState(() {
      widget.cartItems.clear(); // Xóa giỏ hàng
    });
  }


  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chi tiết đơn hàng",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tổng tiền: ${formatCurrency(getTotalPrice())}",
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              SizedBox(height: 10),
              DropdownButtonFormField(
                value: paymentMethod,
                onChanged: (value) =>
                    setState(() => paymentMethod = value.toString()),
                items: ["Tiền mặt", "Chuyển khoản"].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                decoration: InputDecoration(
                    labelText: "Phương thức thanh toán"),
              ),
              TextField(controller: nameController,
                  decoration: InputDecoration(labelText: "Họ và Tên (*)")),
              TextField(controller: phoneController,
                  decoration: InputDecoration(labelText: "Số điện thoại"),
                  keyboardType: TextInputType.phone),
              TextField(controller: addressController,
                  decoration: InputDecoration(labelText: "Địa chỉ giao hàng")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Hủy bỏ")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                placeOrder();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Đặt Hàng", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              "Thành công", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Đơn hàng của bạn đã được đặt thành công!"),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: Text("Đóng")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text("Giỏ hàng trống!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(widget.cartItems[index], index);
              },
            ),
          ),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng cộng:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formatCurrency(getTotalPrice()),
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: showPaymentDialog,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
            child: Text("Thanh toán",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh sản phẩm
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  getGoogleDriveDirectLink(item['image'] ?? ''),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/default_image.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Thông tin sản phẩm + số lượng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Không có tên',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency((item['price'] ?? 0).toDouble()),
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),

                  // Phần hiển thị số lượng và nút tăng/giảm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Nút giảm số lượng
                      IconButton(
                        icon: Icon(
                            Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            if (item['quantity'] > 1) {
                              item['quantity']--; // Giảm số lượng nếu lớn hơn 1
                            } else {
                              widget.cartItems.removeAt(
                                  index); // Xóa nếu số lượng về 0
                            }
                          });
                        },
                      ),

                      // Hiển thị số lượng
                      Text(
                        "${item['quantity']}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                      // Nút tăng số lượng
                      IconButton(
                        icon: Icon(
                            Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            item['quantity']++; // Tăng số lượng
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nút xóa sản phẩm khỏi giỏ hàng
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  widget.cartItems.removeAt(index);
                });
                widget.removeFromCart(item['id'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
