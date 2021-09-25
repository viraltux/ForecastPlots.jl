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

    # acf 
    px = acf(x; type="cor", plot=false)
    @test size(px) == (20,)

    px = acf(x; type="cov", plot=false)
    @test size(px) == (20,)
    
    @test_throws AssertionError acf(x; type="", plot=false)

    # ccf
    x1 = rand(100);
    x2 = circshift(x1,6);
    px = ccf(x1, x2; type="cor", plot = false)

    @test size(px) == (41,)
    @test findmax(px)[2] == 27

    # pacf 
    px = pacf(x; plot=false)
    @test size(px) == (20,2)

    px = pacf(x; type = "stepwise", plot=false)
    @test size(px) == (20,)

    px = pacf(x; type = "real", plot=false)
    @test size(px) == (20,)

    px = pacf(x; type = "stepwise-real", plot=false)
    @test size(px) == (20,2)

    @test_throws AssertionError pacf(x; type = "", plot=false)

end
