module ForecastPlots

using Distributions, LinearAlgebra, Statistics
using Plots, Dates

include("splot.jl")
export splot

include("dplot.jl")
export dplot

include("acf.jl")
include("ccf.jl")
include("pacf.jl")
export acf, ccf, pacf

include("candle.jl")
export candle

include("fplot.jl")
export fplot 


"""
Package: ForecastPlots

Collection of plot functionalities for time series analysis. The available plots are:

- `acf`:     Auto-Correlation plot
- `candle`:  Candelstick plot for stock prices
- `ccf`:     Cross-Correlation plot
- `dplot`:   Decomposition plot for Data, Trend, Seasonality and Remainder.
- `fplot`:   Multivariate forecasting plots with with prediction intervals.
- `pacf`:    Partial Auto-Correlation plot
- `splot`:   Seasonal plot, similar to `monthplot` in R.
"""
ForecastPlots

end



