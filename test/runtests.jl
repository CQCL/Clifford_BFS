using CliffordBFS
using Test


@testset "Cat State Preparation" begin
    include("../CNot_BFS_Sandbox.jl")
    @test length(CNot_BFS.gate_path(CNot_BFS.state_path(plus_zero_3, cat_state))) == 3
end