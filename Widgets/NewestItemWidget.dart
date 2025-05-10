import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'ProductDetailPage.dart';

class NewestItemWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) addToCart;

  NewestItemWidget({required this.addToCart});

  String formatCurrency(int price) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(price);
  }

  String getGoogleDriveDirectLink(String url) {
    final regExp = RegExp(r"/d/(.*?)/");
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return "https://drive.google.com/uc?export=view&id=${match.group(1)}";
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('food_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final items = snapshot.data!.docs.map((doc) {
            return {
              "id": doc.id,
              "name": doc["name"] ?? "Sản phẩm",
              "description": doc["description"] ?? "Không có mô tả",
              "price": doc["price"] ?? 0,
              "image": getGoogleDriveDirectLink(doc["image"] ?? ""),
            };
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: product,
                        addToCart: addToCart,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          child: SizedBox(
                            width: 150,
                            height: 120,
                            child: product["image"].isNotEmpty
                                ? Image.network(
                              product["image"],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/default.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                                : Image.asset(
                              "assets/images/default.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product["name"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  product["description"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                RatingBar.builder(
                                  initialRating: 4,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 18,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.red,
                                  ),
                                  onRatingUpdate: (index) {},
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatCurrency(product["price"]),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(CupertinoIcons.cart, color: Colors.red),
                                      onPressed: () {
                                        // Thêm vào giỏ hàng
                                        addToCart({...product, "quantity": 1});

                                        // Hiển thị thông báo đặt hàng thành công
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle, color: Colors.white),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  "Đã Thêm Vào Giỏ Hàng!",
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
