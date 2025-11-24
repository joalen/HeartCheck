![HeartCheck](https://user-images.githubusercontent.com/45494246/229330386-bbb8b6f3-c8df-4caa-a5f9-0ae8602b9df3.jpg)

# HeartCheck
Quickly determine if you have a heart disease or not; a 2023 Axxess Hackathon AI track product

## Authors 
Alen Jo (current maintainer) and John Luke (former maintainer from v1.0.0)

## Current Version 
3.0.0 - November 2025

## What's New
* Overhauled from Kivy-based Python GUI to Flutter for better support and modern cross-platform support to places like mobile and web
* Revamped dashboard with the same feel but with implemented windows like results (powerful graphs to showcase historical data), support, settings (allows for dynamic changes of settings), credits (powered by Markdown to dynamically update credits...mainly for me to change up the various dataset owners)
* Changed from a normal SQLite DB to a PostgreSQL backend on the cloud
* Moved AI prediction model into Hugging Face to allow for maintainability and ease of using the model (and ensure the model is up-to-date when I fetch new data) 
* Windows based automatic update system whenever there's either delta updates or a new revamped release (like this one)
* PDF generation for patient data (for caretakers)
* Historical graphic data, provided by a time-series version of PostgreSQL
* Model now has a 95% accuracy when changed to H2O AutoML for better training and hyperparameter tuning of variables!
* GitHub Action runner to allow for training and uploading of model at demand
* GitHub Action runners for Windows (and potentially macOS, Linux, mobile, and web platforms; again, cross-platform!!)

## Wanna Try?
To run the demo, type in the username as "guest@heartcheck.com" and password "heartcheckdemo"
Note: within this demo, app does collect metadata pertinent to AI prediction usage and you only get three uses before you have to register an account!

## Note on registered users
You as a registered user get the privilege of having four free API invocations for the HeartCheck in-house AI model; however, resets occur after a day elapses so that everyone gets the ability to test out this cool project! Of course, creating an account on HeartCheck implies your compliance with holding your data unless you delete your account.

## Architecture Layout of HeartCheck
We first approached the problem by figuring out what pre-existing data we could work with that is reliable enough to differentiate between a person with heart disease and not distinctly. Then, we needed to partially learn some medical terminology of the different columns that the pre-existing data-frame has. We then made sure to utilize Python Libraries such as pandas (to extract the data into a data frame), sklearn (to train the classifier to predict a binary output: 0 (for no heart disease) and 1 (for heart disease) from the data frame), and lightgbm to most accurately, efficiently, and rapidly predict a binary output. 

The below is an idea of using Google Cloud to power HeartCheck. At the moment, since this application is meant for demonstration purposes, this backend serves as a general consensus of how I redesigned the new backend for V3.0.0
<img width="973" height="797" alt="image" src="https://github.com/user-attachments/assets/bdb72a5f-ba2b-4fae-8402-37674af2a4c3" />

# Axxess Hackathon 2023 Reflections

## Inspiration
Frankly speaking, we were thinking through ideas of unpopular programs or apps that users may desire as convenient tools. Additionally, we wanted to fit the theme of the Axxess 2023 Hackathon at UT Dallas, which implied biomedical or medical tools useful in the field. Therefore, the inspiration for the program was to let the user enjoy a tool that is somewhat accurate in producing a result that checks if they have heart disease. However, we hope that with enough resources and data, we can make a tool that helps people identify if they have heart disease or not conveniently (this tool does not mean the user should stray away from the doctor as data is not always representative of a medical diagnosis from a professional). 

## What it does
The program attempts to check if the user has heart disease based on the following parameters:
- age in years (must be from 20-90)
- Gender
- Chest pain type (1 = typical angina; 2 = atypical angina; 3 = non-anginal pain; 4 = asymptomatic)
- Resting blood pressure (in mm Hg on admission to the hospital)
- Serum cholesterol in mg/dl
- Fasting blood sugar > 120 mg/dl (1 = true; 0 = false)
- Resting electrocardiographic results (0 = normal; 1 = having ST-T; 2 = hypertrophy)
- Maximum heart rate (between 50 to 200 BPM)
- Exercise induced angina (1 = yes; 0 = no)
- ST depression induced by exercise relative to rest
- Slope of the peak exercise ST segment (1 = upsloping; 2 = flat; 3 = downsloping)
- Number of major vessels (0-3) colored by fluoroscopy
- Thalassemia score (1 = normal, 2 = fixed defect, 3 = reversible defect)
- Ejection Fraction (percentage %)
- Brain Natrieuretic Peptide (measured in pg/mL)
- C-Reactive Protein (measured in mg/L)
- Diagnosis of heart disease (angiographic disease status) (0: No heart disease; 1: Mild Heart Disease; 2: Moderate Heart Disease; 3: Severe Heart Disease; 4: Clinical Heart Disease)

## Challenges we ran into
Some challenges we ran into were fine-tuning the model to increase prediction accuracy, finding open-source and reliable data to work with, and incorporating an algorithm into a user-friendly GUI. 

## Accomplishments that we're proud of
We are proud that we could train the model to be 60% accurate in producing a binary output: 0 (for no heart disease) and 1 (for heart disease). We are also proud that we could get our program to produce a verdict given random test cases (although, in rare cases, it can detect if a person has heart disease). 

## What we learned
We learned about a few examples of supervised learning algorithms with some emphasis on tree-based models (Random Forest Classifiers), linear models (Linear regression), and gradient boosting frameworks (Lightgbm). I (Alen) also learned how to make a working GUI using the Kivy framework, REST APIs for configuring download and upload activities, and database frameworks (like SQLite). 

# Future Updates for HeartCheck
Check out my GitHub issues and project to see what I've got planned next (or when I end up getting downtime to accomplish some of my ideas)!
