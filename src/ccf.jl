"""
Package: ForecastPlots

    ccf(x1::{AbstractVector,DataFrame},
        x2::{AbstractVector,DataFrame};
        type = "cor",
        lag = Integer(ceil(10*log10(length(x1)))),
        alpha = (0.95,0.99);
        plot = true)

Compute the cross-correlation or cros-covariance of two univariate series with an optional plot

The results are normalized to preserve homoscedasticity. The distribution used to normalize the data is an approximation of a Fisher Transformation via a Normal Distribution. There is a plot recipe for the returned object, if the type is `cor` the plot will also show confidence intervals for the given alpha values.

If, for a given integer `k`, `x2` repeats `x1` values such that x1[t] = x2[t+k] for all `i` then high correlation value will be placed *at the right from the center* in the results. That is, this convention will be represented in the plots as `x1_t = x2_{t+k} -> _____0__k__` meaning x2 behavior can be predicted by x1 in k units.

# Arguments
- `x1`: Vector or uni-dimensional DataFrame of data.
- `x2`: Vector or uni-dimensional DataFrame of data.
- `type`: Valid values are "cor" for correlation (default) and "cov" for convariance.
- `lag`: Maximum number of lags.
- `alpha`: A tuple with two thresholds (t1,t2) with t1 <= t2 to plot confidence intervals. The default values are 0.95 and 0.99.
- `plot`: When true displays a plot with the results.
    
# Returns

Cros-correlation vector with an optional plot

# Examples
```julia-repl
x1 = rand(100);
x2 = circshift(x1,6);
ccf(x1, x2; type="cor");
ccf(x1, x2; type="cor", plot = false)
41-element Vector{Float64}:
  0.09861519494432992
 -0.04384418688776631
 -0.1900182513825246
  [...]
```
"""
function ccf(x1::AbstractVector{<:A},
             x2::AbstractVector{<:B};
             type::String = "cor",
             lag::Integer = Integer(ceil(10*log10(length(x1)))),
             alpha::Tuple{AbstractFloat,AbstractFloat} = (0.95,0.99),
             plot::Bool = true,
             kw...) where {A<:Real, B<:Real}

    N = length(x1)
    @assert N == length(x2) "Vectors should be of equal size"
    @assert N >= 4 "Vectors should have at least four values"
    @assert isnothing(findfirst(isnan,x1)) "No missing values allowed"
    @assert isnothing(findfirst(isnan,x2)) "No missing values allowed"
    @assert isnothing(findfirst(ismissing,x1)) "No missing values allowed"
    @assert isnothing(findfirst(ismissing,x2)) "No missing values allowed"
    @assert type in  ["cor","cov"] "The options for `type` are `cor` and `cov`"
    @assert 1 <= lag <= N-4
    @assert length(alpha) == 2
    @assert 0.0 < alpha[1] < alpha[2] < 1.0

    # Promote to same Float type
    x1,x2,_ = Base.promote(x1,x2,[Base.promote_op(/,A,B)(1)])
    
    # auto-ccf
    auto = x1 == x2
    
    ft = (type == "cor" ? Statistics.cor : Statistics.cov)
    
    x = []

    for i in 1:lag
        push!(x,ft(x1[i+1:N],x2[1:(N-i)]))
    end

    if auto
        kx = collect(N-1:-1:N-lag)
    else 
        x = vcat(ft(x1,x2),x) # adding central value (lag=0)
        x = reverse(x)
        for i in 1:lag
            push!(x,ft(x2[i+1:N],x1[1:(N-i)]))
        end
        kx = vcat(collect(N-lag:N-1), N, collect(N-1:-1:N-lag))
    end

    # ccf normalized with the standard error for the
    # Normal distsribution of an approximation for
    # the Fisher transformation
    function fse(v::Real)::AbstractFloat
        1/sqrt(v-3)
    end
    k = fse.(kx)/fse(N)
    cres = x ./ k

    call = "ccf("* (auto ? "x" : "x1, x2") *
        "; type=\""*type*
        "\", lag="*string(lag)*
        ", alpha="*string(alpha)*")"

    # Confidence Intervals
    a1 = alpha[1]
    a2 = alpha[2]
    z1 = Distributions.quantile(Normal(), a1 + (1-a1)/2)
    ci1 = z1*fse(N)
    z2 = Distributions.quantile(Normal(), a2 + (1-a2)/2)
    ci2 = z2*fse(N)
    ci = (ci1,ci2)

    plot && display(cf_gr((cres, N=N, type, lag, alpha, ci, auto); kw...))

    cres

end


function cf_gr(args; kw...)

    # plot configuration

    titlefont = font(8, "Courier")
    xtickfont = font(3, "Courier")
    ytickfont = font(3, "Courier")
    yguidefont = font(5, "Courier")
    xguidefont = font(5, "Courier")

    N = args.N
    if split(args.type,'_')[1] == "pacf"
        type = (args.type) == "pacf_step" ? "Stepwise PACF" : "Real PACF"
        type = (args.type) == "pacf_stepwise-real" ? "Stepwise and Real PACF   |s|r|" : type
        auto_prefix = ""
    else
        type = (args.type == "cor") ? "Correlation" : "Covariance"
        auto_prefix = args.auto ? "Auto-" : "Cross-"
    end

    yguide = auto_prefix*type
    xguide = "Lag"
    
    # Center ticks
    lr = length(args.cres)
    gap = div(lr,11)
    mp = div(lr+1,2)
    rs = mp:gap:lr
    ls = mp-gap:-gap:1

    if args.auto
        xticks = 1:gap:lr
    else
        xt = vcat(reverse(collect(ls)),collect(rs))
        xticks = (xt, xt .- xt[div(end+1,2)])
    end

    plot(collect(1:size(args.cres)[1]+1) .- ((ndims(args.cres) == 2) ? .1 : 0),
         ndims(args.cres) == 2 ? args.cres[:,1] : args.cres;
         seriestype = :sticks, linewidth = 100/(args.lag+1),
         legend = :none, kw...)

    if ndims(args.cres) == 2

        plot!(collect(1:size(args.cres)[1]+1) .+ .1,
              args.cres[:,2];
              seriestype = :sticks, linewidth = 100/(args.lag+1))
        
    end
    
    if (args.type == "cor") | (split(args.type,'_')[1] == "pacf")
        lg = args.lag
        a1 = args.alpha[1]; c1 = args.ci[1]
        a2 = args.alpha[2]; c2 = args.ci[2]
        dc = c2-c1

        plot!([-c1,c1]; seriestype = :hline, seriescolor = :black, linealpha = 0.5, linestyle = :dash)
        
        ax = args.auto ? lg : 2*lg + 1
        annotations = 
            [(ax,c1+dc/8,string("CI %",a1*100),font(3, "Courier")),
             (ax,c2+dc/8,string("CI %",a2*100),font(3, "Courier"))]

        plot!([-c2,c2]; seriestype = :hline, seriescolor = :black,
              linealpha = 0.5, linestyle = :dot, annotations)
              
        
    end
    
end


