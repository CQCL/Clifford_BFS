import CliffordBFS as CB
using Test


@testset "Cat State Preparation" begin
    @test length(CB.gate_path(CB.state_path(plus_zero_3, cat_state))) == 3
end