import CliffordBFS as CB
using Test
import QuantumClifford as QC 

plus_zero_3 = QC.Stabilizer([QC.P"XIII", QC.P"IZII", QC.P"IIZI", QC.P"IIIZ"])
cat_state = QC.Stabilizer([QC.P"XXXX", QC.P"ZZII", QC.P"IZZI", QC.P"IIZZ"])

sc3_initial_state = QC.Stabilizer([
    QC.P"ZIIIIIIII",
    QC.P"IXIIIIIII",
    QC.P"IIZIIIIII",
    QC.P"IIIXIIIII",
    QC.P"IIIIZIIII",
    QC.P"IIIIIXIII",
    QC.P"IIIIIIZII",
    QC.P"IIIIIIIXI",
    QC.P"IIIIIIIIZ",
])

sc3_final_state = QC.Stabilizer([
    QC.P"ZZZIIIIII",
    QC.P"XXIIIIIII",
    QC.P"IIZZIIIII",
    QC.P"IXXXXIIII",
    QC.P"IIIZZZIII",
    QC.P"IIIIXXXXI",
    QC.P"IIIIIZZII",
    QC.P"IIIIIIIXX",
    QC.P"IIIIIIZZZ",
])

@testset "Cat State Preparation" begin
    @test length(CB.cnot_network(plus_zero_3, cat_state)) == 3
end

@testset "Does canonicalization change states?" begin
    for dx in 1:10
        state = QC.random_stabilizer(10, 10)
        other_state = CB.canonical_state(deepcopy(state))
        @test QC.logdot(state, other_state) == 0
    end
end

@testset "Does possible_cnots generate the right number of gates?" begin
    @test length(CB.possible_cnots(5)) == 20
    star_layout = [(1, 2), (1, 3), (1, 4), (1, 5), (1, 6)]
    @test length(CB.possible_cnots(5, star_layout)) == 10
end

@testset "possible_neighbours by-hand comparison" begin
    
end

@testset "weights" begin
    pauli = QC.P"XYZX__"
    @test CB.x_weight(pauli) == 3
    @test CB.z_weight(pauli) == 2
    @test CB.weight(pauli) == 4
end

@testset "is_separable" begin
    state = QC.Stabilizer([QC.P"XYZX", QC.P"_YZX",
                            QC.P"__ZX", QC.P"___X"])
    @test CB.is_separable(state)

    state = QC.Stabilizer([QC.P"XX", QC.P"ZZ"])
    @test !CB.is_separable(state)
end

@testset "state_path with the function" begin
    path = CB.state_path(cat_state, CB.is_separable)
    @test CB.is_separable(path[end])
end

@testset "Do gate paths produce the states we say they do?" begin
    cnots = CB.cnot_network(sc3_initial_state, sc3_final_state)
    test_state = deepcopy(sc3_initial_state)
    for cnot in cnots
         QC.apply!(test_state, cnot)
    end

    test_state = CB.canonical_state(test_state)
    reference_state = CB.canonical_state(sc3_final_state)
    @test test_state == reference_state
end

@testset "Circuit utility functions" begin
    gatelist = [QC.sHadamard(1), QC.sCNOT(1, 2),
                    QC.sCNOT(2, 3), QC.sCNOT(3, 7)]
    
    circ = CB.Circuit(gatelist, 8)

    @test circ.nq == 8
    @test Set(CB.qubits(circ)) == Set([1, 2, 3, 7])
end

@testset "Number of Paulis that can occur after some gate" begin
    for nq = 1:3
        @test length(CB.paulis_on(3, collect(1:nq))) == (4^nq - 1)
    end
end

@testset "Output errors and postmeasurements for cat state prep" begin
    gatelist = [QC.sHadamard(1), QC.sCNOT(1, 2),
                    QC.sCNOT(2, 3), QC.sCNOT(3, 4)]

    circ = CB.Circuit(gatelist, 4)

    stab_gens = [QC.P"XXXX", QC.P"ZZII", QC.P"IZZI", QC.P"IIZZ"]

    stab_group = CB.generated_group(stab_gens)

    errs = CB.brute_force_minimize(CB.output_errors(circ), stab_group)

    high_wt(err) = CB.weight(err) > 1
    dangerous_errs = filter(high_wt, errs)
    
    stab_subgroups = [stab_group[dxs] for dxs in
                       CB.postmeasurements(dangerous_errs, stab_group, 1)]

    @test in([QC.P"ZIIZ"], stab_subgroups)
end

@testset "Applying a couple of gates to things" begin
    @test CB.apply_gate(QC.P"ZZ", QC.sCNOT(1, 2)) == QC.P"IZ"

    stab_gens = [QC.P"XXXX", QC.P"ZZII", QC.P"IZZI", QC.P"IIZZ"]
    stab = QC.Stabilizer(stab_gens)

    output_stab = CB.apply_gate(stab, QC.sCNOT(1, 2))
    test_stab = [QC.P"XIXX", QC.P"IZII", QC.P"ZZZI", QC.P"IIZZ"]
    @test QC.canonicalize(output_stab) == QC.canonicalize(test_stab)
end

@testset "undetected errors" begin
    stab = QC.Stabilizer([QC.P"XXXX", QC.P"ZZZZ"])

    errs = CB.paulis_on(4, [1, 2])
    dangerous_errs = Set(CB.undetected_errors(errs, stab))
    test_errs = Set([QC.P"XXII", QC.P"YYII", QC.P"ZZII"])
    
    @test dangerous_errs == test_errs
end