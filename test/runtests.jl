using ForecastPlots
using Test

@testset "ForecastPlots.jl" begin

    x = rand(100)

    #splot
    # px = splot(x;title="SPlot")
    # @test size(px) == (9,12)

    # px = splot(x,"day";title="SPlot")
    # @test size(px) == (15,17)
    
    # px = splot(x,"quarter",title="SPlot")
    # @test size(px) == (25,4)
    
    # splot(x,"month",title="SPlot")
    # @test size(px) == (9,12)
    
    # splot(x,10,title="SPlot")
    # @test size(px) == (10,10)
    
    splot(x,10,title="SPlot",plot=false)
    @test size(px) == (10,10)
    
end
