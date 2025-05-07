/*
  # Add function to get user details

  This migration adds a function that can be used to get user details from auth.users.
  The function takes an array of user IDs and returns a JSON object mapping each ID to its details including email and raw_user_meta_data.
*/

-- Create function to get user details by user IDs
CREATE OR REPLACE FUNCTION get_user_details(user_ids UUID[])
RETURNS JSONB AS $$
DECLARE
  result JSONB := '{}'::JSONB;
  user_rec RECORD;
BEGIN
  FOR user_rec IN 
    SELECT 
      id::text, 
      email,
      raw_user_meta_data
    FROM auth.users 
    WHERE id = ANY(user_ids)
  LOOP
    result := result || jsonb_build_object(
      user_rec.id, 
      jsonb_build_object(
        'email', user_rec.email,
        'raw_user_meta_data', user_rec.raw_user_meta_data
      )
    );
  END LOOP;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permission to use the function from the authenticated role
GRANT EXECUTE ON FUNCTION get_user_details(UUID[]) TO authenticated; 