import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) addToCart;

  ProductDetailPage({required this.product, required this.addToCart});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRating();
    print("Product Data: ${widget.product}"); // Kiểm tra dữ liệu
  }

  void _loadRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRating = prefs.getDouble(widget.product['name'] ?? "default") ?? 0.0;
    });
  }

  void _saveRating(double rating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(widget.product['name'] ?? "default", rating);
  }

  String formatCurrency(int price) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.product['name'] ?? "Sản phẩm";
    String image = widget.product['image'] ?? "https://via.placeholder.com/150";
    int price = (widget.product['price'] ?? 0);
    String description = widget.product['description'] ??
        "Thưởng thức hương vị tuyệt vời với công thức đặc biệt, đem lại trải nghiệm ẩm thực khó quên!";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        image,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported,
                              size: 100, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formatCurrency(price),
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Đánh giá:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            RatingBar.builder(
                              initialRating: userRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  userRating = rating;
                                });
                                _saveRating(rating);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          description,
                          style:
                          TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Text("Thời gian giao hàng:",
                                style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.access_time, size: 20, color: Colors.red),
                            SizedBox(width: 4),
                            Text("30 phút", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: Colors.red, size: 28),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  },
                                ),
                                Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline,
                                      color: Colors.green, size: 28),
                                  onPressed: () {
                                    setState(() => quantity++);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              "Tổng: ${formatCurrency(price * quantity)}",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.addToCart({
                  'name': name,
                  'image': image,
                  'price': price,
                  'quantity': quantity,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$name đã được thêm vào giỏ hàng!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 55),
              ),
              child: Text(
                "Đặt hàng ngay",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
