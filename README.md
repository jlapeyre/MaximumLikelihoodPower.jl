# MLEPower

[![Build Status](https://travis-ci.org/jlapeyre/MLEPower.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/MLEPower.jl)

[![Coverage Status](https://coveralls.io/repos/jlapeyre/MLEPower.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jlapeyre/MLEPower.jl?branch=master)

[![codecov.io](http://codecov.io/github/jlapeyre/MLEPower.jl/coverage.svg?branch=master)](http://codecov.io/github/jlapeyre/MLEPower.jl?branch=master)

See the docstrings on `mle`, `KSstatistic`, `scanmle`.


### mle

```
    (estimate, stderr) = mle(data::AbstractVector)
```

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`.


### KSstatistic

```
    KSstatistic(data::AbstractVector, alpha)
```

Return the Kolmogorv-Smirnov statistic
comparing `data` to a power law with power `alpha`. The elements of `data` are
assumed to be unique.

### mleKS

```
    mleKS{T<:AbstractFloat}(data::AbstractVector{T})
```

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`. Also return the Kolmogorv-Smirnov statistic. Results
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
