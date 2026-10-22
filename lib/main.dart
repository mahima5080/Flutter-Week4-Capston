import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const CapstoneEcommerceApp(),
    ),
  );
}

// -----------------------------------------------------------------------------
// MODELS & STATE MANAGERS
// -----------------------------------------------------------------------------

class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String imageUrl;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class OrderItem {
  final String orderId;
  final double totalAmount;
  final List<CartItem> items;
  final DateTime dateTime;

  OrderItem({
    required this.orderId,
    required this.totalAmount,
    required this.items,
    required this.dateTime,
  });
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class OrderProvider with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        totalAmount: total,
        items: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// APP ENTRY POINT
// -----------------------------------------------------------------------------

class CapstoneEcommerceApp extends StatelessWidget {
  const CapstoneEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopSmart Capstone',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 1: AUTHENTICATION (LOGIN / SIGNUP)
// -----------------------------------------------------------------------------

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController(text: 'mahima@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  void _submitAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated Firebase Auth
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 12),
              const Text('ShopSmart Store', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Week 4 Flutter Capstone Project', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _submitAuth,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login to Store', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN TAB NAVIGATION (PRODUCTS, CART, ORDERS, SETTINGS)
// -----------------------------------------------------------------------------

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductCatalogScreen(),
    CartScreen(),
    OrderHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, cart, child) => Badge(
                label: Text('${cart.itemCount}'),
                isLabelVisible: cart.itemCount > 0,
                child: const Icon(Icons.shopping_cart),
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 2: PRODUCT CATALOG & CATEGORY FILTER
// -----------------------------------------------------------------------------

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  String _selectedCategory = 'All';

  final List<Product> _products = [
    Product(
      id: 'p1',
      title: 'Wireless Headphones',
      price: 2499.00,
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/150',
      rating: 4.5,
    ),
    Product(
      id: 'p2',
      title: 'Smart Fitness Watch',
      price: 3999.00,
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/150',
      rating: 4.7,
    ),
    Product(
      id: 'p3',
      title: 'Leather Casual Shoes',
      price: 1899.00,
      category: 'Fashion',
      imageUrl: 'https://via.placeholder.com/150',
      rating: 4.2,
    ),
    Product(
      id: 'p4',
      title: 'Ergonomic Backpack',
      price: 1299.00,
      category: 'Fashion',
      imageUrl: 'https://via.placeholder.com/150',
      rating: 4.6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSmart Store'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Electronics', 'Fashion'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = filtered[index];
                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.deepPurple.shade50,
                          child: const Icon(Icons.devices, size: 50, color: Colors.deepPurple),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('₹${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    Text('${product.rating}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.deepPurple),
                                  onPressed: () {
                                    Provider.of<CartProvider>(context, listen: false).addItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.title} added to cart!'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 3: CART & MOCK CHECKOUT
// -----------------------------------------------------------------------------

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your shopping cart is empty.'))
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      final productId = cart.items.keys.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(item.product.title),
                          subtitle: Text('Unit: ₹${item.product.price} | Total: ₹${item.product.price * item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cart.removeSingleItem(productId),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => cart.addItem(item.product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Process Mock Order Checkout
                        Provider.of<OrderProvider>(context, listen: false).addOrder(
                          cart.items.values.toList(),
                          cart.totalAmount,
                        );
                        cart.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment Successful! Order Placed.')),
                        );
                      },
                      child: const Text('Proceed to Payment (Mock)', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 4: ORDER HISTORY
// -----------------------------------------------------------------------------

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orderData.orders.isEmpty
          ? const Center(child: Text('No orders placed yet.'))
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (context, index) {
                final order = orderData.orders[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    title: Text('Order #${order.orderId} - ₹${order.totalAmount.toStringAsFixed(2)}'),
                    subtitle: Text('${order.dateTime.day}/${order.dateTime.month}/${order.dateTime.year} ${order.dateTime.hour}:${order.dateTime.minute}'),
                    children: order.items.map((item) {
                      return ListTile(
                        title: Text(item.product.title),
                        trailing: Text('${item.quantity}x ₹${item.product.price}'),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 5: SETTINGS & DARK MODE TOGGLE
// -----------------------------------------------------------------------------

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme across the application'),
            secondary: const Icon(Icons.brightness_6),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}