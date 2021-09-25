using ForecastPlots
using Test

@testset "ForecastPlots.jl" begin

    x = rand(100)

    #splot
    px = splot(x;title="SPlot", plot=false)
    @test size(px) == (9,12)

    px = splot(x,"day";title="SPlot", plot=false)
    @test size(px) == (15,7)
    
    px = splot(x,"quarter",title="SPlot", plot=false)
    @test size(px) == (25,4)
    
    px = splot(x,"month",title="SPlot", plot=false)
    @test size(px) == (9,12)
    
    px = splot(x,10,title="SPlot", plot=false)
    @test size(px) == (10,10)
    
end
