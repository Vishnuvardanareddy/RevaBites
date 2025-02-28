/*
  # Add menu items for restaurants

  1. New Items
    - Add menu items for each restaurant
    - Include prices, descriptions, and images
  2. Categories
    - Organize items by category
*/

-- Add menu items for Burger Bliss
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'Classic Cheeseburger',
    'BBQ Bacon Burger',
    'Veggie Delight',
    'Chicken Sandwich',
    'French Fries'
  ]),
  unnest(ARRAY[
    'Juicy beef patty with melted cheese and fresh vegetables',
    'Smoky bacon with BBQ sauce and onion rings',
    'Plant-based patty with fresh avocado',
    'Grilled chicken breast with lettuce and mayo',
    'Crispy golden fries with seasoning'
  ]),
  unnest(ARRAY[
    12.99,
    14.99,
    11.99,
    10.99,
    4.99
  ]::decimal(10,2)[]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
    'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5',
    'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2',
    'https://images.unsplash.com/photo-1606755962773-d324e0a13086',
    'https://images.unsplash.com/photo-1573080496219-bb080dd4f877'
  ]),
  unnest(ARRAY[
    'Burgers',
    'Burgers',
    'Vegetarian',
    'Sandwiches',
    'Sides'
  ])
FROM restaurants r
WHERE r.name = 'Burger Bliss';

-- Add menu items for Sushi Master
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'California Roll',
    'Spicy Tuna Roll',
    'Dragon Roll',
    'Miso Soup',
    'Green Tea Ice Cream'
  ]),
  unnest(ARRAY[
    'Crab, avocado, and cucumber roll',
    'Fresh tuna with spicy mayo',
    'Eel and cucumber topped with avocado',
    'Traditional Japanese soup with tofu',
    'Authentic matcha ice cream'
  ]),
  unnest(ARRAY[
    8.99,
    10.99,
    15.99,
    3.99,
    5.99
  ]::decimal(10,2)[]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351',
    'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
    'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56',
    'https://images.unsplash.com/photo-1607301405390-d831c242f59b',
    'https://images.unsplash.com/photo-1563805042-7684c019e1cb'
  ]),
  unnest(ARRAY[
    'Sushi',
    'Sushi',
    'Special Rolls',
    'Soups',
    'Desserts'
  ])
FROM restaurants r
WHERE r.name = 'Sushi Master';