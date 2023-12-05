import CliffordBFS as CB

import Combinatorics as CO
import IterTools as IT
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

cube_initial_state = QC.Stabilizer([
    QC.P"ZIIIIIII",
    QC.P"IXIIIIII",
    QC.P"IIZIIIII",
    QC.P"IIIXIIII",
    QC.P"IIIIZIII",
    QC.P"IIIIIXII",
    QC.P"IIIIIIZI",
    QC.P"IIIIIIIX",
])
cube_final_state = QC.Stabilizer([
    QC.P"ZZZZIIII",
    QC.P"XXXXIIII",
    QC.P"ZZIIZZII",
    QC.P"XXIIXXII",
    QC.P"ZIZIZIZI",
    QC.P"XIXIXIXI",
    QC.P"IIIIZZZZ",
    QC.P"IIIIXXXX",
])

cube_initial_state_2 = QC.Stabilizer([
    QC.P"IIZIIIII",
    QC.P"IIIXIIII",
    QC.P"IZIIIIII",
    QC.P"IIIIIXII",
    QC.P"ZIIIIIII",
    QC.P"IIIIXIII",
    QC.P"IIIIIIZI",
    QC.P"IIIIIIIX",
])
cube_final_state_2 = QC.Stabilizer([
    QC.P"ZZZZIIII",
    QC.P"XXXXIIII",
    QC.P"ZZIIZZII",
    QC.P"XXIIXXII",
    QC.P"ZIZIZIZI",
    QC.P"XIXIXIXI",
    QC.P"IIIIZZZZ",
    QC.P"IIIIXXXX",
])
cube_bell_states = QC.Stabilizer([
    QC.P"ZIIIZIII",
    QC.P"XIIIXIII",
    QC.P"IZIIIZII",
    QC.P"IXIIIXII",
    QC.P"IIZZIIII",
    QC.P"IIXXIIII",
    QC.P"IIIIIIZZ",
    QC.P"IIIIIIXX",
])

cube_bell_states_2 = QC.Stabilizer([
    QC.P"ZZIIIIII",
    QC.P"XXIIIIII",
    QC.P"IIZZIIII",
    QC.P"IIXXIIII",
    QC.P"IIIIZZII",
    QC.P"IIIIXXII",
    QC.P"IIIIIIZZ",
    QC.P"IIIIIIXX",
])

cube_GHZ_states = QC.Stabilizer([
    QC.P"XXIIIIII",
    QC.P"XIXIIIII",
    QC.P"ZZZIIIII",
    QC.P"IIIIZZII",
    QC.P"IIIIZIZI",
    QC.P"IIIIXXXI",
    QC.P"IIIZIIIZ",
    QC.P"IIIXIIIX",
])

cube_GHZ_states_2 = QC.Stabilizer([
    QC.P"ZZIIIIII",
    QC.P"ZIZIIIII",
    QC.P"XXXIIIII",
    QC.P"IIIIZZII",
    QC.P"IIIIZIZI",
    QC.P"IIIIXXXI",
    QC.P"IIIXIIII",
    QC.P"IIIIIIIX",
])

cube_whole_space = QC.Stabilizer([
    QC.P"ZZIIIIII",
    QC.P"ZIZIIIII",
    QC.P"XXXIIIII",
    QC.P"IIIIZZII",
    QC.P"IIIIZIZI",
    QC.P"IIIIXXXI",
    QC.P"IIIXIIII",
    QC.P"IIIIIIIX",
])

planar_832_plus_state = QC.Stabilizer([
    QC.P"ZZZZIIIIIIII",
    QC.P"XXXXIIIIIIII",
    QC.P"ZZIIZZIIIIII",
    QC.P"XXIIXXIIIIII",
    QC.P"ZIZIZIZIIIII",
    QC.P"XIXIXIXIIIII",
    QC.P"IIIIZZZZIIII",
    QC.P"IIIIXXXXIIII",
    QC.P"IIIIIIIIZIII",
    QC.P"IIIIIIIIIZII",
    QC.P"IIIIIIIIIIZI",
    QC.P"IIIIIIIIIIIZ",
])

#=
	Here are some planar layouts that we look at for comparison.
	Qubits 1-8 are data qubits, 9-12 are ancillas
=#

#=
	4--12--8
	|  |   |
	3--11--7
	|  |   |
	2--10--6
	|  |   |
	1--9---5
=#

sandwich_layout = [
    [1, 2],
    [1, 9],
    [2, 3],
    [2, 10],
    [3, 4],
    [3, 11],
    [4, 12],
    [5, 6],
    [5, 9],
    [6, 7],
    [6, 10],
    [7, 8],
    [7, 11],
    [8, 12],
    [9, 10],
    [10, 11],
    [11, 12],
]

#=
	4--6--12
	|  |  |
	3--10-8
	|  |  |
	2--9--7
	|  |  |
	1--5--11
=#

buckle_layout = [
    [1, 2],
    [1, 5],
    [2, 3],
    [2, 9],
    [3, 4],
    [3, 10],
    [4, 6],
    [5, 9],
    [5, 11],
    [6, 10],
    [6, 12],
    [7, 8],
    [7, 9],
    [7, 11],
    [8, 10],
    [8, 12],
    [9, 10],
]

#=
	3--5---12
	|  |   |
	2--11--8
	|  |   |
	1--10--7
	|  |   |
	9--4---6
=#

s_layout = [
    [1, 2],
    [1, 9],
    [1, 10],
    [2, 3],
    [2, 11],
    [3, 5],
    [4, 6],
    [4, 9],
    [4, 10],
    [5, 11],
    [5, 12],
    [6, 7],
    [7, 8],
    [7, 10],
    [8, 11],
    [8, 12],
    [10, 11],
]

#=
	7--8
	|  |
	4--6
	|  |
	2--5
	|  |
	1--3
=#

tiny_layout =
    [[1, 2], [1, 3], [2, 4], [2, 5], [3, 5], [4, 6], [4, 7], [5, 6], [6, 8], [7, 8]]

function all_partitions_cube_prep()
    qubits = collect(1:8)
    x_partitions = collect(IT.subsets(qubits, 4))
    z_partitions = map(x_p -> setdiff(qubits, x_p), x_partitions)

    path_and_length(state) = begin
        path = CB.state_path(state, cube_final_state_2)
        path, length(path)
    end

    init_state = cube_separable_state(x_partitions[1], z_partitions[1])
    shortest_path, min_length = path_and_length(init_state)

    for (x_p, z_p) in zip(x_partitions[2:end], z_partitions[2:end])
        path, length = path_and_length(cube_separable_state(x_p, z_p))
        if length < min_length
            shortest_path, min_length = path, length
        end
    end

    CB.gate_path(shortest_path)
end

function cube_separable_state(x_partition, z_partition)
    QC.Stabilizer(
        vcat(
            map(bit -> QC.single_x(8, bit), x_partition),
            map(bit -> QC.single_z(8, bit), z_partition),
        ),
    )
end

"""
We'd like to know whether the 10-CNot limit can be reached on a layout
with square-lattice connectivity.
We need to be able to measure a pair of stabilizers and a logical X
onto two qubits in the middle after non-fault-tolerant preparation. 

For now, we assume that the stabiliser pair we measure has to be
supported on qubits (2, 4, 5, 7), and the logical will be supported
on qubits (1, 2, 5, 6) (indices off-by-one wrt the paper).
We search over layouts where the six qubits (1, 2, 4, 5, 6, 7) will be
adjacent to the two qubits in the middle after a pair of swaps
"""
function planar_cube_prep()
    desired_state = cube_final_state

    close_qubits = [1, 2, 4, 5, 6, 7]
    perms_6 = map(perm -> close_qubits[perm], collect(CO.permutations(1:6)))
    perms_2 = [[3, 8], [8, 3]]
    ctr = 1
    solutions = []
    for perm_6 in perms_6
        @show ctr
        for perm_2 in perms_2
            qs = vcat(perm_6, perm_2)
            layout = [
                [qs[1], qs[2]],
                [qs[1], qs[7]],
                [qs[2], qs[3]],
                [qs[2], qs[5]],
                [qs[3], qs[4]],
                [qs[3], qs[6]],
                [qs[4], qs[8]],
                [qs[5], qs[6]],
                [qs[5], qs[7]],
                [qs[6], qs[8]],
            ]

            path = CB.state_path(desired_state, CB.is_separable, layout, 12)

            if length(path) < 1
                continue
            end

            gates = CB.gate_path(path, layout)

            if length(gates) == 10
                push!(solutions, (layout, gates))
            end
        end
        ctr += 1
    end

    solutions
end
