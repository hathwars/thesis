# Princeton Senior Thesis
Thesis advised under Dr. Pillow in understanding lapses in animal perception

Using the MATLAB Palamedes toolbox from Prins et. al (2009), the objective was to understand the best model for spontaneous errors in rodent perceptual decision-making experiments.

The PALAMEDES folder includes multiple scripts from the PALAMEDES library that 
I used to write my models.  The observer_models folder  includes lapse and non-lapse versions of the probit and logit ideal observer models.  Finally,
the figures folder includes figures for each of the models above.  All of these are on simulated data, but work well on the mouse data as well.

Here is the output, showing that the models are able to recover the handpicked parameters using simulated data.

>> logit_model_with_lapse


Threshold: -0.004
Slope: 0.975
Guess Rate: 0.500
Lapse Rate: 0.067



Goodness-of-fit by Monte Carlo: 0.5900
Goodness-of-fit by chi-square approximation: 0.3621

>> probit_model_with_lapse


Threshold: -0.319
Slope: 0.593
Guess Rate: 0.500
Lapse Rate: 0.057



Goodness-of-fit by Monte Carlo: 0.2300
Goodness-of-fit by chi-square approximation: 0.1770

The real parameters were

Threshold: 0
Slope: 1
Guess Rate: 0.500
Lapse Rate: 0.05

