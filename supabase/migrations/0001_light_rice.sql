/*
  # Create food items table

  1. New Tables
    - `food_items`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `price` (decimal)
      - `image_url` (text)
      - `category` (text)
      - `rating` (decimal)
      - `preparation_time` (integer)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `food_items` table
    - Add policy for authenticated users to read food items
*/

CREATE TABLE food_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  price decimal(10,2) NOT NULL,
  image_url text NOT NULL,
  category text NOT NULL,
  rating decimal(3,1) NOT NULL DEFAULT 0.0,
  preparation_time integer NOT NULL DEFAULT 30,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE food_items ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all users to read food items
CREATE POLICY "Allow users to read food items"
  ON food_items
  FOR SELECT
  TO authenticated
  USING (true);

-- Insert sample food items
INSERT INTO food_items (name, description, price, image_url, category, rating, preparation_time) VALUES
  ('Margherita Pizza', 'Classic pizza with tomato sauce, mozzarella, and basil', 12.99, 'https://img.freepik.com/free-photo/pizza-pizza-filled-with-tomatoes-salami-olives_140725-1200.jpg', 'Pizza', 4.5, 25),
  ('Pepperoni Pizza', 'Pizza topped with pepperoni and cheese', 14.99, 'https://img.freepik.com/free-photo/pizza-time-tasty-homemade-traditional-pizza-italian-recipe_144627-42529.jpg', 'Pizza', 4.7, 25),
  ('Classic Burger', 'Beef patty with lettuce, tomato, and special sauce', 9.99, 'https://img.freepik.com/free-photo/front-view-burger-stand_141793-15542.jpg', 'Burger', 4.3, 20),
  ('Cheese Burger', 'Classic burger with melted cheddar cheese', 10.99, 'https://img.freepik.com/free-photo/fresh-tasty-burger_144627-16345.jpg', 'Burger', 4.4, 20),
  ('California Roll', 'Crab, avocado, and cucumber roll', 8.99, 'https://img.freepik.com/free-photo/side-view-california-roll-with-wasabi-plate_141793-4486.jpg', 'Sushi', 4.6, 15),
  ('Dragon Roll', 'Eel and cucumber roll topped with avocado', 12.99, 'https://img.freepik.com/free-photo/close-up-delicious-sushi-plate_23-2148849761.jpg', 'Sushi', 4.8, 20),
  ('Chocolate Cake', 'Rich chocolate layer cake with ganache', 6.99, 'https://img.freepik.com/free-photo/chocolate-cake-with-chocolate-sprinkles_144627-8998.jpg', 'Dessert', 4.7, 10),
  ('Tiramisu', 'Classic Italian coffee-flavored dessert', 7.99, 'https://img.freepik.com/free-photo/tiramisu-dessert_144627-9010.jpg', 'Dessert', 4.6, 15);