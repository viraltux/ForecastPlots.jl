# ForecastPlots

Collection of plot functionalities for time series analysis. The available plots are:

- `acf`:     Auto-Correlation plot
- `candle`:  Candelstick plot for stock prices
- `ccf`:     Cross-Correlation plot
- `dplot`:   Decomposition plot for Data, Trend, Seasonality and Remainder.
- `fplot`:   Multivariate forecasting plots with prediction intervals.
- `pacf`:    Partial Auto-Correlation plot
- `splot`:   Seasonal plot, similar to `monthplot` in R.

<img src="./docs/src/images/candle.png">

## Examples

```julia
using ForecastPlots
using RCall, Smoothers

R"x = as.numeric(co2)"
@rget x

dplot(stl(x,12))
```

<img src="./docs/src/images/dplot-stl.png">
	
[![Build Status](https://github.com/viraltux/ForecastPlots.jl/workflows/CI/badge.svg)](https://github.com/viraltux/ForecastPlots.jl/actions)
[![Coverage](https://codecov.io/gh/viraltux/ForecastPlots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/viraltux/ForecastPlots.jl)
