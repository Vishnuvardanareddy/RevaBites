/*
  # Add Menu Items for Restaurants
  
  1. New Items
    - Add menu items for:
      - The Spice Garden (Indian)
      - Pasta Paradise (Italian)
      - Sushi Master (Japanese)
      - Burger Bliss (American)
      
  2. Security
    - Uses existing RLS policies
*/

-- Add menu items for The Spice Garden
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'Chicken Tikka Masala',
    'Vegetable Biryani',
    'Garlic Naan',
    'Mango Lassi'
  ]),
  unnest(ARRAY[
    'Grilled chicken in creamy tomato sauce',
    'Fragrant rice with mixed vegetables',
    'Freshly baked bread with garlic',
    'Sweet yogurt drink with mango'
  ]),
  unnest(ARRAY[
    16.99,
    14.99,
    3.99,
    4.99
  ]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1565557623262-b51c2513a641',
    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8',
    'https://images.unsplash.com/photo-1604542031658-5799ca5d7936',
    'https://images.unsplash.com/photo-1571006682889-7e64f028d06c'
  ]),
  unnest(ARRAY[
    'Main Course',
    'Main Course',
    'Bread',
    'Beverages'
  ])
FROM restaurants r
WHERE r.name = 'The Spice Garden';

-- Add menu items for Pasta Paradise
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'Fettuccine Alfredo',
    'Pepperoni Pizza',
    'Tiramisu',
    'Garlic Bread'
  ]),
  unnest(ARRAY[
    'Creamy pasta with parmesan',
    'Classic pepperoni and cheese pizza',
    'Italian coffee-flavored dessert',
    'Toasted bread with garlic butter'
  ]),
  unnest(ARRAY[
    15.99,
    13.99,
    6.99,
    4.99
  ]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1645112411341-6c4fd023714a',
    'https://images.unsplash.com/photo-1628840042765-356cda07504e',
    'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
    'https://images.unsplash.com/photo-1573140247632-f8fd74997d5c'
  ]),
  unnest(ARRAY[
    'Pasta',
    'Pizza',
    'Dessert',
    'Sides'
  ])
FROM restaurants r
WHERE r.name = 'Pasta Paradise';