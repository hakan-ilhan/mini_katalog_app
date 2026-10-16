import 'package:flutter/material.dart';
import '../models/product.dart';

class CartScreen extends StatelessWidget {
  final List<Product> cartItems;
  final Function(Product) onRemoveFromCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
  });

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Sepetiniz henüz boş.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.network(
                          item.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${item.price.toStringAsFixed(2)} TL'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemoveFromCart(item),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} TL',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}