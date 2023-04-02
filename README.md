![HeartCheck](https://user-images.githubusercontent.com/45494246/229330386-bbb8b6f3-c8df-4caa-a5f9-0ae8602b9df3.jpg){align: center}

# HeartCheck
Quickly determine if you have a heart disease or not

# Authors 
Alen Jo and John Luke 

# Pre-requisites 
Install the following modules using the package manager [pip](https://pip.pypa.io/en/stable/):

```bash
pip install sklearn
pip install pandas
pip install lightgbm
```
# Inspiration
In honesty, we were thinking through ideas of unpopular programs or apps that users may desire as convenient tools. Additionally, we wanted to fit the theme of the Axxess 2023 Hackathon at UT Dallas, which implied biomedical or medical tools useful in the field. Therefore, the inspiration for the program was to let the user enjoy a tool that is somewhat accurate in producing a result that checks if they have heart disease. However, we hope that with enough resources and data, we can make a tool that helps people identify if they have heart disease or not conveniently (this tool does not mean the user should stray away from the doctor as data is not always representative of a medical diagnosis from a professional). 

# What it does
The program attempts to check if the user has heart disease based on the following parameters:
- age in years (must be from 20-90)
- Gender: (1 = male; 0 = female)
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
- Thalassemia score (1 = normal, 2 = fixed defect, 3 = reversible defect
- Diagnosis of heart disease (angiographic disease status) (Value 0: < 50% diameter narrowing, Value 1: > 50% diameter narrowing)

# How we built it
We first approached the problem by figuring out what pre-existing data we could work with that is reliable enough to differentiate between a person with heart disease and not distinctly. Then, we needed to partially learn some medical terminology of the different columns that the pre-existing data-frame has. We then made sure to utilize Python Libraries such as pandas (to extract the data into a data frame), sklearn (to train the classifier to predict a binary output: 0 (for no heart disease) and 1 (for heart disease) from the data frame), and lightgbm to most accurately, efficiently, and rapidly predict a binary output. 

# Challenges we ran into
Some challenges we ran into were fine-tuning the model to increase prediction accuracy, finding open-source and reliable data to work with, and incorporating an algorithm into a user-friendly GUI. 

# Accomplishments that we're proud of
We are proud that we could train the model to be 60% accurate in producing a binary output: 0 (for no heart disease) and 1 (for heart disease). We are also proud that we could get our program to produce a verdict given random test cases (although, in rare cases, it can detect if a person has heart disease). 

# What we learned
We learned about a few examples of supervised learning algorithms with some emphasis on tree-based models (Decision Trees and Random Trees), linear models (Linear regression), and gradient boosting frameworks (Lightgbm). 

# What's next for HeartCheck
Hopefully, we can obtain a more accurate data source to properly train our classifier and design an intuitive and convenient user interface that allows users to interact easily with the program. Additionally, we hope to migrate from pandas to a more faster data manipulation library, like Polars.
