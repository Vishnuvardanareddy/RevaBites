/*
  # Food Items Management

  1. Security
    - Add policies for food items management
    - Allow admins to manage food items
    - Allow authenticated users to read food items

  2. Changes
    - Add admin role check function
    - Add management policies for food items table
*/

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(user_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = user_id
    AND raw_user_meta_data->>'role' = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add management policies
CREATE POLICY "Allow admins to insert food items"
  ON food_items
  FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Allow admins to update food items"
  ON food_items
  FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Allow admins to delete food items"
  ON food_items
  FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));