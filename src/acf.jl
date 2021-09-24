"""
Package: ForecastPlots

    acf(x;
        type = "cor",
        lag = Integer(ceil(10*log10(length(x)))),
        alpha = (0.95,0.99);
        plot = true)

Compute the auto-correlation or auto-covariance for an univariate series with an optional plot.

The results are normalized to preserve homoscedasticity. The distribution used to normalize the data is an approximation of a Fisher Transformation via a Normal Distribution. There is a plot recipe for the returned object, if the type is `cor` the plot will also show confidence intervals for the given alpha values.

# Arguments
- `x`: Vector or uni-dimensional DataFrame of data.
- `type`: Valid values are "cor" for correlation (default) and "cov" for convariance.
- `lag`: Maximum number of lags.
- `alpha`: A tuple with two thresholds (t1,t2) with t1 <= t2 to plot confidence intervals. The default values are 0.95 and 0.99.
- `plot`: When true displays a plot with the results.

# Returns
A CF object and optional plot

# Examples
```julia-repl
julia> x = rand(100);
acf(x; type="cor");
acf(x; type="cor", plot=false);
20-element Vector{Float64}:
 -0.07114015325321181
 -0.045271910181007916
  0.19300008480298597
```
"""
function acf(x::AbstractVector{<:Real};
             type::String = "cor",
             lag::Integer = Integer(ceil(10*log10(length(x)))),
             alpha::Tuple{AbstractFloat,AbstractFloat} = (0.95,0.99),
             plot::Bool = true)

    ccf(x,x; type, lag, alpha, plot)
    
end
