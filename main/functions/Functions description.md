# Function description
### Here there are the descriptions of each single function and the how to use them depending on the type of work.
***BlandAltmanGVersion:*** use this function if you want to create a Bland and Altman plot following the Giavarina [2015] description. If you want to use it, you need the data acquired by both tape meter and smartphone. <br /><br />
***do_align_v2:*** function used inside "estimate_jump_v2.m" function. Download it to run correctly your script.<br /><br />
***estimate_jump_v2:*** function that allows the extraction of data from Excel file of Phyphox app. After data extraction, the function aligns the accelerometer and gyroscope, filters and extracts all the features.<br /><br />
***feature_selection:*** function that you can use if you want to implement a new model using your dataset.<br /><br />
***get_features_GPL_v2:*** function that allows the feature extraction used in the paper starting from the filtered acceleration data coming from Phyphox app. <br /><br />
***get_timings_v2:*** function that allows the identification of the onset and take-off instants. It give also the velocity signal as output. <br /><br />
***jump_estimate:*** function used to estimate b_jump obtained under the hypothesis of projectile motion. <br /><br />
***normalize_set:*** function used to normalize your dataset in order to use the models that are in "results" folder. <br /><br />
***readPhyphox_v2:*** function inside "estimate_jump_v2" able to extract the data coming from Excel file exported from Phyphox app. You can both filter the data and align gyroscope and accelerometer signals.<br /><br /><br /><br />


#### Work creating your own training and test sets
In this case the functions that you can use are: estimate_jump_v2 and feature_selection (and related features). After that, you create your dataset and divide it into training and test sets and apply the Regression Learner App.<br /><br /><br /><br />

#### Work using your data and the realized models
In this case you need to use normalize_set after having created your dataset in order to normalize data. Then, in the "results" folder, you can use your dataset as input of the model.To normalize models, use data_with_models.mat contained in "results" folder.
