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

1- clone this repo and cd into it

2- `touch .env` - you need to add a valid `GOOGLE_MAPS_API_KEY` in there, like so
```ruby
GOOGLE_MAPS_API_KEY=valid_key_in
```

3- run `bundle install`

4- run `rails db:setup`

5- run `rails dev:cache`

6- start the server `rails server`

[driver with less than 10 rides](http://localhost:3000/v1/3/assignments)

[driver with more than 10 rides](http://localhost:3000/v1/1/assignments)

[driver with no rides](http://localhost:3000/v1/2/assignments)

[driver not in the db](http://localhost:3000/v1/5/assignments)

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