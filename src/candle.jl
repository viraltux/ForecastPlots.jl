"""
Package: ForecastPlots

    candel(x, t, args...; colors = (:green, :red), kw...)

Plot a candlestick for stock prices

# Arguments
- `x`: Matrix with four columns for Open, High, Low and Close values.
- `t`: Vector with time units, it defaults to 1:size(x,1)
- `args...`: `plot` arguments
- `colors`: Tuple with the up and down color symbols, it defaults to (:green,:red)
- `kw...`: `plot` keyword arguments

# Returns
Candle plot

# Examples
```julia-repl
using MarketData

x = yahoo(:INTC)
last_month_intc = values(x)[end-30:end,1:4]
candle(last_month_intc)
candle(last_month_intc,timestamp(x)[end-30:end])
candle(last_month_intc,timestamp(x)[end-30:end]; colors=(:white,:black), title = "INTC")
```
"""
function candle(x::Matrix{<:Real},t=1:size(x,1); colors=(:green,:red), kw...)

    @assert length(colors) == 2 "Two colors required"
    @assert eltype(colors) == Symbol "'colors' must be symbols e.g. (:white,:black)"
    @assert colors[1] != colors[2] "'colors' must be different"
    
    plot(t,repeat([missing],size(x,1));labels=nothing,kw...)

    ttype = eltype(t) <: TimeType
    t = ttype ? Dates.value.(t) : t
    woc = ttype ? (t[2]-t[1])/2  : 1/2
    whl = woc/10
    
    rect(w, h, x, y) = Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])
    
    for (i,ohlc) in zip(t,eachrow(x))

        # High / Low
        plot!(rect(whl,ohlc[2]-ohlc[3],i,ohlc[3]);
              seriescolor = :black,
              linewidth = 0,
              label = nothing)

        # Open / Close
        plot!(rect(woc,ohlc[4]-ohlc[1],i-woc/2,ohlc[1]);
              seriescolor = ohlc[1]<ohlc[4] ? colors[1] : colors[2],
              linewidth = 0,
              label = nothing)

    end
    current()
end
