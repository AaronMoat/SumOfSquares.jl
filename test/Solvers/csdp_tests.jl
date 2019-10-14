include("solver_preamble.jl")
import CSDP
factory = with_optimizer(CSDP.Optimizer, printlevel=0)
config = MOI.Test.TestConfig(atol=1e-4, rtol=1e-4, query=false)
@testset "Linear" begin
    Tests.linear_test(factory, config, [
        # Segfaults, see https://github.com/JuliaOpt/CSDP.jl/issues/39
        "dsos_horn",
    ])
end
@testset "SDP" begin
    Tests.sd_test(factory, config)
end