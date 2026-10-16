import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  final List<Product> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://fakestoreapi.com/products'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final List<dynamic> jsonList = json.decode(jsonString);

        setState(() {
          _products = jsonList.map((item) => Product.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Veri çekilemedi: Hata Kodu ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'İnternet veya bağlantı hatası oluştu.';
        _isLoading = false;
      });
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} sepete eklendi!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Katalog'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                        cartItems: _cartItems,
                        onRemoveFromCart: (product) {
                          _removeFromCart(product);
                        },
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: product,
                              onAddToCart: () => _addToCart(product),
                            ),
                          ),
                        );
                      },
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                ),
    );
  }
}