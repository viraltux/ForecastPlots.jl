"""
Package: ForecastPlots

    pacf(x,
         type = "step-real",
         lag = Integer(ceil(10*log10(length(x)))),
         alpha = (0.95,0.99);
         plot = true)

Compute the partial auto-correlation for an univariate series with an optional plot.

There are two versions; the "step" version estimates the auto-regressive parameters of an increasing model, the "real" version estimates the actual partial auto-correlation by eliminating the linear information provided by the lags. When using the default type "stepwise-real" both versions are calculated.

The distribution used to estimate the confidence intervals is an approximation of a Fisher Transformation via a Normal Distribution. There is a plot recipe for the returned object.

# Arguments
- `x`: Vector of data.
- `type` = Valid values are "stepwise", "real" and "stepwise-real".
- `lag`: Maximum number of lags.
- `alpha`: A tuple with two thresholds (t1,t2) with t1 <= t2 to plot confidence intervals. The default values are 0.95 and 0.99.
- `plot`: When true displays a plot with the results.

# Returns
A CF object

# Examples
```julia-repl
julia> x = rand(100);
pacf(x);
pacf(x; plot=false)
20×2 Matrix{Float64}:
 -0.0475437   -0.101204
  0.0407006    0.058935
 -0.0747269    0.0366026
```
"""
function pacf(x::AbstractVector{<:Real};
              type::String = "stepwise-real",
              lag::Integer = Integer(ceil(10*log10(length(x)))),
              alpha::Tuple{Real,Real} = (0.95,0.99),
              plot::Bool = true,
              kw...)

    N = length(x)
    @assert type in  ["stepwise","real","stepwise-real"] "The options for `type` are `stepwise`, `real` and `stepwise-real`"
    @assert 1 <= lag <= N-4
    @assert length(alpha) == 2
    @assert 0.0 < alpha[1] < alpha[2] < 1.0

    # Confidence Intervals
    function fse(v::Real)::AbstractFloat
        1/sqrt(v-3)
    end

    a1 = alpha[1]
    a2 = alpha[2]
    z1 = quantile(Normal(), a1 + (1-a1)/2)
    ci1 = z1*fse(N-lag)
    z2 = quantile(Normal(), a2 + (1-a2)/2)
    ci2 = z2*fse(N-lag)
    ci = (ci1,ci2)

    call = "pacf(x"*
        "; type=\""*type*
        "\", lag="*string(lag)*
        ", alpha="*string(alpha)*")"

    if (type::String == "stepwise") 
        pac = pacf_stepwise(x; lag, alpha)
        plot && display(cf_gr((cres=pac, N=N, type="pacf_stepwise", lag, alpha, ci, auto=true, kw...)))
        return pac
    end

    if (type::String == "real") 
        pac = pacf_real(x; ag, alpha)
        plot && display(cf_gr((cres=pac, N=N, type="pacf_real", lag, alpha, ci, auto=true, kw...)))
        return pac
    end

    if type::String == "stepwise-real"
        pacs = pacf_stepwise(x; lag, alpha)
        pacr = pacf_real(x; lag, alpha)
        plot && display(cf_gr((cres=hcat(pacs, pacr), N=N, type="pacf_stepwise-real", lag, alpha, ci, auto=true, kw...)))
        return hcat(pacs, pacr)
    end

end

function pacf_lag(x::AbstractVector{<:Real};
                   lag::Integer = Integer(ceil(10*log10(length(x)))),
                   alpha::Tuple{Real,Real} = (0.95,0.99))

    R = vcat(cov(x,x),acf(x; type = "cov", lag, alpha, plot=false))
    p = length(R)-1

    A = zeros(p,p)
    for i in p:-1:1
        A[i,i:end] = R[1:p-i+1]
        A[i:end,i] = R[1:p-i+1]
    end
    b = R[2:end]

    lambda = 10^-36
    (A'*A+lambda*I(p))\(A'*b)

end

function pacf_stepwise(x::AbstractVector{<:Real};
                   lag::Integer = Integer(ceil(10*log10(length(x)))),
                   alpha::Tuple{Real,Real} = (0.95,0.99))

    #TODO optimize with Levinson-Durbin algorithm
    pac = []
    for i in 1:lag
        push!(pac, pacf_lag(x; lag = i)[end])
    end
    pac
    
end

function pacf_real(x::AbstractVector{<:Real};
             lag::Integer = Integer(ceil(10*log10(length(x)))),
             alpha::Tuple{Real,Real} = (0.95,0.99))

    # prevent singularities
    lambda = 10^-36

    N = length(x)
    A = zeros(N-lag,lag+1)
    for i in 1:(N-lag)
        A[i,:] = x[i:i+lag]
    end
    bt1 = A[:,1]
    A = A[:,2:end]
    A = hcat(A,repeat([1.0],N-lag))

    pacf_res = []
    for i in 2:lag+1
        A1i = drop(A, c=i-1)
        lsq = (A1i'*A1i+lambda*I(lag))\(A1i'*bt1)
        r1 = round.(bt1.-A1i*lsq, digits=10)

        bt0 = A[:,i-1]
        lsq = (A1i'*A1i+lambda*I(lag))\(A1i'*bt0)
        r0 = round.(bt0.-A1i*lsq, digits=10)
        push!(pacf_res,cor(r0,r1))
        
    end
    
    pacf_res
end

"""
Package: ForecastPlots

    drop(M;r,c)

Drop rows and columns from a matrix.
"""
function drop(M::AbstractMatrix; r=[], c=[])
    s = size(M)
    dr = collect(1:s[1])
    dc = collect(1:s[2])
    splice!(dr,r)
    splice!(dc,c)
    M[dr,dc]
end
