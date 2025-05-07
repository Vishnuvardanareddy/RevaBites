import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class VendorService {
  final _supabase = Supabase.instance.client;

  /// Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final response =
          await _supabase.from('restaurants').select('id, name').order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load restaurants: $e');
    }
  }

  /// Get all orders for a specific restaurant
  Future<List<Map<String, dynamic>>> getRestaurantOrders(
      String restaurantId) async {
    try {
      // Get orders with order items and menu items
      final response = await _supabase
          .from('orders')
          .select('''
            id, 
            created_at,
            status,
            restaurant_id,
            user_id,
            order_items (
              *,
              menu_items (*)
            )
          ''')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      // Convert to List<Map<String, dynamic>>
      final orders = List<Map<String, dynamic>>.from(response);

      // Extract all user IDs from orders
      final userIds = orders
          .map((order) => order['user_id'])
          .where((id) => id != null)
          .toList();

      if (userIds.isNotEmpty) {
        try {
          // Call the RPC function to get user emails and metadata
          final result = await _supabase
              .rpc('get_user_details', params: {'user_ids': userIds});

          // Process the result if successful
          if (result != null) {
            final userDetailsMap = Map<String, dynamic>.from(result);

            // Attach user details to orders
            for (var order in orders) {
              final userId = order['user_id']?.toString();
              if (userId != null && userDetailsMap.containsKey(userId)) {
                order['users'] = userDetailsMap[userId];
              } else {
                // Fallback if user details not found
                order['users'] = {
                  'email':
                      'User ${order['user_id'].toString().substring(0, 8)}',
                  'raw_user_meta_data': {'full_name': 'Unknown'}
                };
              }
            }
          } else {
            // Fallback to user IDs if RPC returns null
            _addUserIdPlaceholders(orders);
          }
        } catch (e) {
          // Log error and use fallback
          log('Error fetching user details via RPC: $e');
          _addUserIdPlaceholders(orders);
        }
      } else {
        // No user IDs to process
        _addUserIdPlaceholders(orders);
      }

      return orders;
    } catch (e) {
      log('Exception: $e');
      throw Exception('Failed to load restaurant orders: $e');
    }
  }

  /// Helper to add user ID placeholders when user details can't be retrieved
  void _addUserIdPlaceholders(List<Map<String, dynamic>> orders) {
    for (var order in orders) {
      if (order['user_id'] != null) {
        order['users'] = {
          'email': 'User ${order['user_id'].toString().substring(0, 8)}',
          'raw_user_meta_data': {'full_name': 'Unknown'}
        };
      }
    }
  }

  /// Update the status of an order
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Check current status to prevent updating cancelled or delivered orders
      final currentStatusResponse = await _supabase
          .from('orders')
          .select('status')
          .eq('id', orderId)
          .single();

      final currentStatus = currentStatusResponse['status'];
      if (currentStatus == 'cancelled' || currentStatus == 'delivered') {
        throw Exception('Cannot update cancelled or delivered orders');
      }

      await _supabase
          .from('orders')
          .update({'status': status}).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
