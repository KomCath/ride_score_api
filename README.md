# Welcome to Ride Score API

> A challenge that turned into learning in public experience.

Recently, I was given a take-home Rails project as part of an interview process. Even though I didn't get the job, I decided to continue working on the project because I'm enjoying to learn more about how to build Rails API endpoints.

---

## The Challenge
#### Specifications Checklist:
- Create a Rails 7 application, using Ruby 3+
- Include the following entities:
  - Ride: has an id, a start address and a destination address
  - Driver: has an id and a home address
- Build a RESTful API endpoint that returns a paginated JSON list of rides in descending score order for a given driver
- Please write up API documentation for this endpoint in MarkDown or alternative
- Google Maps is expensive. Consider how you can reduce duplicate API calls
- Include RSpec tests

#### What to improve:
- Implement CRUD for driver + ride + assignment
- Add a model address + logic to get coordinates to share with driver + ride
- Remove logic from models and create a service to handle calling GoogleMapsMetricsService

---

## Architecture Plans * post-challenge *
- Create service to handle calling to `AddressVerificationService`
- Create service to move away parse_api_response logic from `AddressVerificationService`
- Add testing steps for address to readme
- Upgrade to rails 7.1

---

## What we've got

####  -- Version 1.0 --
- Ruby version `3.1.2`
- Rails version `7.0.8`
- Rspec + Postgresql
- **Models:** Driver + Ride + Assignment
- **Controllers:** `AssignmentsController` - *index*
- **Services:** `GoogleMapsMetricsService`

---

####  -- Version 2.0 -- **WIP**
- **Models:** Address + ~~VerifiedAddress~~
- **Controllers:** `AddressesController` - *index + show + create + update*
- **Services:** `AddressVerificationService` + ~~`AddressVerificationBuilder`~~

---

## Testing Steps

NOTE: make sure that for this test `ruby -v` is `3.1.2` and `rails -v` is `7.0.8.1`

1. clone this repo and cd into it

2. run `echo GOOGLE_MAPS_API_KEY= > .env` and add your valid API key as the value, if you don't have one go [here](https://developers.google.com/maps/documentation/embed/get-api-key), it's free!
```ruby
GOOGLE_MAPS_API_KEY=valid_key_here
```

3. enable the service `distance-matrix-backend` from Google Maps API that we are using for this challenge [here](https://console.cloud.google.com/marketplace/product/google/distance-matrix-backend.googleapis.com?q=search&referrer=search&project=peak-lattice-417821)

4. run `bundle install`

5. run `rails dev:cache`
```ruby
=> Development mode is now being cached.
```

6. run `rails db:setup`
```
🌱Seeding...
```

7. run `rails server`

8. watch the magic happen ✨ *this endpoint returns a paginated JSON list of rides in descending `score` order for a given `driver`, and the path is `/v1/driver_id/assignments`*

- first, let's call the endpoint with a `driver_id` that has [less than 10 rides assigned](http://localhost:3000/v1/3/assignments)

- with a `driver_id` that has [more than 10 rides assigned](http://localhost:3000/v1/1/assignments)

- with a `driver_id` that has [no rides assigned](http://localhost:3000/v1/2/assignments)

- and finally with a `driver_id` that is [not in the db](http://localhost:3000/v1/5/assignments)

*...to be continued*

---

Thank you for following my learning journey. I look forward to continuing to improve the Ride Score API and sharing my progress with the community. To follow my updates or share your thoughts on the project feel free to [reach out to me on LinkedIn](https://www.linkedin.com/in/catharina-komrij/). Let's connect and learn together!
