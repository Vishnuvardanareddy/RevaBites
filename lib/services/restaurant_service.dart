import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reva_bites/models/restaurant.dart';
import 'package:reva_bites/models/food_item.dart';

// Rest of the file remains the same;

class RestaurantService {
  final _supabase = Supabase.instance.client;

  Future<List<Restaurant>> getRestaurants(
      {String? searchQuery, String? category}) async {
    var query = _supabase.from('restaurants').select('*, menu_items(*)');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
          'name.ilike.%$searchQuery%,cuisine.ilike.%$searchQuery%,menu_items.name.ilike.%$searchQuery%');
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('menu_items.category', category);
    }

    final response = await query.order('rating', ascending: false);

    return (response as List).map((item) => Restaurant.fromJson(item)).toList();
  }

  Future<List<FoodItem>> searchFoodItems(
      {String? query, String? category}) async {
    var dbQuery =
        _supabase.from('menu_items').select('*, restaurants!inner(*)');

    if (query != null && query.isNotEmpty) {
      dbQuery = dbQuery.or('name.ilike.%$query%,description.ilike.%$query%');
    }

    if (category != null && category.isNotEmpty) {
      dbQuery = dbQuery.eq('category', category);
    }

    final response = await dbQuery;
    return (response as List).map((item) => FoodItem.fromJson(item)).toList();
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String restaurantId) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('restaurant_id', restaurantId);

    return List<Map<String, dynamic>>.from(response);
  }
}
