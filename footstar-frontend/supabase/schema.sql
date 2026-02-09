-- Create a table for public profiles
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  first_name text,
  last_name text,
  age int,
  avatar_url text,
  
  -- Player Attributes
  position_primary text,
  position_secondary text,
  position_tertiary text,
  foot text,
  
  -- Skills (1-5)
  speed int check (speed between 1 and 5),
  technique int check (technique between 1 and 5),
  stamina int check (stamina between 1 and 5),
  defense int check (defense between 1 and 5),
  shooting int check (shooting between 1 and 5),
  tactics int check (tactics between 1 and 5),
  vision int check (vision between 1 and 5),
  charisma int check (charisma between 1 and 5),
  
  -- Social
  favorite_club text,
  favorite_player text,

  constraint username_length check (char_length(username) >= 3)
);

-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);
