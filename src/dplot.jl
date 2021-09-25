"""
Package: ForecastPlots

    dplot(x; dlabels = ["Data","Trend","Seasonal","Remainder"])

Plot a seasonal, trend and remainder decomposition of a time series.

# Arguments
- `x`: Matrix with three columns containing sesonality, trend and remainder decomposition
- `dlabels`: String array of length four containing labels for data, seasonality, trend and remainder.

# Returns

Sesonal decomposition plot with scale bars

# Examples
```julia-repl
dplot(randn(100,3))
dplot(randn(100,3); labels = ["數據","趨勢","季節性","剩餘"])
dplot(rand(100,3),now()-Day(99):Day(1):now())
```
"""
function dplot(x::Matrix{<:T}, t=1:size(x,1);
               dlabels = ["Data","Trend","Seasonality","Remainder"], kw...) where T<: Real

    @assert length(dlabels) == 4 "Four labels needed for 'Data','Trend','Seasonality' and 'Remainder'"
    @assert x isa Matrix{<:Real} "Numerical Matrix with columns expected"
    @assert size(x,2) == 3 "Numerical Matrix with columns expected" 
    
    seasonality = x[:,1]
    trend = x[:,2]
    remainder = x[:,3]

    xtickfont = font(3, "Courier")
    ytickfont = font(3, "Courier")
    yguidefont = font(5, "Courier")

    # reference bar
    a,b = extrema(skipmissing(values(seasonality.+
                                     trend.+
                                     remainder))); hd = b-a
    a,b = extrema(skipmissing(values(seasonality))); hs = b-a
    a,b = extrema(skipmissing(values(trend))); ht = b-a
    a,b = extrema(skipmissing(values(remainder))); hr = b-a
    mh = min(hd,hs,ht,hr)

    inset_subplots  = [(1, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (2, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (3, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (4, bbox(-0.012, 0, 0.01, 1.0, :left))]

    layout = @layout [Data
                      Seasonal
                      Trend
                      Remainder]

    rect(w, h, x, y) = Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])

    ttype = eltype(t) <: TimeType
    sbd = 10
    sbx = ttype ? Dates.value(t[1]) - (sbd+1)*Dates.value(t[2]-t[1])  : -sbd
    sbw = ttype ? sbd*Dates.value(t[2]-t[1])÷4 : 10÷4

    sbc = :gray

    p1 = plot(t,seasonality .+ trend .+ remainder;
              yguide = dlabels[1], xguide = "", 
              ytickfont, yguidefont,
              bottom_margin = -5Plots.mm,
              legend = false, grid = false,
              kw...,
              xticks = false)

    p1 = plot!(rect(sbw, hr,sbx, minimum(seasonality .+ trend .+ remainder));
               seriescolor = :grey,
               linewidth = 0,
               label = nothing)

    p2 = plot(t,trend;
              yguide = dlabels[2], xguide = "", title = "", xticks = false,
              ytickfont, yguidefont,
              bottom_margin = -5Plots.mm,
              legend = false, grid = false)

    p2 = plot!(rect(sbw, hr, sbx, minimum(trend));
               seriescolor = :grey,
               linewidth = 0,
               label = nothing)

    p3 = plot(t,seasonality;
              yguide = dlabels[3], xguide = "", title = "", xticks = false,
              ytickfont, yguidefont, seriestype = :sticks,
              bottom_margin = -5Plots.mm,
              legend = false, grid = false)

    p3 = plot!(rect(sbw, hr, sbx, minimum(seasonality));
               seriescolor = :grey,
               linewidth = 0,
               label = nothing)

    p4 = plot(t,remainder;
              yguide = dlabels[4], xguide = "", 
              xtickfont, ytickfont, yguidefont, seriestype = :sticks,
              legend = false, grid = false,
              kw...,
              title = "")
              
    p4 = plot!(rect(sbw , hr, sbx, minimum(remainder));
               seriescolor = :grey,
               linewidth = 0,
               label = nothing)

    plot(p1,p2,p3,p4; layout)

end

