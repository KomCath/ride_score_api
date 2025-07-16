# Welcome to Ride Score API

![Rails](https://img.shields.io/badge/rails-7.0.8-blue)
![Ruby](https://img.shields.io/badge/ruby-3.1.2-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14.13-blue)
![RSpec](https://img.shields.io/badge/tests-RSpec-green)
![Python](https://img.shields.io/badge/Python-ML--integration-blue)
![Status](https://img.shields.io/badge/status-open--to--feedback-brightgreen)


> A take-home challenge that turned into learning-in-public personal project.

`ride_score_api` started as a technical interview assignment. Although I didn't get the job, I kept building it, turning it into a "playground" to learn new things like service design, API endpoints, and even AI/ML integration.

---

## Setup

NOTE: make sure to have installed: `ruby -v` is `3.1.2` and `rails -v` is `7.0.8.1`

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


#### Thoughts/Improvements?

- No CRUD yet – all models are seeded for demo purposes
- Google Maps API calls happen at seed time (`rails db:seed`) instead of live — not ideal, but functional for proof-of-concept
- Used service objects to isolate external API logic early on


#### Testing steps

Watch the magic happen ✨ this endpoint returns a paginated JSON list of rides in descending `score` order for a given `driver`, and the path is *`/v1/driver_id/assignments`*

1. first, let's call the endpoint with a `driver_id` that has [less than 10 rides assigned](http://localhost:3000/v1/3/assignments) *`/v1/3/assignments`*

2. with a `driver_id` that has [more than 10 rides assigned](http://localhost:3000/v1/1/assignments) *`/v1/1/assignments`*

3. with a `driver_id` that has [no rides assigned](http://localhost:3000/v1/2/assignments) *`/v1/2/assignments`*

4. and finally with a `driver_id` that is [not in the db](http://localhost:3000/v1/5/assignments) *`/v1/5/assignments`*


---

## Part 2 - Post Challenge -  Address Layer

After the challenge, one of the first things I knew I wanted to add was a proper `Address` model. It honestly didn't make sense for this type of project not to have it, but because of the time constraints of the take-home, it wasn't part of the original build.

Having worked with address logic in a previous job, I felt confident tackling this layer. Plus, I was still enjoying working with the Google Maps API and wanted to keep exploring its edge cases and limitations. So I went for it and also added address verification.


#### What I built

**Model:** `Address`

**Controller:** `AddressesController` - `index` + `show`

**Services:**

- `AddressVerificationService` - validates an addresse using Google Maps Address Validation API
- `AddressVerificationHandlerService` *WIP* - coordinates when and how to verify an address (not yet wired up to Ride or Driver)

#### Thoughts/Improvements?

- `AddressVerificationHandlerService` is meant to be triggered whenever an address is passed during driver or ride creation - *this still needs to be implemented*
- Still exploring the best UX flow for when address verification fails (e.g., invalid addresses that require manual correction)
- Implemented address verification as a backgrounded concern to reduce duplicate calls and standardize data


#### Testing steps

*...to be continued*


---

## Part 3 - Currently Here - ML Score Prediction Feature

At this point, I started getting curious about how I could use AI/ML in this project. After some research, I decided to try integrating a predictive model that could score ride assignments based on historical ride data.

Instead of using Rails for training the model, I'm using Python, since most ML tools and libraries are better supported in that ecosystem. This opened the door for learning how to connect a Rails backend to a Python-trained model. This is just a first attempt, a proof of concept.

#### What I built

<!-- **Controller:** update `AssignmentsController` to display ML prediction scores next to current score -->

**Service:**

- `MlDataExporterService` - fetches ride and assignment data and outputs a `csv` for training the ML model
- `train_assignment_model.py` - uses `scikit-learn` to train a simple regression model that predicts `score`, and saves the model as a `pkl` file
- `ScorePredictionService` *(I'm here)* - loads the `pkl` and return a predicted `score`


#### Thoughts/Improvements?

- This was my first attempt integrating `Python` into a `Rails` app, messy but fun
- Predictions currently use placeholder data and mimic real scores; the real goal is to improve prediction logic once the dataset grows

#### Testing steps

*...to be continued*


<!-- #### What to improve:
- Implement CRUD flow for driver + ride + assignment
- Remove logic from driver + assignment models and create a service to handle calling GoogleMapsMetricsService
- Add testing steps for address to readme
- Upgrade to rails 7.1
 -->
---

Thank you for following my learning journey. I look forward to continuing to improve the Ride Score API and sharing my progress with the community. To follow my updates or share your thoughts on the project feel free to [reach out to me on LinkedIn](https://www.linkedin.com/in/catharina-komrij/). Let's connect and learn together!
