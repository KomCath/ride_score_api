# Welcome to Ride Score API

## Challenge Specifications:

- Create a Rails 7 application, using Ruby 3+
- Include the following entities:
  - Ride: has an id, a start address and a destination address. You may end up adding additional information
  - Driver: has an id and a home address

- Build a RESTful API endpoint that returns a paginated JSON list of rides in descending score order for a given driver
- Please write up API documentation for this endpoint in MarkDown or alternative
- Calculate the score of a ride in $ per hour as: (ride earnings) / (commute duration + ride duration). Higher is better
- Google Maps is expensive. Consider how you can reduce duplicate API calls
- Include RSpec tests

---

## What I've got so far:

- Ruby version `3.1.2`
- Rails version `7.0.8`
- Rspec + Postgresql

- Models: driver + ride + assignment
- Service: `GoogleMapsMetricsService`
- Controller: 

---

## Challenge Architecture plans:

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