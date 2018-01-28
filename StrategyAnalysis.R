require(PerformanceAnalytics)

strategies <- read.zoo('~/Tresors/Coding/MarketAnalysis3/data.csv', sep = ',', header = TRUE, format = "%m/%d/%Y")

# charts.PerformanceSummary(strategies, main = 'Performance', ylog = TRUE)
# charts.PerformanceSummary(strategies[,c('Hold.SPY','Hold.T.Bill','SPY.UR','Hot.Sector.UR','Average')], main = "Performance")

cbind(t(as.data.frame(table.AnnualizedReturns(strategies))), t(as.data.frame(maxDrawdown(strategies))), t(as.data.frame(SortinoRatio(strategies, MAR = 0.005))))
# t(table.CalendarReturns(strategies))
# t(table.Stats(strategies))