# Height Democratization of Jump Height estimates exploiting Smartphone IMU measures 

## Description

This repository contains the main code used for the jump height democratization analysis performed for the paper "*A Countermovement Jump Height Estimate Democratization Approach through Smartphone Measures*" by Mascia and Camomilla. 

The code here shared is so divided:

1. Feature extraction (written in GNU Octave/MATLAB language);
2. Feature selection (written in R language)

## Feature Extraction
The code extracts all those features which were biomechanically related to the jump itself (Dowling and Vamos, 1993; Mascia and Camomilla, 2021). Moreover, they included the three *central frequencies* extrapolated through Variational Mode Decomposition (Dragomiretskiy and Zosso, 2014). 

It must be noticed that the anthropometric features, described by four skinfold lengths, were not automatically computed through the presented algorithm, since they were manually measured by an external operator.

All the features, along with their description are listed in the table below.

|     ID     |     Feature                                                     |     Measure unit    |     Description                                                                                     |
|------------|-----------------------------------------------------------------|---------------------|-----------------------------------------------------------------------------------------------------|
|     Bi     |     Biceps skinfold                                             |     mm              |     Self-explanatory                                                                                |
|     Tr     |     Triceps skinfold                                            |     mm              |     Self-explanatory                                                                                |
|     Sc     |     Subscapular skinfold                                        |     mm              |     Self-explanatory                                                                                |
|     Ic     |     Superior-Anterior Iliac Crest skinfold                      |     mm              |     Self-explanatory                                                                                |
|     h<sup>SP</sup>    |     Jump height                                                 |     m               |     Height computed via TOV from a<sup>SP<sup>                                                                |
|     A      |     Unweighting phase duration                                  |     s               |     [t<sub>0</sub>, t<sub>UB</sub>]                                                                                       |
|     b      |     Minimum acceleration                                        |     m / s<sup>2</sup>          |     a(<sub>a, min</sub>)                                                                                      |
|     C      |     Time from minimum to maximum acceleration time              |     s               |     [t<sub>a, min</sub>, t<sub>a, max</sub>]                                                                              |
|     D      |     Main positive impulse time                                  |     s               |     Positive acceleration from t<sub>UB</sub>   until the last positive sample prior t<sub>TO</sub>                       |
|     e      |     Maximum acceleration                                        |     m / s<sup>2</sup>          |     a(t<sub>a, max</sub>)                                                                                      |
|     F      |     Time from acceleration positive peak to   take-off          |     s               |     [t<sub>a,max</sub>, t<sub>TO</sub>]                                                                                   |
|     G      |     Ground duration                                             |     s               |     [t<sub>0</sub>, t<sub>TO</sub>]                                                                                       |
|     H      |     Time from minimum acceleration to the end of B              |     s               |     [t<sub>a, min</sub>, t<sub>BP</sub>]                                                                                   |
|            |                                                                 |                     |                                                                                                     |
|     k      |     Acceleration at the end of the braking phase                |     m / s<sup>2</sup>          |     a(t<sub>BP</sub>)                                                                                          |
|     J      |     Time from negative peak velocity to the end of B          |     s               |     [t<sub>v, min</sub>, t<sub>BP</sub>]                                                                                  |
|     l      |     Negative peak power                                         |     W / kg          |     P(t<sub>P, min</sub>)                                                                                      |
|     M      |     Positive power duration                                     |     s               |     Self-explanatory                                                                                |
|     n      |     Positive peak power                                         |     W / kg          |     P(t<sub>P, max</sub>)                                                                                      |
|     O      |     Time distance between positive peak power and   take-off    |     s               |     [t<sub>P, max</sub>, t<sub>TO</sub>]                                                                                  |
|     p      |     Mean slope between acceleration peaks                       |     au              |     p = (e - b) / C                                                                                 |
|     q      |     Shape factor                                                |     au              |     Ratio between the area under the curve along D   and the one of a rectangle of sides D and e    |
|     r      |     Impulse ratio                                               |     au              |     r = b / e                                                                                       |
|     s      |     Minimum negative velocity                                   |     m / s           |     v(t<sub>v, min</sub>)                                                                                      |
|     u      |     Mean Concentric Power                                       |     W / kg          |     Self-explanatory                                                                                |
|     W      |     Power peaks delta time                                      |     s               |     [t<sub>P, min</sub>, t<sub>P, max</sub>]                                                                              |
|     z      |     Mean Eccentric Power                                        |     W / kg          |     Self-explanatory                                                                                |
|     f<sub>1</sub>     |     High central frequency                                      |     Hz              |     Highest central frequency computed through   VMD, associated with wobbling tissues and noise    |
|     f<sub>2</sub>     |     Middle central frequency                                    |     Hz              |     Middle central frequency computed through VMD,   associated with wobbling tissues               |
|     f<sub>3</sub>     |     Low central frequency                                       |     Hz              |     Lowest central frequency computed through VMD,   associated with the jump proper                |

<p align = center>
<b>Table 1</b>: Detailed explanation of each of the analyzed features. Capital letters are for timings, small letters for the other parameters. Legend: au = arbitrary units; t<sub>0</sub> = jump onset time; t<sub>UB</sub> = unbraking-braking phase transition time; t<sub>BP</sub> = braking-propulsion phase transition time; t<sub>TO</sub> = take-off time; t<sub>a, min</sub> = minimum acceleration time; t<sub>a, max</sub> = maximum acceleration time; t<sub>v, min</sub> = minimum velocity time; t<sub>P, min</sub> = minimum power time; t<sub>P, max</sub> = maximum power time.
</p>

<figure align = "center">
<img src="./common/features.png" height=600>
</figure>
<p align ="center">
<b>Figure 1</b>. Visual depiction, on a jump representative of the population, of the features selected. Acceleration-related features are shown in the top panel, while power-related ones in the bottom panel. The vertical dotted lines in the top panel represent jump-phases transitions (McMahon et al., 2019): the weighting phase lasts from the beginning to t<sub>0</sub> (jump onset); the unweighting phase lasts from t<sub>0</sub> to t<sub>UB</sub>; the braking phase lasts from t<sub>UB</sub> to t<sub>BP</sub>; the propulsion phase lasts from t<sub>BP</sub> to t<sub>TO</sub>. Notice that t<sub>UB</sub> and t<sub>v, min</sub> coincide. For the sake of clarity, only the former was depicted. Feature i cannot be represented as its numerical value was derived from further computations. The meaning of each feature is detailed in Table 1.
</p>

## Feature Selection

The best subset of features was chosen according to the best subset regression method (Hocking and Leslie, 1967). For each subset composed of $N$ features ($N = 1, \dots, M$), the combination giving the highest $R^2$ versus the gold standard values was stored. Then, a k-fold cross-validation paradigm ($k = 10$) was used to stress model generalization on each of the $M$ models obtained. Consequently, the best model among these $M$ was selected as the one presenting the lowest cross-validation error. For each feature included as a predictor in the selected model, the variance inflation factor ($VIF$) metrics was computed to face possible multicollinearity (Marquardt, 1970). A predictor presenting a $VIF > 10$ was considered linearly dependent to some of the others (Marquardt, 1970). Accordingly, if $VIF$ was above threshold, predictors were removed from the model, which was evaluated again excluding the specific multicollinear predictor until all remaining predictors satisfied the inclusion criteria ($VIF < 10$).

## References
Dowling, J. J., and Vamos, L. (1993). Identification of Kinetic and Temporal Factors Related to Vertical Jump Performance. Journal of Applied Biomechanics, 9(2), 95–110. https://doi.org/10.1123/jab.9.2.95

Dragomiretskiy, K., and Zosso, D. (2014). Variational Mode Decomposition. IEEE Transactions on Signal Processing, 62(3), 531–544. https://doi.org/10.1109/TSP.2013.2288675

Dragomiretskiy, K., and Zosso, D. (2014). Variational Mode Decomposition. IEEE Transactions on Signal Processing, 62(3), 531–544. https://doi.org/10.1109/TSP.2013.2288675

Marquardt, D. W. (1970). Generalized Inverses, Ridge Regression, Biased Linear Estimation, and Nonlinear Estimation. Technometrics, 12(3), 591. https://doi.org/10.2307/1267205

Mascia, G., and Camomilla, V. (2021). An automated Method for the Estimate of Vertical Jump Power through Inertial Measurement Units. ISBS Proceedings Archive, 39(1). https://commons.nmu.edu/isbs/vol39/iss1/74