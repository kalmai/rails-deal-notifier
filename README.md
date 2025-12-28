[![codecov](https://codecov.io/gh/kalmai/rails-deal-notifier/graph/badge.svg?token=G2RM4TUOTG)](https://codecov.io/gh/kalmai/rails-deal-notifier)
### Sports Deal Notifier
notifiy users of local sports team deals.
MVP: notify me of a free carwash from CBJ OR columbus crew meeting conditions.

\* _this project will **NOT** include promotions for gambling._

#### Ruby version
ruby 3.4.7

#### System dependencies
- git
- can run locally
- OR use docker
  - docker-compose
  - docker

#### Configuration
- rails master key stored in `./config/master.key`
- secrets for deployment live in `./.kamal/secrets`
- run `docker compose up`

#### Database creation
- `rails db:setup`

#### Database initialization
- upon booting up the container/local environment it should be seeded by the seed file

#### How to run the test suite
- `bundle exec rspec`
- future me, if there are issues with data persistence in test suite database, run something like `rails db:drop RAILS_ENV=test` plus `rails db:create RAILS_ENV=test`

#### Services (job queues, cache servers, search engines, etc.)
- nhl, mls, ... apis
- geoapify

#### Manual deployment instructions
- ensure you have the `id.pem` file stored in `~/.ssh/`
- tag the image with `docker build -t kalmai/rails-deal-notifier-rails:latest -f Dockerfile . --no-cache`
- push the image to docker hub `docker push kalmai/rails-deal-notifier-rails:latest`
- run `kamal deploy`

### TODOs:
* seed https://en.wikipedia.org/wiki/Sports_in_Ohio deals listed below:
  * https://www.nhl.com/bluejackets/fans/gameday-central#gameday-promotions
  * ~~https://www.columbuscrew.com/supporters/promotions~~
  * https://www.mlb.com/guardians/fans/sponsoroffers
  * https://www.bengals.com/fans/promotions/ promotions are pretty lame... should be low priority
  * cleveland browns are lacking...
* learn pytorch to visit team urls and create/update promotions per season since they can change.
  * ideally figure out how to automate finding the source urls for promotions since they are hidden in the dumbest ways.

* ~~seed MLS teams from their api standings api.~~
* ~~calculate which deals the subscriber should be notified of~~
* ~~send a notification email which contains actionable deals~~
* ~~glam up user interface~~
* ~~add sidekiq to then implement cron jobs and notify users of deals they can act upon~~ went with good_job cause free
  * ~~make this timezone aware~~
  * ~~add the notification for time sensitive deals i.e. moomoocarwash's 1 hour before game deal~~
* remove current GitHub Page and replace with this application
  * render.com seems to be the new heroku, just have to get docker image to work and then figure out how to point my github page to it? or just provide render.io url for portfolio.
* calculate effort level of deal so subscriber can choose the level of effort they want to exert for the discount
  * ~~add notification email regarding users who have subscribed to time sensitive deals~~
  * ~~this will most likely entail getting the games that will be happening today versus results from yesterday and calculating which deals are time sensitive?~~
    * ~~need to add another call to the api each day in the nhl api service~~
    * ~~`time_sensitive?` seems like a good field to add to the structs~~
* add passwordless auth via this blog post: https://blog.testdouble.com/posts/2022-10-25-building-passwordless-email-auth-in-rails/
* build out a FE for users to modify deals they want to use
* build out a User controller to handle account actions like updating email/notification method from email to sms or something like that
  * should totally explore push notifications, not sure that's possible though
    * did a little research and all of them integrate with paid services. just gotta find the service that is the freeist.
* ~~bulk time sensitive emails in order bulking time sensitive emails into one email and sending the rest in order~~
* utilize league start and end times to only call them when they are relatively in season.
  * create a job that checks the teams playing this season and update if necessary
* figure out a better solution for getting timezone/states
  * currently we grab their location data on loading the page which leads to inaccurate information if they update any information or enter a postal code we cannot find with geoapify
    * figure out how to ask for location with browser permissions
    * likely need to update ui to ask for state/postal
      * should likely persist lat/lon as well in the future
* if peoples are interested, register and add https://buymeacoffee.com/ as a badge
* should probably figure out why build times in docker are kinda butt
