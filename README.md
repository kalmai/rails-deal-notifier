[![codecov](https://codecov.io/gh/kalmai/rails-deal-notifier/graph/badge.svg?token=G2RM4TUOTG)](https://codecov.io/gh/kalmai/rails-deal-notifier)
### Sports Deal Notifier
notifiy users of local sports team deals.
MVP: notify me of a free carwash from CBJ OR columbus crew meeting conditions.

#### Ruby version
ruby 3.3.3

#### System dependencies
- git
- docker-compose: 2.27.0
- docker 26.1.0

#### Configuration
- rails master key stored in `./config/master.key`
- run `docker compose up`

#### Database creation
- `psql -U $USER -d deal_notifier_dev` to connect to local DB

#### Database initialization
- upon booting up the container/local environment it should be seeded by the seed file, should aim to automate team population within leagues in the future...
- execute `rake digest_sports_data:wikipedia_ca_us_teams wikipedia_sports_teams.csv` to fill out hockey teams
- need to add team abbreviations to each team since wikipedia does not. may be able to do this just by calling the appropriate sports api once it's built out

#### How to run the test suite
- `bundle exec rspec`
- future me, if there are issues with data persistence in test suite database, run something like `rails db:drop RAILS_ENV=test` plus `rails db:create RAILS_ENV=test`

#### Services (job queues, cache servers, search engines, etc.)
- nhl api
- sportapi (for mls, and more soon?)
- redis
- good_jobs
- sendgrid
- geoapify

#### Deployment instructions
- run with ngrok for now since firebase image doesn't work yet...
- Firebase Deployment instructions
  - create the app image with: `sudo RAILS_MASTER_KEY=$(echo config/master.key) docker compose --env-file ./config/.env.prod up --build --remove-orphans --force-recreate -d`
  - tag it with: `docker tag rails-deal-notifier-rails northamerica-northeast1-docker.pkg.dev/rails-deal-notifier/deal-notifier/app`
  - push it to google artifactory: `docker push northamerica-northeast1-docker.pkg.dev/rails-deal-notifier/deal-notifier/app`

### TODOs:
* seed https://en.wikipedia.org/wiki/Sports_in_Ohio deals listed below:
  * https://www.nhl.com/bluejackets/fans/gameday-central#gameday-promotions
  * https://www.columbuscrew.com/supporters/promotions
  * https://www.mlb.com/guardians/fans/sponsoroffers
  * https://www.bengals.com/fans/promotions/ promotions are pretty lame... should be low priority
  * cleveland browns are lacking...

* ~~seed MLS teams from their api standings api.~~
* ~~calculate which deals the subscriber should be notified of~~
* send a notification email which contains actionable deals
* glam up user interface
* ~~add sidekiq to then implement cron jobs and notify users of deals they can act upon~~ went with good_job cause free
  * ~~make this timezone aware~~
  * add the notification for time sensitive deals i.e. moomoocarwash's 1 hour before game deal
* remove current GitHub Page and replace with this application
* calculate effort level of deal so subscriber can choose the level of effort they want to exert for the discount
  * ~~add notification email regarding users who have subscribed to time sensitive deals~~
  * ~~this will most likely entail getting the games that will be happening today versus results from yesterday and calculating which deals are time sensitive?~~
    * ~~need to add another call to the api each day in the nhl api service~~
    * ~~`time_sensitive?` seems like a good field to add to the structs~~
* add passwordless auth via this blog post: https://blog.testdouble.com/posts/2022-10-25-building-passwordless-email-auth-in-rails/
* build out a FE for users to select deals they want to use
* build out a User controller to handle account actions like updating email/notification method from email to sms or something like that
  * should totally explore push notifications, not sure that's possible though
* bulk time sensitive emails in order bulking time sensitive emails into one email and sending the rest in order
