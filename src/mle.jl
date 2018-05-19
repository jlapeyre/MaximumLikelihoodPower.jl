"""
    (estimate, stderr) = mle(data::AbstractVector)

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`.
"""
function mle(data::AbstractVector{<:AbstractFloat})
    xmin = data[1]
    acc = zero(xmin)
    xlast = Inf
    ncount = 0
    for x in data
        if xlast == x
            continue
        end
        xlast = x
        ncount += 1
        acc += log(x/xmin)
    end
    ahat = 1 + ncount/acc
    stderr = (ahat-1)/sqrt(ncount)
    (ahat,stderr)
end

"""
    KSstatistic(data::AbstractVector, alpha)

Return the Колмогоров-Смирнов (Kolmogorov-Smirnov) statistic
comparing `data` to a power law with power `alpha`. The elements of `data` are
assumed to be unique.
"""
function KSstatistic(data::AbstractVector{T}, alpha) where T <: AbstractFloat
    n = length(data)
    xmin = data[1]
    maxdistance = zero(xmin)
    @inbounds  for i in 0:n-1
        pl::T = 1 - (xmin/data[i+1])^alpha
        distance = abs(pl - i/n)
        if distance > maxdistance maxdistance = distance end
    end
    return maxdistance
end

"""
    scanKS(data, powers)

Compute the Kolmogorov Smirnov statistic for several values of α in
the iterator `powers`. Return the value of α
that minimizes the KS statistic and the two neighboring values.
"""
function scanKS(data, powers)
    ks = [KSstatistic(data,x) for x in powers]
    i = indmin(ks)
    return collect(powers[i-1:i+1])
end

"""
    MLEKS{T <: AbstractFloat}

Container for storing results of MLE estimate and
Kolmogorov-Smirnov statistic of the exponent of a power law.
"""
immutable MLEKS{T <: AbstractFloat}
    alpha::T
    stderr::T
    KS::T
end

"""
    mleKS{T<:AbstractFloat}(data::AbstractVector{T})

Return the maximum likelihood estimate and standard error of the exponent of a power law
applied to the sorted vector `data`. Also return the Kolmogorov-Smirnov statistic. Results
are returned in an instance of type `MLEKS`.
"""
function mleKS(data::AbstractVector{<: AbstractFloat})
    (alpha,stderr) = mle(data)
    KSstat = KSstatistic(data, alpha)
    MLEKS(alpha,stderr,KSstat)
end

"""
    MLEScan{T <: AbstractFloat}

Record best estimate of alpha and associated parameters.
"""
type MLEScan{T <: AbstractFloat}
    alpha::T
    stderr::T
    minKS::T
    xmin::T
    imin::Int
    npts::Int
    nptsall::Int
    ntrials::Int
end

# FIXME. more clever formatting needed
function Base.show(io::IO, s::MLEScan)
#    println(io, "alpha   = " , s.alpha)
#    println(io, "stderr  = " , s.stderr)
    @printf(io, "alpha   = %.8f\n" , s.alpha)
    @printf(io, "stderr  = %.8f\n" , s.stderr)
    println(io, "minKS   = " , s.minKS)
    println(io, "xmin    = " , s.xmin)
    println(io, "imin    = " , s.imin)
    println(io, "npts    = " , s.npts)
    println(io, "nptsall = " , s.nptsall)
    @printf(io, "pct pts = %.3f\n" , (s.npts/s.nptsall))
    println(io, "ntrials = " , s.ntrials)
end

function MLEScan(T)
    z = zero(T)
    inf = convert(T,Inf)
    MLEScan(z,z,inf,z,0,0,0,0)
end

"""
    comparescan(mle::MLEKS, i, data, mlescan::MLEScan)

compare the results of MLE estimation `mle` to record results
in `mlescan` and update `mlescan`.
"""
function comparescan(data, mle::MLEKS, i, mlescan::MLEScan)
    if mle.KS < mlescan.minKS
        mlescan.minKS = mle.KS
        mlescan.alpha = mle.alpha
        mlescan.stderr = mle.stderr
        mlescan.imin = i
        mlescan.npts = length(data)
        mlescan.xmin = data[1]
    end
    mlescan.ntrials += 1
end

"""
    scanmle(data::AbstractVector, ntrials=100, stderrcutoff=0.1)

Perform `mle` approximately `ntrials` times on `data`, increasing `xmin`. Stop trials
if the `stderr` of the estimate `alpha` is greater than `stderrcutoff`. Return an object
containing statistics about the scan.
"""
function scanmle(data::AbstractVector{<: AbstractFloat}, ntrials=100, stderrcutoff=0.1)
    skip = convert(Int,round(length(data)/ntrials))
    if skip < 1
        skip = 1
    end
    _scanmle(data, 1:skip:length(data), stderrcutoff)
end


"""
    _scanmle{T<:AbstractFloat, V <: Integer}(data::AbstractVector{T}, range::AbstractVector{V},stderrcutoff)

Inner function for scanning power-law mle for power `alpha` over `xmin`. `range` specifies which `xmin` to try.
`stderrcutoff` specifies a standard error in `alpha` at which we stop trials. `range` should be increasing.
"""
function _scanmle(data::AbstractVector{T}, range::AbstractVector{<: Integer},
                                    stderrcutoff) where T <: AbstractFloat
    mlescan = MLEScan(T)
    mlescan.nptsall = length(data)
    for i in range
        ndata = @view data[i:end]
        mleks = mleKS(ndata)
        mleks.stderr > stderrcutoff && break
        comparescan(ndata, mleks, i, mlescan)  # do we want ndata or data here ?
    end
    mlescan
end

#  LocalWords:  Kolmogorov Smirnov
