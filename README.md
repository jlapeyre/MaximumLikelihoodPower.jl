# MaximumLikelihoodEstimatePower

Linux, OSX: [![Build Status](https://travis-ci.org/jlapeyre/MaximumLikelihoodEstimatePower.jl.svg)](https://travis-ci.org/jlapeyre/MaximumLikelihoodEstimatePower.jl)
&nbsp;
Windows: [![Build Status](https://ci.appveyor.com/api/projects/status/github/jlapeyre/MaximumLikelihoodEstimatePower.jl?branch=master&svg=true)](https://ci.appveyor.com/project/jlapeyre/maximumlikelihoodestimatepower-jl)
&nbsp; &nbsp; &nbsp;

[![Coverage Status](https://coveralls.io/repos/github/jlapeyre/MaximumLikelihoodEstimatePower.jl/badge.svg?branch=master)](https://coveralls.io/github/jlapeyre/MaximumLikelihoodEstimatePower.jl?branch=master)

[![codecov.io](http://codecov.io/github/jlapeyre/MaximumLikelihoodEstimatePower.jl/coverage.svg?branch=master)](http://codecov.io/github/jlapeyre/MaximumLikelihoodEstimatePower.jl?branch=master)

Physicists love power laws.

```
using Compat
import MaximumLikelihoodEstimatePower
const MLE = MaximumLikelihoodEstimatePower

julia> seed = 11; α = 0.5;

# Get 10^6 samples from the Pareto distribution
julia> data = MLE.Examples.makedata(α,seed);

# Minimize the Kolmogorov-Smirnov statistic
# The second value returned is the minimizing alpha
julia> MLE.scanKS(data, Compat.range(.4, length=11, stop=.6))
3-element Array{Float64,1}:
 0.48
 0.5
 0.52

# Perform mle several times. This estimates the exponent
# of the tail of the CDF, rather than the PDF, so the
# estimate is close to 1.5 rather than 0.5.
julia> MLE.scanmle(data).alpha
1.5089709151114046
```

The following functions make up the API, but none of them are exported.

### mle

```
    (estimate, stderr) = mle(data::AbstractVector)
```

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`.


### KSstatistic

```
    KSstatistic(data::AbstractVector, alpha) --> Float64
```

Return the Kolmogorov-Smirnov statistic
comparing `data` to a power law with power `alpha`. The elements of `data` are
assumed to be unique. Minimizing the KS statistic over alpha is another way
to estimate the parameter of the sample distribution. See `testKS` in the
`test` directory.

### scanKS(data, powers)

Compute the Kolmogorov Smirnov statistic for several values of α in
the iterator `powers`. Return the value of α
that minimizes the KS statistic and the two neighboring values.

### mleKS

```
    mleKS{T<:AbstractFloat}(data::AbstractVector{T})
```

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`. Also return the Kolmogorov-Smirnov statistic. Results
are returned in an instance of type `MLEKS`.


### scanmle

```
    scanmle(data::AbstractVector, ntrials=100, stderrcutoff=0.1)
````

Perform `mle` approximately `ntrials` times on `data`, increasing `xmin`. Stop trials
if the `stderr` of the estimate `alpha` is greater than `stderrcutoff`. Return an object
containing statistics about the scan.

### comparescan

```
    comparescan(mle::MLEKS, i, data, mlescan::MLEScan)
```
compare the results of MLE estimation `mle` to record results
in `mlescan` and update `mlescan`.

<!--  LocalWords:  MaximumLikelihoodEstimatePower OSX nbsp codecov io
 -->
<!--  LocalWords:  mle stderr KSstatistic
 -->
