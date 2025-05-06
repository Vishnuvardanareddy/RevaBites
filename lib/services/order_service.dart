import 'package:reva_bites/models/cart_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  /// Creates a new order with order items from the cart
  Future<String> createOrder({
    required String restaurantId,
    required Map<String, CartItem> cartItems,
    String status = 'pending',
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Insert the order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'restaurant_id': restaurantId,
            'status': status,
          })
          .select()
          .single();

      final String orderId = orderResponse['id'];

      // Insert order items
      final orderItems = cartItems.values
          .map((item) => {
                'order_id': orderId,
                'menu_item_id': item.id,
                'price': item.price,
                'quantity': item.quantity,
              })
          .toList();

      await _supabase.from('order_items').insert(orderItems);

      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get all orders for the current user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.from('orders').select('''
            *,
            restaurants (*),
            order_items (
              *,
              menu_items (*)
            )
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  /// Update the status of an order
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
