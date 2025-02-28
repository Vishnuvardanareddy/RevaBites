import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva_bites/utils/constants.dart';
import 'package:reva_bites/widgets/restaurant_card.dart';
import 'package:reva_bites/widgets/food_category.dart';
import 'package:reva_bites/widgets/food_item_card.dart';
import 'package:reva_bites/widgets/search_bar.dart';
import 'package:reva_bites/services/restaurant_service.dart';
import 'package:reva_bites/models/restaurant.dart';
import 'package:reva_bites/models/food_item.dart';

// Rest of the file remains the same

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadData();
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      if (_tabController.index == 0) {
        final restaurants = await _restaurantService.getRestaurants(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
        );
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
      } else {
        final foodItems = await _restaurantService.searchFoodItems(
          query: _searchQuery.isEmpty ? null : _searchQuery,
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
        );
        setState(() {
          _foodItems = foodItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadData();
  }

  void _handleCategorySelect(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? '' : category;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery to',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  'Current Location',
                  style: GoogleFonts.poppins(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.text),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Restaurants'),
            Tab(text: 'Food Items'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            CustomSearchBar(onSearch: _handleSearch),
            const SizedBox(height: AppDimensions.paddingMedium),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                children: [
                  FoodCategory(
                    icon: Icons.local_pizza,
                    label: 'Pizza',
                    isSelected: _selectedCategory == 'Pizza',
                    onTap: () => _handleCategorySelect('Pizza'),
                  ),
                  FoodCategory(
                    icon: Icons.lunch_dining,
                    label: 'Burger',
                    isSelected: _selectedCategory == 'Burger',
                    onTap: () => _handleCategorySelect('Burger'),
                  ),
                  FoodCategory(
                    icon: Icons.local_dining,
                    label: 'Biryani',
                    isSelected: _selectedCategory == 'Biryani',
                    onTap: () => _handleCategorySelect('Biryani'),
                  ),
                  FoodCategory(
                    icon: Icons.icecream,
                    label: 'Desserts',
                    isSelected: _selectedCategory == 'Dessert',
                    onTap: () => _handleCategorySelect('Dessert'),
                  ),
                  FoodCategory(
                    icon: Icons.local_cafe,
                    label: 'Coffee',
                    isSelected: _selectedCategory == 'Beverages',
                    onTap: () => _handleCategorySelect('Beverages'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRestaurantList(),
                  _buildFoodItemList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_restaurants.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: _restaurants[index]);
      },
    );
  }

  Widget _buildFoodItemList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_foodItems.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _foodItems.length,
      itemBuilder: (context, index) {
        return FoodItemCard(foodItem: _foodItems[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              _searchQuery.isEmpty && _selectedCategory.isEmpty
                  ? 'No items available'
                  : 'No results found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
