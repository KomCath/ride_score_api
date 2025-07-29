# Welcome to Ride Score API

![Rails](https://img.shields.io/badge/rails-7.0.8-blue)
![Ruby](https://img.shields.io/badge/ruby-3.1.2-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14.13-blue)
![RSpec](https://img.shields.io/badge/tests-RSpec-green)
![Python](https://img.shields.io/badge/Python-ML--integration-blue)
![Status](https://img.shields.io/badge/status-open--to--feedback-brightgreen)

> A take-home challenge turned ongoing learning-in-public project.

`ride_score_api` began as a take-home interview challenge. Although I didn't get the job, I kept building. Turning the codebase into a learning playground to explore service design, APIs, and now AI/ML integration.


---

## Setup

NOTE: make sure to have installed: `ruby -v` is `3.1.2` and `rails -v` is `7.0.8.1`

1. clone this repo and cd into it

2. run `echo GOOGLE_MAPS_API_KEY= > .env` and add your valid API key as the value, if you don't have one, you can get it [here](https://developers.google.com/maps/documentation/embed/get-api-key), it's free!
```ruby
GOOGLE_MAPS_API_KEY=valid_key_here
```

3. run `bundle install`

4. run `rails dev:cache`


---

## Part 1 - The Original Challenge

Build a basic Rails API that could score and rank driver-ride assignments using data from the Google Maps API.

#### Technical spec

- Build a Rails 7 app, using Ruby 3+
- Include the following entities:
    - Ride: has an id, a start address and a destination address
    - Driver: has an id and a home address
- Create a RESTful API endpoint that returns a **paginated JSON list of rides** in descending score order **for a given driver**
- Google Maps is expensive. Consider how you can reduce duplicate API calls
- Include RSpec tests
- Document the API in Markdown

#### What I built

**Models:** `Driver` + `Ride` + `Assignment` *(used to link drivers + rides with calculated score)*

**Controller:** `AssignmentsController#index` - main endpoint that returns a driver's ride assignments sorted by score *(with pagination)*

**Service:** `GoogleMapsMetricsService` - fetches commute and ride metrics using Google Maps Distance Matrix API

#### WIP Observations

- No CRUD yet – all models are seeded for demo purposes
- Google Maps API calls happen at seed time (`rails db:seed`) instead of live — not ideal, but functional for proof-of-concept
- Used service objects to isolate external API logic early on

#### Testing

Watch the magic happen ✨ this endpoint returns a paginated JSON list of rides in descending `score` order for a given `driver`, and the path is *`/v1/driver_id/assignments`*

1. make sure to follow the [setup](#setup) steps first

2. enable the service `Distance Matrix API` from your Google Cloud console [here](https://console.cloud.google.com/marketplace/product/google/distance-matrix-backend.googleapis.com)

3. run `rails db:setup` followed by `rails server`

4. first, let's call the endpoint with a `driver_id` that has [less than 10 rides assigned](http://localhost:3000/v1/3/assignments) *`/v1/3/assignments`*

5. with a `driver_id` that has [more than 10 rides assigned](http://localhost:3000/v1/1/assignments) *`/v1/1/assignments`*

6. with a `driver_id` that has [no rides assigned](http://localhost:3000/v1/2/assignments) *`/v1/2/assignments`*

7. and finally with a `driver_id` that is [not in the db](http://localhost:3000/v1/5/assignments) *`/v1/5/assignments`*


---

## Part 2 - Post Challenge - Address Layer

After the challenge, one of the first things I knew I wanted to add was a proper `Address` model. It honestly didn't make sense for this type of project not to have it, but because of the time constraints of the take-home, it wasn't part of the original build.

Having worked with address logic in a previous job, I felt confident tackling this layer. Plus, I was still enjoying working with the Google Maps API and wanted to keep exploring its edge cases and limitations. So I went for it and also added address verification.

#### What I built

**Model:** `Address`

**Controller:** `AddressesController` - `index` + `show`

**Services:**

- `AddressVerificationService` - validates an address using Google Maps Address Validation API
- `AddressVerificationHandlerService` *WIP* - coordinates when and how to verify an address (not yet wired up to Ride or Driver)

#### WIP Observations

- `AddressVerificationHandlerService` is meant to be triggered whenever an address is passed during driver or ride creation - *this still needs to be implemented*
- Still exploring the best UX flow for when address verification fails (e.g., invalid addresses that require manual correction)
- Implemented address verification as a backgrounded concern to reduce duplicate calls and standardize data

#### Testing

As I mentioned above, this is still  a WIP, but if you're curious about how address verification is working so far, you can currently test it manually through the `AddressVerificationHandlerService`

1. make sure to follow the [setup](#setup) steps first

2. enable the service `Address Validation API` from your Google Cloud console [here](https://console.cloud.google.com/marketplace/product/google/addressvalidation.googleapis.com)

3. go to `rails c`

4. first, let's test a `verification_successful` — valid address
```bash
address_params = {
  line1: "204 Nieto St",
  city: "Long Beach",
  state: "CA",
  zip_code: "90803"
}

AddressVerificationHandlerService.new(address_params).call
# you should see
=> "204 Nieto Avenue, Long Beach, CA 90803-5508, USA"
```

5. then `verification_pending` — slightly incorrect city
```bash
address_params = {
  line1: "2106 Bermuda St",
  city: "Laguna Beach",
  state: "CA",
  zip_code: "90814"
}

AddressVerificationHandlerService.new(address_params).call
# you should see
=> {
  status: "verification_pending",
  message: "[{\"locality\"=>\"Long Beach\"}]",
  address_id: 2
}
```

6. then `unable_to_perform_verification` — with no API key for this test. Exit your `rails c` and go to your `.env` to comment out the line with the `GOOGLE_MAPS_API_KEY`

7. go back into `rails c`
```bash
address_params = {
  line1: "204 Nieto St",
  city: "Laguna Beach",
  state: "CA",
  zip_code: "90803"
}

AddressVerificationHandlerService.new(address_params).call
# you should see
=> {
  status: "unable_to_perform_verification",
  message: "Code: 403 - Method doesn't allow unregistered callers...",
  address_id: 5
}
```


---

## Part 3 - Currently Here - ML Score Prediction Feature

At this point, I started getting curious about how I could use AI/ML in this project. After some research, I decided to try integrating a predictive model that could score ride assignments based on historical ride data.

Instead of using Rails for training the model, I'm using Python, since most ML tools and libraries are better supported in that ecosystem. This opened the door for learning how to connect a Rails backend to a Python-trained model. This is a first attempt, it's more of a proof of concept.

#### What I built

<!-- **Controller:** update `AssignmentsController` to display ML prediction scores next to current score -->

**Service:**

- `MlDataExporterService` - fetches ride and assignment data and outputs a CSV for training the ML model
- `train_assignment_model.py` - uses `scikit-learn` to train a simple regression model that predicts `score`, and saves the model as a `pkl` file
- `ScorePredictionService` *(currently in progress)* - loads the `pkl` and return a predicted `score`

#### WIP Observations

- This was my first attempt integrating `Python` into a `Rails` app, messy but fun
- Predictions currently use placeholder data and mimic real scores; the real goal is to improve prediction logic once the dataset grows

#### Testing

*...to be continued*


---

## What's Next 

[Checkout my trello board](https://trello.com/b/3kZThs0H/ridescoreapi)

Backend

- Surface ML prediction scores in AssignmentsController#index
- Add full CRUD for Drivers, Rides, and Assignments and Addresses
- Finish and integrate AddressVerificationHandlerService
- Improve address validation UX (handle verification_pending cases)
- Remove logic from driver + assignment models and create a service to handle calling GoogleMapsMetricsService
- Upgrade to rails 7.1
- Start thinking about deployment (Render / Fly.io / Heroku?)

AI / ML

- AI-Driven Assignment Optimization

Frontend

- Add a lightweight frontend to manage CRUD in React
- Replace CSV inputs/outputs with UI forms


---

Thank you for following my learning journey. I look forward to continuing to improve the Ride Score API and sharing my progress with the community. To follow my updates or share your thoughts on the project feel free to [reach out to me on LinkedIn](https://www.linkedin.com/in/catharina-komrij/). Let's connect and learn together!
