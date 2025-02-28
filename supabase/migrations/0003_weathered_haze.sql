/*
  # Add Restaurants and Menu Items

  1. New Tables
    - `restaurants`
      - `id` (uuid, primary key)
      - `name` (text)
      - `cuisine` (text)
      - `rating` (decimal)
      - `delivery_time` (text)
      - `image_url` (text)
      - `created_at` (timestamp)

    - `menu_items`
      - `id` (uuid, primary key)
      - `restaurant_id` (uuid, foreign key)
      - `name` (text)
      - `description` (text)
      - `price` (decimal)
      - `image_url` (text)
      - `category` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to read data
*/

-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  cuisine text NOT NULL,
  rating decimal(3,1) NOT NULL,
  delivery_time text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL REFERENCES restaurants(id),
  name text NOT NULL,
  description text NOT NULL,
  price decimal(10,2) NOT NULL,
  image_url text NOT NULL,
  category text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow public read access to restaurants"
  ON restaurants
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow public read access to menu items"
  ON menu_items
  FOR SELECT
  TO authenticated
  USING (true);

-- Insert sample restaurants
INSERT INTO restaurants (name, cuisine, rating, delivery_time, image_url) VALUES
  ('The Spice Garden', 'Indian, Curry', 4.5, '30-35 min', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4'),
  ('Pasta Paradise', 'Italian, Pizza', 4.3, '25-30 min', 'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae'),
  ('Sushi Master', 'Japanese, Sushi', 4.7, '35-40 min', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c'),
  ('Burger Bliss', 'American, Burgers', 4.4, '20-25 min', 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17');

-- Insert sample menu items
INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  'Butter Chicken',
  'Tender chicken in rich tomato-butter sauce',
  15.99,
  'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398',
  'Main Course'
FROM restaurants r
WHERE r.name = 'The Spice Garden';

INSERT INTO menu_items (restaurant_id, name, description, price, image_url, category)
SELECT 
  r.id,
  'Margherita Pizza',
  'Fresh tomatoes, mozzarella, and basil',
  12.99,
  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
  'Pizza'
FROM restaurants r
WHERE r.name = 'Pasta Paradise';