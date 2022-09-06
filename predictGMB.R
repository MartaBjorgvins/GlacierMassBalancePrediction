#' Get data frame with predictions from measured and future data frames.
#' 
#' This function takes in data frames called winterFitData and summerFitData
#' This data is from measurements of variables in the glacier mass balance
#' regression model where the columns are in the following order:
#' first column: year(with the name "year"),
#' second column: winter/summer mass balance(with the name "bw" and "bs"),
#' other columns: variables(one or more) in the linear regression model.
#' 
#' Also data frames called winterPredData and summerPredData that keep data
#' for variables in the glacier mass balance regression models but for
#' the prediction time period. The columns should be in the following order:
#' first column: year(with the name "year"),
#' other columns: variables(one or more) in the linear regression model.
#' 
#' The function returns a data frame of predictions where the columns are in
#' the following order:
#' year, winter prediction, summer prediction, net prediction and
#' accumulated net prediction.
#' 
#' @param winterFitData data frame with variables used to fit the winter model.
#' @param summerFitData data frame with variables used to fit the summer model.
#' @param bestdataYearsMark an integer number that represents the year where
#' the more accurate measurements of the glacier mass balance started.
#' @param winterPredData data frame with variables used to make 
#' the winter predictions.
#' @param summerPredData data frame with variables used to make 
#' the summer predictions.
#' @return returns a data frame of predicted timelines.
#' @export


PredictGMB <- function
(winterFitData,summerFitData,bestDataYearsMark,winterPredData,summerPredData){
  require("dplyr")
  require("purrr")
  
  
  wfdim <- dim(winterFitData)
  sfdim <- dim(summerFitData)
  wpdim <- dim(winterPredData)
  spdim <- dim(summerPredData)
  
  if (wfdim[1] != sfdim[1] | wpdim[1] != spdim[1]) {
    return("Summer and winter data (both fit and predict) timelines must be of the same length")
  }
  
  if (missing(bestDataYearsMark)) { #sets Q_bw and Q_bs as identity matrices
    Q_bw <- diag(wfdim[1])
    Q_bs <- diag(sfdim[1])
  } else {
    #Find Q_bw, the weight matrix for the weighted winter regression model
    WFitBest <- winterFitData %>% filter(year >= bestDataYearsMark)
    WFitBest <- select(WFitBest, -year)
    winterlmBest <- lm(bw ~., WFitBest)

    WFitNotBest <- winterFitData %>% filter(year < bestDataYearsMark)
    WFitNotBest <- select(WFitNotBest, -year)
    predBwNotBest <- predict(winterlmBest,WFitNotBest)
    
    # now we calculate the residual standard error(RSE) for predBwNotBest
    # and the ratio between that RSE and the winterlmBest RSE.
    SSEbwpred <- sum((WFitNotBest$bw-predBwNotBest)**2)
    k_w<-length(winterlmBest$coefficients)-1
    n_w<-length(predBwNotBest)
    RSEbwpred <- sqrt(SSEbwpred/(n_w-(1+k_w)))
    q_w <-RSEbwpred/sigma(winterlmBest) # sigma(lm) := RSE of a lm.
    
    Q_bw <- diag(c(rep(q_w**2,n_w),rep(1,dim(WFitBest)[1])))
    
    #Find Q_bs, the weight matrix for the weighted summer regression model
    SFitBest <- summerFitData %>% filter(year >= bestDataYearsMark)
    SFitBest <- select(SFitBest, -year)
    summerlmBest <- lm(bs ~., SFitBest)
    SFitNotBest <- summerFitData %>% filter(year < bestDataYearsMark)
    SFitNotBest <- select(SFitNotBest, -year)
    predBsNotBest <- predict(summerlmBest,SFitNotBest)
    
    # now we calculate the residual standard error(RSE) for predBsNotBest
    # and the ratio between that RSE and the summerlmBest RSE.
    SSEbspred <- sum((SFitNotBest$bs - predBsNotBest)**2)
    #calculate residual standard error
    k_s<-length(summerlmBest$coefficients)-1
    n_s<-length(predBsNotBest)
    RSEbspred <- sqrt(SSEbspred/(n_s-(1+k_s)))
    q_s <- RSEbspred/sigma(summerlmBest) # sigma(lm) := RSE of a lm.
    
    Q_bs <- diag(c(rep(q_s**2,n_s),rep(1,dim(SFitBest)[1])))
  }
  # X matrix for the winter regression with an vector of ones and
  # the variables
  X_w <- as.matrix(cbind(rep(1,wfdim[1]),winterFitData[,3:wfdim[2]]))
  bw <- winterFitData$bw
  # B_bw is the estimate of the parameters in the winter regression
  B_bw <- solve(t(X_w)%*%solve(Q_bw)%*%X_w)%*%t(X_w)%*%solve(Q_bw)%*%bw
  
  # X matrix for the winter regression with an vector of ones and
  # the variables
  X_s <- as.matrix(cbind(rep(1,sfdim[1]),summerFitData[,3:sfdim[2]]))
  bs <- summerFitData$bs
  # B_bs is the estimate of the parameters in the summer regression
  B_bs <- solve(t(X_s)%*%solve(Q_bs)%*%X_s)%*%t(X_s)%*%solve(Q_bs)%*%bs
  
  #Predict the glacier mass balance from PredData:
  winterMatrix <- data.matrix(winterPredData[,colnames(winterPredData)!="year"])
  X_wPred <- cbind(rep(1,wpdim[1]),winterMatrix)
  WPred <- X_wPred%*%B_bw
  summerMatrix <- data.matrix(summerPredData[,colnames(summerPredData)!="year"])
  X_sPred <- cbind(rep(1,spdim[1]),summerMatrix)
  SPred <- X_sPred%*%B_bs
  NPred <- WPred + SPred
  accumNPred <- NPred %>% accumulate(`+`)
  
  data.frame(
    year = summerPredData[,colnames(summerPredData)=="year"],
    WinterPrediction = WPred,
    SummerPrediction = SPred,
    NetPrediction = NPred,
    accumNetPredic = accumNPred)
}
