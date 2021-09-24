using ForecastPlots
using Test

@testset "ForecastPlots.jl" begin

    x = rand(100)
    splot(x,title="SPlot")
    splot(x,"day",title="SPlot")
    splot(x,"quarter",title="SPlot")
    splot(x,"month",title="SPlot")
    splot(x,10,title="SPlot")
    
end
