require(quantmod)

##### VARIABLES #####
SymbolsBenchmark <- ('VFINX')
SymblolsRiskFree <- ('VFIIX')
SymbolsSectors <- c('FSCPX','FDFAX','FSENX','FIDSX','FSPHX','FSCGX','FSPTX','FSTCX','FSDPX','FSUTX')
SymbolsBonds <- c('VUSTX','VBMFX','VWEHX','VWAHX','VCVSX')
SymbolsUR <- c('UNRATE')
# SymbolW5000 <- c('WILL5000IND')
StartDate <- as.Date('1988-12-31')
EndDate <- as.Date('2017-09-30')
Months <- length(seq(from=StartDate, to=EndDate, by='month')) + 1
URLagMonths <- 1
SMAMonths <- 12
HotSectorSMAMonths <- 1

##### GET DATA #####
DataBenchmark <- getSymbols(SymbolsBenchmark, src='yahoo', from=StartDate, to=EndDate, auto.assign=TRUE)
DataRiskFree <- getSymbols(SymblolsRiskFree, src='yahoo', from=StartDate, to=EndDate, auto.assign=TRUE)
DataSectors <- getSymbols(SymbolsSectors, src='yahoo', from=StartDate, to=EndDate, auto.assign=TRUE)
DataBonds <- getSymbols(SymbolsBonds, src='yahoo', from=StartDate, to=EndDate, auto.assign=TRUE)
DataUR <- getSymbols(SymbolsUR, src='FRED', auto.assign=TRUE)
# DataW5000 <- getSymbols(SymbolW5000, src='FRED', auto.assign=TRUE)

# SMAs <- do.call(merge, lapply(DataYahoo, function(x) SMA(Ad(get(x)), n = MomoSMA)))
# SMAsMonthly <- SMAs[endpoints(SMAs, 'months')]

##### MERGE AND AGGREGATE DATA #####
AdjPrices <- do.call(merge, lapply(DataYahoo, function(x) Ad(get(x))))
AdjPricesMonthly <- AdjPrices[endpoints(AdjPrices, 'months')]
Indicators <- do.call(merge, lapply(DataFRED, function(x) get(x)))
IndicatorsMonthly <- Indicators[endpoints(Indicators, 'months')]
# clear unused objects
rm(list=SymbolsYahoo)
rm(list=SymbolsFRED)
# move UNRATE forward one month since data release is lagged
IndicatorsMonthly$UNRATE <- lag(IndicatorsMonthly$UNRATE, URLagMonths)
# convert FFR to monthly rate
IndicatorsMonthly$FEDFUNDS <- IndicatorsMonthly$FEDFUNDS/12

##### PUT DATA IN FINAL XTS #####
# create empty xts with dates as last day of month
FinalData <- xts(1:Months, seq(as.Date(StartDate), by='month', length=Months) - 1)
FinalData <- FinalData[-1,]
# put data in the empty xts
FinalData <- apply.monthly(merge(FinalData, IndicatorsMonthly, AdjPricesMonthly), mean, na.rm=TRUE)
FinalData <- FinalData[!is.na(FinalData$FinalData), ]
FinalData <-  FinalData[, !colnames(FinalData) %in% 'FinalData']
# add indicators
FinalData$UNRATEvsSMA <- SMA(FinalData$UNRATE, n = UnrateSMA) - FinalData$UNRATE


##### RE-ORDER DATA #####
# AdjPricesMonthly <- as.data.frame(AdjPricesMonthly)
# AdjPricesMonthly <- AdjPricesMonthly[nrow(AdjPricesMonthly):1, ]

##### WRITE CSV #####
# write.table(as.data.frame(IndicatorsMonthly), file='~/MarketAnalysis/test.csv', sep=",")
