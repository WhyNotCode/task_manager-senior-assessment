# Task Manager

A simple todo app with weather. Built with Rails 7.1, PostgreSQL, and Hotwire.

## Quick Start

Prerequisites: Ruby 3.3.4, PostgreSQL, WeatherAPI account (free)

1. Clone and install:
   git clone git@github.com:WhyNotCode/task_manager-senior-assessment.git
   cd task_manager-senior-assessment
   bundle install

2. Set up API key:
   rails credentials:edit
   (add: weatherapi: api_key: your_key_here)
   
   OR use env var:
   export WEATHER_API_KEY=your_key

3. Database:
   rails db:create
   rails db:migrate

4. Run:
   ./bin/dev
   
   Open http://localhost:3000

## Tests

Run all tests:
   bundle exec rspec

34+ tests covering task logic and weather service - all pass with no flakes.

## What I Built

TASKS:
- Create/edit/delete tasks
- Mark complete/incomplete
- View by status (Todo vs Completed)
- Tracks completion percentage

WEATHER:
- Shows temp, conditions, sunrise/sunset
- Auto-detects location from IP
- Falls back to Cape Town for dev
- Caches for 15 minutes
- Manual refresh to clear cache

Mobile responsive, dark mode support (system preference), keyboard accessible.

## Design Decisions

1. **DateTime for completion (not boolean)**
   - Why: Prevents data bugs, records WHEN tasks completed, better for history
   - Model handles both: complete!, incomplete!, completed?

2. **Service layer for weather**
   - Why: Testable, handles all API errors gracefully, doesn't crash app
   - Returns: { success:, location:, temp_c:, temp_f:, sunrise:, sunset:, ... }

3. **15-minute cache**
   - Why: API updates that often anyway, reduces rate limits, huge perf win
   - Manual refresh button if you need immediate update

4. **Hotwire (Turbo) for dynamic updates**
   - Why: Fast, no page reloads, works without JavaScript
   - Tasks update smoothly when you add/complete/delete

5. **Bootstrap for design**
   - Why: Mobile-first responsive, dark mode built-in, consistent look

6. **Defensive error handling everywhere**
   - Why: Network fails, APIs go down, responses are weird - app stays up
   - Returns user-friendly errors instead of 500 pages

7. **Credentials for API key**
   - Why: Never commit secrets, Rails encrypts them, safe to share
   - Falls back to ENV if not set, logs warning

## Trade-offs

Caching vs Real-time: Weather API updates every 15-30 min anyway. Caching gives massive performance boost with manual refresh available.

Hardcoded fallback (Cape Town): Simple, works for dev. Could use geolocation but adds complexity + privacy concerns.

Full-page reload after task actions: Simpler than in-place updates. Turbo is so fast you won't notice. Correct state guaranteed.

No user accounts: Assessment scope. Could add if needed. All users share same tasks.

## Tests Cover

TASK MODEL:
- Validations (title required, length limits)
- Complete/incomplete toggle
- Scopes (completed, incomplete)
- Completion percentage

WEATHER SERVICE:
- IP detection (IPv4, IPv6, localhost)
- Location formatting
- API responses (success, errors, bad JSON)
- Error handling (network down, 403 quota, 500 errors)
- Integration flow

Focus: Business logic matters. Controllers/views are thin Rails defaults.

## Security

- API key in encrypted Rails credentials (not code)
- API parameters URI-encoded
- CSRF tokens on forms (Rails default)
- XSS prevention via escaped output (Rails default)
- Parameterized database queries (no SQL injection)

I will be happy to answer more questions when required.

