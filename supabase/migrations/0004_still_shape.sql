/*
  # Add More Restaurants and Menu Items

  1. New Data
    - Additional restaurants with diverse cuisines
    - Menu items for each restaurant
    - Realistic ratings and delivery times
*/

-- Insert more restaurants
INSERT INTO restaurants (name, cuisine, rating, delivery_time, image_url) VALUES
  ('Beijing House', 'Chinese, Asian', 4.6, '25-30 min', 'https://images.unsplash.com/photo-1552566626-52f8b828add9'),
  ('Taco Fiesta', 'Mexican, Latin', 4.4, '20-25 min', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836'),
  ('Mediterranean Delight', 'Mediterranean, Greek', 4.5, '30-35 min', 'https://images.unsplash.com/photo-1544124499-58912cbddaad'),
  ('Thai Orchid', 'Thai, Asian', 4.3, '25-30 min', 'https://images.unsplash.com/photo-1559847844-5315695dadae');

-- Insert menu items for Beijing House
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'Kung Pao Chicken',
    'Dim Sum Platter',
    'Mapo Tofu'
  ]),
  unnest(ARRAY[
    'Spicy diced chicken with peanuts and vegetables',
    'Assorted steamed dumplings',
    'Spicy tofu in Sichuan sauce'
  ]),
  unnest(ARRAY[
    14.99,
    16.99,
    12.99
  ]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1525755662778-989d0524087e',
    'https://images.unsplash.com/photo-1563245372-f21724e3856d',
    'https://images.unsplash.com/photo-1582450871972-ab5ca641643d'
  ]),
  'Main Course'
FROM restaurants r
WHERE r.name = 'Beijing House';

-- Insert menu items for Taco Fiesta
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  unnest(ARRAY[
    'Street Tacos',
    'Burrito Supreme',
    'Guacamole & Chips'
  ]),
  unnest(ARRAY[
    'Three authentic street-style tacos',
    'Large burrito with all the fixings',
    'Fresh guacamole with crispy tortilla chips'
  ]),
  unnest(ARRAY[
    11.99,
    13.99,
    8.99
  ]),
  unnest(ARRAY[
    'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b',
    'https://images.unsplash.com/photo-1552332386-f8dd00dc2f85',
    'https://images.unsplash.com/photo-1541288097308-7b8e3f58c4c6'
  ]),
  unnest(ARRAY[
    'Main Course',
    'Main Course',
    'Appetizer'
  ])
FROM restaurants r
WHERE r.name = 'Taco Fiesta';