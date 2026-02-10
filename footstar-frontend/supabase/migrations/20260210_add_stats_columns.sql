-- Add stats columns to profiles table
ALTER TABLE profiles 
ADD COLUMN str_matches_played INTEGER DEFAULT 0,
ADD COLUMN str_matches_won INTEGER DEFAULT 0,
ADD COLUMN str_goals_scored INTEGER DEFAULT 0;
