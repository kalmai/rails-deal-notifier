### Sports Deal Notifier
notifiy users of local sports team deals with CRON jobs.
MVP: notify me of a free carwash from CBJ scoring.

#### Ruby version
ruby 3.3.0

#### System dependencies
- sendgrid api key
- geoapify api key

#### Configuration
- rails master key

#### Database creation
- `psql -U zkolker -d deal_notifier_dev` to connect to local DB

#### Database initialization
- `rails db:seed` to get leagues
- execute `rake digest_sports_data:wikipedia_ca_us_teams wikipedia_sports_teams.csv` to fill out teams
- need to add team abbreviations to each team since wikipedia does not. may be able to do this just by calling the appropriate sports api once it's built out

#### How to run the test suite
- `bundle exec rspec`

#### Services (job queues, cache servers, search engines, etc.)
- redis

#### Deployment instructions
- run with ngrok for now...?

### TODOs:
* seed CBJ deals: https://www.nhl.com/bluejackets/fans/gameday-central#gameday-promotions
* calculate which deals the subscriber should be notified of
* send a notification email which contains actionable deals
* glam up user interface
* remove current GitHub Page and replace with this application
* calculate effort level of deal so subscriber can choose the level of effort they want to exert for the discount
  * add notification email regarding users who have subscribed to time sensitive deals
  * this will most likely entail getting the games that will be happening today versus results from yesterday and calculating which deals are time sensitive?
    * need to add another call to the api each day in the nhl api service
    * `time_sensitive?` seems like a good field to add to the structs
* establish a CSV format for uploading deals from other states
  * this should and may likely lead to some kind of admin panel for accepting deals as the administrator role
* add passwordless auth via this blog post: https://blog.testdouble.com/posts/2022-10-25-building-passwordless-email-auth-in-rails/
* build out a FE for users to select deals they want to use
* build out a User controller to handle account actions like updating email/notification method from email to sms or something like that
  * should totally explore push notifications, not sure that's possible though
