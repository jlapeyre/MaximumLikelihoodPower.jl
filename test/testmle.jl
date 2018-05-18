# TODO: Finish this and move to test directory

using MaximumLikelihoodEstimatePower

import MaximumLikelihoodEstimatePower: KSstatistic

"""
    MyPareto(alpha::Float64,x0::Float64)

Pareto distribution for sampling. This does not depend on Distributions and
the RNG seed can be set. This may not be needed for recent versions of Julia.
"""
immutable MyPareto
    alpha::Float64    
    x0::Float64
end
MyPareto(alpha=1.0) = MyPareto(alpha,1.0)
Base.rand(p::MyPareto) = p.x0 * rand()^(-one(p.alpha)/p.alpha)

"""
    makedata()

Create a reproducible sorted array of Pareto distribution samples.
"""
function makedata()
    srand(11)
    d = MyPareto(.5)
    data = [rand(d) for _=1:10^6]
    sort!(data)
    data
end


"""
    testKS(data)

Compute the Kolmogorov Smirnov statistic for several values of α.
Return the minimizing α and the two neighboring values. The minimizer
is closest to 0.5, the value used in the Pareto distribution.
"""
function testKS(data)
    powers = linspace(.4,.6,11)
    ks = [KSstatistic(data,x) for x in powers]
    i = indmin(ks)
    (powers[i-1:i+1]...)
end

# This returns true with srand(11)
function compKS(data)
    testKS(data) == (.48,.5,.52)
end

function testmle1(nend)
    d = Pareto(.5)
    data = rand(d,10^6)
    sort!(data)
    println("Done generating and sorting")
    (alphahat, stddev) = EmpiricalCDFs.mle(data[end-nend:end]) # , data[end-nend])
    KSstatistic = EmpiricalCDFs.KStest(data[end-nend:end], alphahat)
    return (alphahat, stddev, KSstatistic)
end

let d = makedata()
    @test compKS(d)
end
