# Jumps
Repository about jumps: how to perform them using a smartphone and estimate the jumped distance.
#### How to perform jumps:
The jump has to be performed in the following way. Each participant executes the jump with the left hand on the hip and the right one near to the hip while holding the smartphone (SP). The SP has to be on and with the Phyphox app opened. <br />
Once the participant is ready, the jump recording starts and it will be composed by three phases: <br /> 
- a static phase of a few seconds with the participant being with hands on the hips, feet in parallel stance position, and heels positioned at the zero of a meter tape; <br />
- the jumping trial triggered by a vocal command of the operator; <br />
- an after-landing second static phase. <br />
The jump was considered correct if the participant succeeded in maintaining the equilibrium after landing without using their legs/arms and keeping the feet in the parallel stance position. The heel-to-heel distance, measured using the meter tape, was considered as the reference jump length to be estimated. <br />
#### How to install and use the Phyphox app and how to position the smartphone during the jump:
You can go to Apple Store or Playstore and download "Phyphox" app. <br />
Once installed, go to the orange button and click on "Add simple experiment". Then, select the title of your experiment, sensor rate and active sensors. In this case, select accelerometer, gyroscope and magnetic field. <br />
To control the smartphone remotely, click on your experiment and select "Allow remote access". In this way, you can control the smartphone using a computer connected to the Wi-Fi of the smartphone. <br />
To this aim, once opened your experiment in Phyphox app, maintain the smartphone with the right hand near to the hip to perform the standing long jump (SLJ). The smartphone screen should be outward-oriented, with the longer side parallel to the ground.
#### Repository description
In this repository you will find three folders:
- data: in which you will find an example of the Excel file exported from Phyphox app and data used for ML models implementation
- functions: in which you will find the Matlab functions to: i) create your table to realize estimations using the existing ML models, ii) create your new model based on your data
- results: in which you will find the realized ML models. You can use them to estimate how much you jumped.
