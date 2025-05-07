import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reva_bites/screens/auth_screen.dart';
import 'package:reva_bites/services/vendor_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final _supabase = Supabase.instance.client;
  final _vendorService = VendorService();
  bool _isLoading = true;
  bool _isUpdating = false;
  List<Map<String, dynamic>> _restaurants = [];
  String? _selectedRestaurantId;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final restaurants = await _vendorService.getRestaurants();

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });

      if (_restaurants.isNotEmpty && _selectedRestaurantId == null) {
        _selectedRestaurantId = _restaurants.first['id'];
        _loadOrders();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load restaurants: $e');
    }
  }

  Future<void> _loadOrders() async {
    if (_selectedRestaurantId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final orders =
          await _vendorService.getRestaurantOrders(_selectedRestaurantId!);

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load orders: $e');
    }
  }

  Future<void> _updateOrderStatus(
      String orderId, String currentStatus, String newStatus) async {
    // Don't allow updates if status is cancelled or delivered
    if (currentStatus == 'cancelled' || currentStatus == 'delivered') {
      _showErrorSnackBar(
          'Cannot update ${_getFormattedStatus(currentStatus)} orders');
      return;
    }

    try {
      setState(() {
        _isUpdating = true;
      });

      await _vendorService.updateOrderStatus(orderId, newStatus);

      setState(() {
        _isUpdating = false;
      });

      // Refresh orders after update
      _loadOrders();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order status updated to ${_getFormattedStatus(newStatus)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      _showErrorSnackBar('Failed to update order status: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('MMM d, y • hh:mm a').format(dateTime);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.amber;
      case 'out_for_delivery':
        return Colors.deepPurple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFormattedStatus(String status) {
    return status
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ));
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Restaurant selector
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[100],
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Restaurant',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedRestaurantId,
                    items: _restaurants.map((restaurant) {
                      return DropdownMenuItem<String>(
                        value: restaurant['id'],
                        child: Text(restaurant['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRestaurantId = value;
                      });
                      _loadOrders();
                    },
                  ),
                ),

                // Orders list
                Expanded(
                  child: _orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders for this restaurant',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            final orderItems = List<Map<String, dynamic>>.from(
                                order['order_items']);
                            final status = order['status'] ?? 'pending';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order #${order['id'].toString().substring(0, 8)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (order['users'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order['users']['raw_user_meta_data'] !=
                                                      null &&
                                                  order['users'][
                                                              'raw_user_meta_data']
                                                          ['full_name'] !=
                                                      null
                                              ? order['users']
                                                      ['raw_user_meta_data']
                                                  ['full_name']
                                              : order['users']['email'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatDate(order['created_at']),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getStatusColor(status),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _getFormattedStatus(status),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Customer information
                                        if (order['users'] != null)
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Customer Details:',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (order['users'][
                                                            'raw_user_meta_data'] !=
                                                        null &&
                                                    order['users'][
                                                                'raw_user_meta_data']
                                                            ['full_name'] !=
                                                        null)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.person_outline,
                                                          size: 18,
                                                          color:
                                                              Colors.grey[700]),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        order['users'][
                                                                'raw_user_meta_data']
                                                            ['full_name'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                if (order['users'][
                                                            'raw_user_meta_data'] !=
                                                        null &&
                                                    order['users'][
                                                                'raw_user_meta_data']
                                                            ['full_name'] !=
                                                        null)
                                                  const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.email_outlined,
                                                        size: 18,
                                                        color:
                                                            Colors.grey[700]),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      order['users']['email'] ??
                                                          'No email',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(height: 16),

                                        // Order items section
                                        const Text(
                                          'Order Items:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...orderItems.map((item) {
                                          final menuItem = item['menu_items'];
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(menuItem['name']),
                                            subtitle: Text(
                                              '${NumberFormat.currency(
                                                symbol: '₹',
                                                decimalDigits: 2,
                                              ).format(item['price'])} x ${item['quantity']}',
                                            ),
                                            trailing: Text(
                                              NumberFormat.currency(
                                                symbol: '₹',
                                                decimalDigits: 2,
                                              ).format(
                                                (item['price'] as num) *
                                                    (item['quantity'] as int),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Amount:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              NumberFormat.currency(
                                                symbol: '₹',
                                                decimalDigits: 2,
                                              ).format(
                                                orderItems.fold(
                                                  0.0,
                                                  (sum, item) =>
                                                      sum +
                                                      ((item['price'] as num) *
                                                          (item['quantity']
                                                              as int)),
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Status update buttons
                                        if (status != 'cancelled' &&
                                            status != 'delivered')
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              if (status == 'pending')
                                                _statusButton(
                                                  'Confirm',
                                                  Colors.blue,
                                                  () => _updateOrderStatus(
                                                    order['id'],
                                                    status,
                                                    'confirmed',
                                                  ),
                                                ),
                                              if (status == 'confirmed')
                                                _statusButton(
                                                  'Preparing',
                                                  Colors.amber,
                                                  () => _updateOrderStatus(
                                                    order['id'],
                                                    status,
                                                    'preparing',
                                                  ),
                                                ),
                                              if (status == 'preparing')
                                                _statusButton(
                                                  'Out for Delivery',
                                                  Colors.deepPurple,
                                                  () => _updateOrderStatus(
                                                    order['id'],
                                                    status,
                                                    'out_for_delivery',
                                                  ),
                                                ),
                                              if (status == 'out_for_delivery')
                                                _statusButton(
                                                  'Delivered',
                                                  Colors.green,
                                                  () => _updateOrderStatus(
                                                    order['id'],
                                                    status,
                                                    'delivered',
                                                  ),
                                                ),
                                              if (status != 'cancelled' &&
                                                  status != 'delivered')
                                                _statusButton(
                                                  'Cancel',
                                                  Colors.red,
                                                  () => _updateOrderStatus(
                                                    order['id'],
                                                    status,
                                                    'cancelled',
                                                  ),
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

  Widget _statusButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isUpdating ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: _isUpdating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }
}
