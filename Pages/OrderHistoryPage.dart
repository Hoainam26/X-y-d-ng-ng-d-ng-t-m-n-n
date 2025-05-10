import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  String formatCurrency(dynamic price) {
    if (price is! num) return "0 VND";
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    return "${formatCurrency.format(price)} VND";
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Không xác định";
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void showOrderDetails(BuildContext context, QueryDocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chi tiết đơn hàng"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thời gian: ${formatTimestamp(data['timestamp'])}", style: const TextStyle(color: Colors.grey)),
                const Divider(),
                Text("Họ và Tên: ${data['name'] ?? 'Không có thông tin'}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Số điện thoại: ${data['phone'] ?? 'Không có thông tin'}"),
                Text("Địa chỉ giao hàng: ${data['address'] ?? 'Không có thông tin'}"),
                Text("Phương thức thanh toán: ${data['paymentMethod'] ?? 'Không có thông tin'}"),
                const Divider(),
                ...(data['items'] as List<dynamic>? ?? []).map((item) {
                  return ListTile(
                    leading: item['image'] != null
                        ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover)
                        : Image.asset('assets/default_image.png', width: 50, height: 50),
                    title: Text(item['name'] ?? 'Không xác định',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text("Số lượng: ${item['quantity'] ?? '0'}",
                        style: const TextStyle(color: Colors.black54)),
                    trailing: Text(formatCurrency(item['price']),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  );
                }).toList(),
                const Divider(),
                Text("Tổng tiền: ${formatCurrency(data['totalPrice'])}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          ],
        );
      },
    );
  }

  void deleteOrder(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa đơn hàng"),
        content: const Text("Bạn có chắc chắn muốn xóa đơn hàng này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xóa đơn hàng thành công"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi khi xóa đơn hàng: $e"), backgroundColor: Colors.red),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Chưa có đơn hàng nào!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final order = snapshot.data!.docs[index];
              final data = order.data() as Map<String, dynamic>? ?? {};
              return InkWell(
                onTap: () => showOrderDetails(context, order),
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Đơn hàng #${index + 1}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteOrder(context, order.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text("Thời gian: ${formatTimestamp(data['timestamp'])}",
                            style: const TextStyle(color: Colors.grey)),
                        const Divider(),
                        Text("Tổng tiền: ${formatCurrency(data['totalPrice'])}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
