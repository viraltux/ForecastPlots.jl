using ForecastPlots
using Test

@testset "ForecastPlots.jl" begin

    x = rand(100)

    #splot
    px = splot(x;title="SPlot")
    @test size(px) == (9,12)
    splot(x,"day";title="SPlot"); @test true
    splot(x,"quarter",title="SPlot"); @test true
    splot(x,"month",title="SPlot"); @test true
    splot(x,10,title="SPlot"); @test true
    splot(x,10,title="SPlot",plot=false); @test true
    
end
