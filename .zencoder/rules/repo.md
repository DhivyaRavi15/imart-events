# imart-events Information

## Summary
imart-events is a Supabase-powered backend application that manages user events and data for an organization management system. It uses Deno for serverless edge functions that handle user registration and other events.

## Structure
- **supabase/**: Contains Supabase configuration and serverless functions
  - **functions/**: Edge functions for event handling
  - **config.toml**: Supabase configuration file
- **.vscode/**: VS Code configuration
- **deno.json**: Deno runtime configuration

## Language & Runtime
**Language**: TypeScript
**Runtime**: Deno v1
**Framework**: Supabase Edge Functions
**Build System**: Deno built-in

## Dependencies
**Main Dependencies**:
- `@supabase/supabase-js`: Supabase JavaScript client (v2.39.5)
- Deno standard library (v0.224.0)
  - `dotenv`
  - `http/server`

## Database Schema
The application uses a Supabase PostgreSQL database with the following main tables:
- **users**: Stores user information
- **organizations**: Manages organization data
- **departments**: Tracks departments within organizations
- **employees**: Stores employee information
- **jobs**: Manages job listings
- **apps**: Tracks applications in the system

## Edge Functions
**add-user**: 
- Handles user registration events
- Triggered on `SIGNED_UP` events
- Validates user data and creates records in the `users` table
- Path: `supabase/functions/add-user/index.ts`

## Build & Installation
```bash
# Run locally
deno run --allow-net --allow-env functions/add-user/index.ts

# Deploy to Supabase
supabase functions deploy add-user --debug
```

## Supabase Configuration
**Project ID**: imart-events
**API Port**: 54321
**Database Port**: 54322
**Studio Port**: 54323
**Edge Runtime**: Enabled with Deno v1
**Authentication**: Email authentication enabled
**Storage**: Enabled with 50MiB file size limit

## Environment Variables
The application requires the following environment variables:
- `SUPABASE_URL`: URL of the Supabase instance
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key for Supabase authentication