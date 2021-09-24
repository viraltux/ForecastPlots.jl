"""
Package: ForecastPlots

    dplot(x; dlabels = ["Data","Trend","Seasonal","Remainder"])

Plot a seasonal, trend and remainder decomposition of a time series.

# Arguments
- `x`: Matrix with three columns containing sesonality, trend and remainder decomposition
- `dlabels`: String array of length four containing labels for data, seasonality, trend and remainder.

# Returns

Sesonal decomposition plot

# Examples
```julia-repl
dplot(rand(100,3))
dplot(rand(100,3), ["數據","趨勢","季節性","剩餘"])
```
"""
dplot

@userplot DPlot

@recipe function f(dp::DPlot; dlabels = ["Data","Trend","Seasonality","Remainder"])

    @assert length(dlabels) == 4 "Four labels needed for 'Data','Trend','Seasonality' and 'Remainder'"
    @assert dp.args[1] isa Matrix{<:Real} "Numerical Matrix with columns expected"
    @assert size(dp.args[1],2) == 3 "Numerical Matrix with columns expected" 
    
    seasonality = dp.args[1][:,1]
    trend = dp.args[1][:,2]
    remainder = dp.args[1][:,3]

    # subplots configuration
    legend:= false
    grid:= false
    layout := @layout [Data
                       Seasonal
                       Trend
                       Remainder]
    
    xtickfont:= font(3, "Courier")
    ytickfont:= font(3, "Courier")
    yguidefont:= font(5, "Courier")

    # reference bar
    a,b = extrema(skipmissing(values(seasonality.+
                                     trend.+
                                     remainder))); hd = b-a
    a,b = extrema(skipmissing(values(seasonality))); hs = b-a
    a,b = extrema(skipmissing(values(trend))); ht = b-a
    a,b = extrema(skipmissing(values(remainder))); hr = b-a
    mh = min(hd,hs,ht,hr)

    inset_subplots := [(1, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (2, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (3, bbox(-0.012, 0, 0.01, 1.0, :left)),
                       (4, bbox(-0.012, 0, 0.01, 1.0, :left))]

    @series begin
        subplot := 1
        yguide := dlabels[1]
        xguide := " "
        xaxis := nothing
        bottom_margin := -7Plots.mm    
        seasonality .+ trend .+ remainder
    end

    @series begin
        subplot := 2
        title := " "
        yguide := dlabels[2]
        xguide := " "
        xaxis := nothing
        #ymirror:=true
        #guide_position:=:left
        bottom_margin := -7Plots.mm    
        trend
    end

    @series begin
        subplot := 3
        title := " "
        yguide := dlabels[3]
        xguide := " "
        xaxis := nothing
        seriestype := :sticks
        bottom_margin := -7Plots.mm    
        seasonality
    end

    @series begin
        subplot := 4
        title := " "
        yguide := dlabels[4]
        seriestype := :sticks
        #bottom_margin:=0Plots.mm    
        #ymirror:=true
        #guide_position:=:left
        remainder
    end

    # Scale Bars
    @series begin
        subplot := 5
        title := " "
        background_color_inside := nothing
        framestyle := :none
        seriestype := :bar
        ylims := (0,hd)
        mh:mh
    end

    @series begin
        subplot := 6
        title := " "
        background_color_inside := nothing
        framestyle := :none
        seriestype := :bar
        ylims := (0,ht)
        mh:mh
    end
    
    @series begin
        subplot := 7
        title := " "
        framestyle := :none
        seriestype := :bar
        ylims := (0,hs)
        mh:mh
    end

    @series begin
        subplot := 8
        title := " "
        framestyle := :none
        seriestype := :bar
        ylims := (0,hr)
        mh:mh
    end

end

