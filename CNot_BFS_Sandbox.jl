include("CNot_BFS.jl")
import .CNot_BFS

import IterTools as IT
import QuantumClifford as QC

plus_zero_3 = QC.Stabilizer([QC.P"XIII", QC.P"IZII", QC.P"IIZI", QC.P"IIIZ"])
cat_state = QC.Stabilizer([QC.P"XXXX", QC.P"ZZII", QC.P"IZZI", QC.P"IIZZ"])

sc3_initial_state = QC.Stabilizer([
									QC.P"ZIIIIIIII", QC.P"IXIIIIIII", QC.P"IIZIIIIII",
									QC.P"IIIXIIIII", QC.P"IIIIZIIII", QC.P"IIIIIXIII",
									QC.P"IIIIIIZII", QC.P"IIIIIIIXI", QC.P"IIIIIIIIZ"
								])
sc3_final_state = QC.Stabilizer([
									QC.P"ZZZIIIIII", QC.P"XXIIIIIII", QC.P"IIZZIIIII",
									QC.P"IXXXXIIII", QC.P"IIIZZZIII", QC.P"IIIIXXXXI",
									QC.P"IIIIIZZII", QC.P"IIIIIIIXX", QC.P"IIIIIIZZZ"
								])

cube_initial_state = QC.Stabilizer([
									QC.P"ZIIIIIII", QC.P"IXIIIIII", QC.P"IIZIIIII",
									QC.P"IIIXIIII", QC.P"IIIIZIII", QC.P"IIIIIXII",
									QC.P"IIIIIIZI", QC.P"IIIIIIIX"
								])
cube_final_state = QC.Stabilizer([
									QC.P"ZZZZIIII", QC.P"XXXXIIII", QC.P"ZZIIZZII",
									QC.P"XXIIXXII", QC.P"ZIZIZIZI", QC.P"XIXIXIXI",
									QC.P"IIIIZZZZ", QC.P"IIIIXXXX"
								])

cube_initial_state_2 = QC.Stabilizer([
									QC.P"IIZIIIII", QC.P"IIIXIIII", QC.P"IZIIIIII",
									QC.P"IIIIIXII", QC.P"ZIIIIIII", QC.P"IIIIXIII",
									QC.P"IIIIIIZI", QC.P"IIIIIIIX"
								])
cube_final_state_2 = QC.Stabilizer([
									QC.P"ZZZZIIII", QC.P"XXXXIIII", QC.P"ZZIIZZII",
									QC.P"XXIIXXII", QC.P"ZIZIZIZI", QC.P"XIXIXIXI",
									QC.P"IIIIZZZZ", QC.P"IIIIXXXX"
								])
cube_bell_states = QC.Stabilizer([
									QC.P"ZIIIZIII", QC.P"XIIIXIII",
									QC.P"IZIIIZII", QC.P"IXIIIXII", 
									QC.P"IIZZIIII", QC.P"IIXXIIII", 
									QC.P"IIIIIIZZ", QC.P"IIIIIIXX"
								])

cube_bell_states_2 = QC.Stabilizer([
									QC.P"ZZIIIIII", QC.P"XXIIIIII",
									QC.P"IIZZIIII", QC.P"IIXXIIII", 
									QC.P"IIIIZZII", QC.P"IIIIXXII", 
									QC.P"IIIIIIZZ", QC.P"IIIIIIXX"
								])

cube_GHZ_states = QC.Stabilizer([
									QC.P"XXIIIIII", QC.P"XIXIIIII",
									QC.P"ZZZIIIII", QC.P"IIIIZZII", 
									QC.P"IIIIZIZI", QC.P"IIIIXXXI", 
									QC.P"IIIZIIIZ", QC.P"IIIXIIIX"
								])

cube_GHZ_states_2 = QC.Stabilizer([
									QC.P"ZZIIIIII", QC.P"ZIZIIIII",
									QC.P"XXXIIIII", QC.P"IIIIZZII", 
									QC.P"IIIIZIZI", QC.P"IIIIXXXI", 
									QC.P"IIIXIIII", QC.P"IIIIIIIX"
								])

cube_whole_space = QC.Stabilizer([
									QC.P"ZZIIIIII", QC.P"ZIZIIIII",
									QC.P"XXXIIIII", QC.P"IIIIZZII", 
									QC.P"IIIIZIZI", QC.P"IIIIXXXI", 
									QC.P"IIIXIIII", QC.P"IIIIIIIX"
								])



function all_partitions_cube_prep()
	qubits = collect(1:8)
	x_partitions = collect(IT.subsets(qubits, 4))
	z_partitions = map(x_p -> setdiff(qubits, x_p), x_partitions)
	
	path_and_length(state) = begin
		path = CNot_BFS.state_path(state, cube_final_state_2)
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

	CNot_BFS.gate_path(shortest_path)
end

function cube_separable_state(x_partition, z_partition)
	QC.Stabilizer(vcat(map(bit -> QC.single_x(8, bit), x_partition),
		map(bit -> QC.single_z(8, bit), z_partition)))
end