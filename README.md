# Welcome to Ride Score API

## Challenge Specifications Checklist:

- [ x ] Create a Rails 7 application, using Ruby 3+

- [ x ] Include the following entities:
  - [ x ] Ride: has an id, a start address and a destination address. You may end up adding additional information
  - [ x ] Driver: has an id and a home address

- [ x ] Build a RESTful API endpoint that returns a paginated JSON list of rides in descending score order for a given driver

- [ x ] Please write up API documentation for this endpoint in MarkDown or alternative

- [ x ] Calculate the score of a ride in $ per hour as: (ride earnings) / (commute duration + ride duration). Higher is better

- [ x ] Google Maps is expensive. Consider how you can reduce duplicate API calls

- [ x ] Include RSpec tests

---

## Testing Steps:

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
8. watch the magic happen ✨

this endpoint returns a paginated JSON list of rides in descending `score` order for a given `driver`, and the path is `/v1/driver_id/assignments`

- first, let's call the endpoint with a `driver_id` that has [less than 10 rides assigned](http://localhost:3000/v1/3/assignments)

- with a `driver_id` that has [more than 10 rides assigned](http://localhost:3000/v1/1/assignments)

- with a `driver_id` that has [no rides assigned](http://localhost:3000/v1/2/assignments)

- and finally with a `driver_id` that is [not in the db](http://localhost:3000/v1/5/assignments)

---

## Challenge Architecture Plans:

### Models:

- drivers
  - id
  - home_address

- rides
  - id
  - start_address
  - destination_address
  - ride_duration
  - ride_earning

  - class methods:
    - calculate_ride_earning
      - will need: ride_distance + ride_duration - google api call

- assignments
  - id
  - driver_id
  - ride_id
  - commute_duration
  - score

  - class methods:
    - calculate_commute_duration
      - will need: commute_duration - google api call
    - calculate_score

### Services:

- google api call - `GoogleMapsMetricsService`

### Controllers:

- AssignmentsController - index

### What we've got:

- Ruby version `3.1.2`
- Rails version `7.0.8`
- Rspec + Postgresql

- Models: driver + ride + assignment
- Service: `GoogleMapsMetricsService`
- Controller: `AssignmentsController`

### What to improve:
- implement CRUD for driver + ride + assignment
- add a model address + logic to get coordinates to share with driver + ride
- remove logic from models and create a service to handle calling `GoogleMapsMetricsService`
