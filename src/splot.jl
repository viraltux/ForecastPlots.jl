"""
Package: ForecastPlots

    splot(x, labels; plot = true)

Plot a seasonal plot of x based on the parameter `labels`

# Arguments
- `x`: Regular timed observations
- `labels`: This parameter accepts Integer, String and Vector values. 
            - When an Integer the labels are 1:labels.
            - When a Vector the sorted labels are specified within.
            - When a String it accepts values "month", "day" and "quarter"m, by default the first value of x to fall in "Jan", "Mon" or "Q1", if other initial values are required labels must be specified in a vector.
- `plot`: When `true` the splot is displayed, otherwise only the seasonal per column matrix is returned.

# Returns

Matrix with seasonal data by column with an optional  plot

# Examples
```julia-repl
splot(rand(120),"month");
splot(rand(120),"quarter");
splot(rand(120),"day"; plot=false)
18×7 Matrix{Union{Missing, Float64}}:
 0.799164   0.214773   0.957464   0.969107   0.5886    0.153288   0.298444
 0.631211   0.539124   0.728887   0.235045   0.398699  0.492781   0.332502
 0.691047   0.473517   0.834303   0.0316447  0.208999  0.231782   0.00797575
```
"""
function splot(x::AbstractVector{<:T},
               labels::Union{Integer, String, AbstractVector{String}} = 12;
               plot::Bool = true, kw...) where T<:Real

    day_labels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    month_labels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    quarter_labels = ["Q1","Q2","Q3","Q4"]

    if isa(labels, String)
        if labels == "month"
            labels = month_labels
            season = 12

        elseif labels == "day"
            labels = day_labels
            season = 7
            
        elseif labels == "quarter"
            labels = quarter_labels
            season = 4
        else
            @error "Only 'month', 'day' and 'quarter' are valid string values for `labels`"
        end
    end

    if isa(labels, Vector)
        labels = labels
        season = length(labels)
    end

    if isa(labels, Integer)
        season = labels
        labels = 1:season
    end

    ls = ceil(length(x)/season)

    # padding to assure correct size
    x = vcat(x,repeat([missing],Int(season*ls-length(x))))

    # labels for seasons 
    xticks = (ls/2:ls+1:length(x)+ls, labels)
    
    x = Array(reshape(x,:,Int(length(x)/season))')

    # season plots
    xs = vcat(x, Array(repeat([missing],inner=season)') )
    xs = reshape(xs,:,1)

    # season means
    m = mapslices(mean ∘ skipmissing, x, dims=1)
    m = repeat(m, size(x)[1] )
    m = vcat(m, Array(repeat([missing],inner=season)') )
    m = reshape(m,:,1)
        
    if plot
        Plots.plot(xs; legend=false, grid = false, xticks, kw...)
        display(Plots.plot!(m; legend=false, grid = false, kw...))
    end

    return reshape(xs,:,season)[1:end-1,:]

end


