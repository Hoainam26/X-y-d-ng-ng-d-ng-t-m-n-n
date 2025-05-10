import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ProductDetailPage.dart';

class PopularItemsWidget extends StatelessWidget {
  final Function(Map<String, dynamic>) addToCart;

  PopularItemsWidget({required this.addToCart});

  String formatCurrency(int price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
  }

  String getGoogleDriveDirectLink(String url) {
    final regExp = RegExp(r"/d/(.*?)/");
    final match = regExp.firstMatch(url);
    return (match != null && match.groupCount >= 1)
        ? "https://drive.google.com/uc?export=view&id=${match.group(1)}"
        : url;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Food_phobien') // Đổi collection
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có món ăn phổ biến"));
          }

          final items = snapshot.data!.docs.map((doc) {
            return {
              "id": doc.id,
              "name": doc["name"],
              "desc": doc["description"],
              "image": getGoogleDriveDirectLink(doc["image"] ?? ""),
              "price": (doc["price"] is int) ? doc["price"] : int.tryParse(doc["price"].toString()) ?? 0,
            };
          }).toList();

          return ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: items.map((item) => _buildItemCard(context, item)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: item,
              addToCart: addToCart,
            ),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          addToCart(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Container(
          width: 180,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item["image"].isNotEmpty
                          ? item["image"]
                          : "https://via.placeholder.com/150",
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/default.png",
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  item["name"] ?? "Sản phẩm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Flexible(
                  child: Text(
                    item["desc"] ?? "Không có mô tả",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(item["price"] ?? 0),
                      style: TextStyle(fontSize: 17, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.red),
                      onPressed: () {
                        addToCart({...item, "quantity": 1}); // Thêm vào giỏ hàng

                        // Hiển thị thông báo đặt hàng thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm vào giỏ hàng!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
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
      ),
    );
  }
}
