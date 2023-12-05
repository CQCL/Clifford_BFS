import CliffordBFS as CB
using Test
import QuantumClifford as QC 

plus_zero_3 = QC.Stabilizer([QC.P"XIII", QC.P"IZII", QC.P"IIZI", QC.P"IIIZ"])
cat_state = QC.Stabilizer([QC.P"XXXX", QC.P"ZZII", QC.P"IZZI", QC.P"IIZZ"])

@testset "Cat State Preparation" begin
    @test length(CB.gate_path(CB.state_path(plus_zero_3, cat_state))) == 3
end