# Glacier mass balance (GMB) prediction with a weighted linear regression model

The motive for this project was making future predictions of the glacier mass balance (GMB) of Vatnajökull Glacier. The prediction are made by first fitting a weighted linear regression model with climate covariate to historical glacier mass balance data, then future values of the covariates from climate models are fed into the model to make future predictions. The method and the corresponding R code are made available to ensure that future predictions for other glaciers can be made. 

Due to a misunderstanding and time constraints it was not possible to extract future values of the covariates from climate models to make GMB predictions. 
Therefore, simulated data are used instead of data from climate models. The simulation is only based on the fact that the historical data follow a normal distribution and have the same mean and standard deviation.

The project is important as it presents a method that others can use, despite the fact that climate model covariates for linear regression model for Vatnajökull Glacier’s winter and summer mass balance are not currently available. 

In this project, a weighted linear regression model is used to predict the future mass balance of a glacier. The reason why it is weighted is that, in the case of GMB data, it is common to have two or more data sources that have different measurement variance. The data used in this project to fit the model are combined data from the Harmonie model, which is a snowfall model dating back to 1981, and data from measurements starting in 1992.

The idea behind the prediction model is to find time series of weather factors from climate and ocean models that correlate with the GMB and select the once that jointly give the smallest prediction error.

The algorithm can use that input variables from new climates and ocean models when they are created.
I hope that parties working on GMB and climate change projects can take advantage of this method.

See in more detail how to use the method for glaciers other than Vatnajökull Glacier here in the last section called "How to use this project".

### The glacial year
The glacial year is defined from the start of October to the end of September. In this project the glacial year is named after the year that the glacial year ends on, that is also the bigger part of the glacial year.
In the preliminary work for this project, when working with great selection of covariates when finding a good linear regression models, all the covariate that correspond to the period of September to December were give a year index that was shifted forward by one year so that they were consistent with the glacial year.

## The data
The covariates that were used in the final models for the winter, summer and net mass balance of Vatnajökull Glacier in Iceland (bw, bs and bn), are

 - Air temperature in Stykkishólmur in Breyðafjörður Iceland for July and February

 - The Atlantic Multidecadal Oscillation (AMO) in May

 - The sea surface temperature (SST) on the area south-west of Icelad in May 

 - The Greenland Blocking Index (GBI) in November

 - GBI winter mean
 
The covariates that were used in the final models were selected through an exhaustive search where that was possible, forward selection and sequential replacement. The best model from the method where compered by BIC, sigma and adjusted $R^2$ and the models that performed the best in that comparison were chosen. 

### The future variables and their scaling
When future data from climate models are used, it is highly likely that each covariates needs to be scaled such that it matches better the historical data so that, after the scaling, they can be used directly in the linear regression. To make this possible the climate covariates need to begin in the past so they can be compared to the historical data. In this project a fake future data were simulated from the historical data, thus, scaling was unnecessary as the simulation was based on the mean and standard deviation of the historical data.

### Input
The input in the project are the data described above in the data section. We read it in as one excel file with the name "AllData.xlsx". AllData has multiple sheets with data, one sheet for the winter data and one for the summer data, they include the glacier mass balance and the variables used in the linear regression model for winter and summer, these two sheets of data are used to fit the linear regression models. It has other two sheets with the prediction data for summer and winter that only has the variable data for the linear regression models and they are used to do the prediction.

Here is a table that shows what data are in what sheet in the data file.

| Sheet name | winterFitData | summerFitData | winterPredictData | summerPredictData |
|---|---|---|---|---|
| Variable 1 | year | year | year | year |
| Variable 2 | bw | bs | AirT_Feb | AirT_Jul |
| Variable 3 | AirT_Feb | AirT_Jul | GBINov | AMOMay |
| Variable 4 | GBINov | AMOMay | GBIwinter | sstSW_May |
| Variable 5 | GBIwinter | sstSW_May |  |  |

### Output
The Output is a table with the prediction. It contains predictions of winter, summer and net mass balance of Vatnajökull Glacier along with the accumulative predicted net mass balance. These predictions can be downloaded as an excel or csv file. More detailed instructions are given in the program setup section below. The markdown html file will also include graphs of the predictions along with graphs of the original mass balance observations.

## The model

The statistical models for the winter and summer GMB of Vatnajökull Glacier used in this project are given below. To model the net GMB, the outcome of the summer GMB prediction and the winter GMB prediction are added together. The statistical models are 

$$
W_t = \beta_0 + \beta_1 AirTFeb_t + \beta_2 GBINov_t + \beta_3 GBIwinter_t + \varepsilon_t
$$

and

$$
S_t = \beta_0 + \beta_1 AirTJul_t + \beta_2 AMOMay_t + \beta_3 SeaTSWMay_t + \varepsilon_t
$$

where

 - $W_t$: Winter mass balance in year $t$
 - $S_t$: Summer mass balance in year $t$
 - $\beta_i, i=0,...,3$ are unknown parameters and $\beta_0$ is an intercept
 
 and the predictors are
 
 - $AirTFeb_t$: The mean of the air temperature in February in year $t$
 - $AirTJul_t$: The mean of the air temperature in July in year $t$
 - $GBINov_t$: The Greenland Blocking monthly Index for November in year $t$
 - $GBIwinter_t$: The mean of the Greenland Blocking monthly Index over the winter season in year $t$
 - $AMOMay_t$: The Atlantic Multidecadal Oscillation in May in year $t$
 - $sstSWMay_t$: The sea surface temperature south-west of Iceland in May in year $t$
 - $\varepsilon_t$: The error term

The net GMB is calculated with $N_t = W_t + S_t$.

When working with glacier mass balance data, it is often the case that the older data are not as accurate as the more recent data because the mass balance is not as accurately measured or it is calculated from simulated values(re-analysis??). In order to take into account knowledge from different data sources, then the observations that are more accurate are given more weight by using a weighted linear regression. The mass balance data of Vatnajökull Glacier is combination of direct observation and simulated values (re-analysis?), and thus, it was anticipated that the standard deviation of the simulated data was higher than of the direct observation. This was taken into account by forming a weight matrix. The weight matrix is a diagonal matrix that stores information about the heteroscedasticity of the mass balance data. To find the size of the scaling factor, the estimate of the standard deviation of the error term in the linear model when using only the measured data is computed and the standard deviation of the error between the linear model and the data from the Harmonie model is computed. The ratio between these two standard deviations is found and used as the diagonal elements in the weight matrix which coincide with part of the data coming from the simulation. Thus, the model parameters are estimated using a weighted linear regression.

The conclusion was that the ratio between the standard deviation of the error term in the linear model for winter mass balance was 1.39 and for summer mass balance was 1.46.

The covariance matrix of the joint observations is given by 

$$
\Sigma = \sigma^2 Q
$$

where $Q$ is the diagonal weight matrix and $\sigma^2$ is variance of the direct observations. The diagonal elements of $Q$ that correspond to the direct observations are equal to 1, while the other elements are equal to $1.39^2$ for the winter mass balance and equal to $1.46^2$ for the summer mass balance. 

The model parameters are estimated with weighted linear regression that takes the weight of the $Q$ matrix into account,  

$$
\hat{\beta}=(X^TQ^{-1}X)^{-1}X^TQ^{-1}y.
$$


## Program setup
This project was created using R (version 4.1.0) and RStudio.

If you are new to R I recommend following this [Install R and RStudio – A Step-by-Step Guide for Beginners](https://techvidvan.com/tutorials/install-r/) for instructions.
The steps are easy to follow and well explained, but there are a lot of ads on the site which is unfortunate.

Otherwise, the programs can be accessed from the following websites:

Download and install R from [The Comprehensive R Archive Network](https://cran.r-project.org/) web page.	
The web page provides three links for downloading and installing R. Follow the link that describes your operating system, that is Windows, Mac or Linux.

And to download RStudio go to the [RStudio Desktop download](https://www.rstudio.com/products/rstudio/download/#download) web page and choose the right link for your operating system.

### Install R packages
Packages used in this project need to be installed before you run the main file.
To install them all, you copy the following code and paste it in the console window in your RStudio. If you have them already installed, you can skip this part and instead check if they need to be updated. You do that by pushing the Update button in the Package window in RStudio and find these packages there and select them and then pressing the Install Updates button in that window.

```R
install.packages("excel.link")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("patchwork")
install.packages("dplyr")
install.packages("purrr")
install.packages("writexl")
```

### Download files
The next step is to download the project repository:

 - Go to the green "Code" button in the right top corner of this GitHub repository page and press Download ZIP.
 - Extract the ZIP file to a folder at your preferred location.

### Open the project in RStudio
In your folder you can open the project in RStudio by clicking the R project GMBPrediction or you can start with opening the RStudio desktop app and then pressing the project button and pressing open project and there you search in you computer for the project GMBPrediction and press it to open it in RStudio.

### Runing the project
Next you open the `GMBPredictionMainfile.Rmd` file in RStudio. It is found in the Files window in RStudio.

There you can run the project by pressing the Knit button and then pressing Knit to HTML.

The `GMBPredictionMainfile.Rmd` file is a markdown file so the knighting will make a HTML file with graph of the original data and graphs of the outcome of the prediction, it will also be saved and stored in the same folder as the project as both csv file and excel file. If you don't want the tables with the outcome to be saved as ether csv or excel file you can "comment" the code for exporting the data out by putting "#" symbol in front of the code in the main file file that you don't want to be evaluated. If you do not wish to export the outcome table at all it is best to change the chunk option by writing "FALSE" in steed of "TRUE" where you see "eval=TRUE".


## How to use this project
In this project, a data related to Vatnajökull Glacier is used. That is, data that comes from measurements and historical data for the GMB in Vatnajökull Glacier and data from variables that were found out with stepwise methods together with other methods that would be the baits that give a predictive value for the GMB of Vatnajökull Glacier. 

The idea of this document is to show a method of predicting GMB whether for Vatnajökull Glacier or other glaciers. Then you can use the document as the skeleton and read in the data that you are interested in working with at any given time and run the commands that are suitable for the task in question, but skip what is not suitable.

If you want to skip any code you can write this symbol # in front of the code and it will not be seen as a code but as a comment. Or if you want to skip whole chunks then you can change the chunk option by writing "eval=FALSE" into the curly brackets after a comma that needs to be in between the name of the code chunk and the code option.

All regular text and comment in the Rmarkdown file both inside and outside of the code chunks can also be changed or removed if you want to use this markdown file for your GMB prediction project.

You can also just use the function `predictGMB.R` which the main file uses to get the predicted values.
The R function `predictGMB.R` keeps the weighted linear regression and is a function that takes in the data and returns the prediction as an R data frame. The file `predictGMB.R` contains a description of how to use the function.

