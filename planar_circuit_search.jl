#=
	We'd like to be able to implement error-detected addition using the
	[[8, 3, 2]] code on a planar layout. 

	We know that the non-fault-tolerant plus-state preparation can be
	carried out with 10 CNots on a layout where there are no ancillas
	between the qubits of interest:

	4--8
	|  |
	3--7
	|  |
	2--6
	|  |
	1--5

	The remainder of the original circuit can be executed using flag
	circuits which affect at most six of the data qubits, and need
	two ancillas. 
	We can obtain a planar layout which has two ancillas with access to
	six data qubits by moving two qubits:

	   4--8			4--8 
	   |  |			|  |
	3--A--7			3--A--7
	|  |  |			|  |  |
	2--A--6			2--A--6
	   |  |			|  |
	   1--5			1--5
	
	   4--8			4--8
	   |  |			|  |
	3--A--A--7  	3--7
	   |  |			|  |
	   2--6 	 2--A--A--6
	   |  |			|  |
	   1--5			1--5

	In this script, we're going to study layouts of this type. 
	We want to:
	 + Prepare the |+++> state using 10 CNots
	 + Measure a pair of weight-4 fully overlapping stabilizers to
	   achieve fault tolerance, and:
	 + Have any face of the cube accessible to the ancillas in the
	   middle, so we can do a flag logical measurement.
=#

include("CNot_BFS_Sandbox.jl")
include("circuit_analysis.jl")
include("circuit_analysis_sandbox.jl")

"""
The faces of the cube are independent from the layout
"""
const planar_faces = [[1, 2, 3, 4],
						[1, 2, 5, 6],
						[1, 3, 5, 7],
						[5, 6, 7, 8],
						[2, 4, 6, 8]]

flip_lr(perm) = perm[[5, 6, 7, 8, 1, 2, 3, 4]]
flip_ud(perm) = perm[[4, 3, 2, 1, 8, 7, 6, 5]]

"""
Gets rid of the two reflection symmetries
"""
function qubit_permutations()
	perms = [] 
	for test_perm in CO.permutations(1:8)
		perm_redundant = any([flip_ud(test_perm) in perms,
								flip_lr(test_perm) in perms,
								flip_ud(flip_lr(test_perm)) in perms])
		if ~(perm_redundant)
			push!(perms, test_perm)
		end 
	end
	perms
end

function tiny_planar_layout(qs)
	[[qs[1], qs[2]], [qs[1], qs[5]],
		[qs[2], qs[3]], [qs[2], qs[5]],
		[qs[3], qs[4]], [qs[3], qs[6]],
		[qs[4], qs[8]],
		[qs[5], qs[6]], [qs[5], qs[7]],
		[qs[6], qs[8]]]
end

"""
The layouts drawn above allow us to measure operators on the following
sets of qubits, which we call access zones (why not?)
"""
function planar_access_zones(qs)
	[
		qs[[1, 2, 3, 4, 6, 7]],
		qs[[2, 3, 5, 6, 7, 8]],
		qs[[2, 3, 4, 6, 7, 8]],
		qs[[1, 2, 3, 5, 6, 7]]
	]
end

function support(pauli)
	union(findall(QC.int_to_bits(8, pauli.xz[1])),
			findall(QC.int_to_bits(8, pauli.xz[2])))
end

function one_stabilizer_solutions(layout, circ)
	access_zones = planar_access_zones(layout)
	measurements = measurements_after_gatelist(gatelist, n_stabs=1)
	
	solutions = []

	for measurement in measurements
		for zone in access_zones
			if issubset(support(measurement), zone)
				for face in planar_faces
					if issubset(face, zone)
						push!(solutions, (layout, circ, measurement, zone, face))
					end
				end
			end
		end
	end

	solutions
end

function two_stabilizer_solutions(layout, circ)
	access_zones = planar_access_zones(layout)
	measurements = measurements_after_gatelist(gatelist, n_stabs=2)
	
	solutions = []

	for measurement in measurements
		for zone in access_zones
			meas_support = union(support(measurement[1]), support(measurement[2]))
			if issubset(meas_support, zone)
				for face in planar_faces
					if issubset(face, zone)
						push!(solutions, (layout, circ, measurement, zone, face))
					end
				end
			end
		end
	end

	solutions
end

"""
We're trying to find one or two stabilizers that we can measure to make
the state preparation fault-tolerant, and a face that we can run the
logical X measurement on.
"""
function try_to_find_solutions(layout, path)
	gates = CNot_BFS.gate_path(path)
	circ = Circuit(gates, 8)
	return [one_stabilizer_solutions(layout, circ);
				two_stabilizer_solutions(layout, circ)]
end

function planar_circuit_search()
	desired_state = cube_final_state
	perms = qubit_permutations()
	all_solutions = []
	for perm in perms
		layout = tiny_planar_layout(perm)

		path = CNot_BFS.state_path(desired_state, CNot_BFS.is_separable, layout, 10)
		if length(path) == 0 # <-- min-length path does not exist
			continue
		end
		
		solutions = try_to_find_solutions(layout, path)

		if ~(isempty(solutions))
			all_solutions = vcat(all_solutions, solutions)
		end
	end

	all_solutions
end

const by_hand_planar_circuit = [QC.sHadamard(1), QC.sHadamard(3),
								QC.sCNOT(1, 2), QC.sCNOT(2, 6), QC.sCNOT(6, 5),
								QC.sCNOT(3, 4), QC.sCNOT(4, 8), QC.sCNOT(8, 7), 
								QC.sHadamard(3), QC.sHadamard(4), QC.sHadamard(8), QC.sHadamard(7),
								QC.sCNOT(3, 1), QC.sCNOT(4, 2), QC.sCNOT(8, 6), QC.sCNOT(7, 5)]

zero_state = QC.Stabilizer([QC.P"ZIIIIIII", QC.P"IZIIIIII",
							QC.P"IIZIIIII", QC.P"IIIZIIII",
							QC.P"IIIIZIII", QC.P"IIIIIZII",
							QC.P"IIIIIIZI", QC.P"IIIIIIIZ"])

