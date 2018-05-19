module Aux

"""
    MyPareto(alpha::Float64,x0::Float64)

Pareto distribution for sampling. This does not depend on Distributions and
the RNG seed can be set. This may not be needed for future versions of Julia.
"""
immutable MyPareto
    alpha::Float64
    x0::Float64
end
MyPareto(alpha=1.0) = MyPareto(alpha,1.0)
Base.Random.rand(p::MyPareto) = p.x0 * Base.Random.rand()^(-one(p.alpha)/p.alpha)

"""
    makedata()

Create a reproducible sorted array of Pareto distribution samples.
"""
function makedata(alpha=0.5,seed=11)
    Base.Random.srand(seed)
    d = MyPareto(alpha)
    return [Base.Random.rand(d) for _=1:10^6] |> sort!
end

end # module Aux
