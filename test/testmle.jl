let seed = 11, α = 0.5,  data = MLE.Aux.makedata(α,seed)
    @test MLE.scanKS(data, Compat.range(.4, length=11, stop=.6)) == [.48,.5,.52]
    @test abs(MLE.scanmle(data).alpha - 1.5) < 1e-2
end
