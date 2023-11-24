using CliffordBFS
using Test

import CliffordBFS.CNot_BFS as CNot_BFS

@testset "Example tests" begin
	include("../CNot_BFS_Sandbox.jl")
	@test path = CNot_BFS.gate_path(CNot_BFS.state_path(plus_zero_3, cat_state))
end