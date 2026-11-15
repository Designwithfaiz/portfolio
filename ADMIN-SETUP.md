# Portfolio admin setup

The admin interface is added at **/admin/**. Your public GitHub Pages site remains static; Supabase provides the secure login, project database and video storage.

## 1. Create Supabase project
Create a free project at https://supabase.com/dashboard. In Project Settings > API, copy the Project URL and anon/publishable key.

## 2. Configure the website
Edit `assets/js/supabase-config.js` in this repository:
- Replace `PASTE_YOUR_SUPABASE_PROJECT_URL_HERE` with your project URL.
- Replace `PASTE_YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY_HERE` with the anon/publishable key.

This browser key is expected to be public. Never use a service_role/secret key in the website.

## 3. Create the private admin user
In Supabase > Authentication > Users, invite/create the email address you will use to sign in. Disable public sign-ups in Authentication settings.

Copy the user's UUID. Open SQL Editor, paste the contents of `supabase/schema.sql`, replace `YOUR_AUTH_USER_UUID` with that UUID, and run it. The SQL creates the projects table, public read access for published projects, and admin-only write/upload permissions.

## 4. Publish
Commit the config file and wait for GitHub Pages to deploy. Open `https://designwithfaiz.github.io/portfolio/admin/` and sign in.

## How to manage work
- Choose **Upload video file** to upload MP4, MOV or WebM files to Supabase Storage.
- Choose **Google Drive / YouTube link** to embed an existing video.
- Edit a project to change its title, category, description, thumbnail or visibility.
- Uncheck “Show this project” to keep a project as a draft.

The public Work page reads published records from Supabase automatically. Until Supabase is configured and projects are entered, it retains the current 12 hard-coded examples.

## Important storage note
Uploaded portfolio videos are public to visitors because the portfolio needs to play them. Only the dashboard and write operations are private. Keep private/personal footage out of this public portfolio bucket. Upload size and bandwidth limits depend on your Supabase plan.
