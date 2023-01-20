#=
	In this script, I'm going to try to figure out a CNot network that
	prepares a given CSS stabiliser state using a breadth-first search
	on an implicit graph whose nodes are stabiliser states (two nodes
	will be connected by an edge iff the stabiliser states can be
	transformed into one another using a single CNot).
=#

import ImplicitGraphs as IG 
import IterTools as IT
import QuantumClifford as QC

function possible_cnots(n_qubits)
	pairs = collect(IT.subsets(1 : n_qubits, 2))
	pairs = vcat(pairs, map(reverse, pairs))
	map(pair -> QC.sCNOT(pair...), pairs)
end

function neighbour_state(current_state, gate)
	new_state = gate * current_state
	QC.canonicalize_gott!(new_state)
	new_state
end

function possible_neighbours(current_state)
	cnots = possible_cnots(QC.nqubits(current_state))
	map(cnot -> neighbour_state(current_state, cnot), cnots)
end

#=
	For now, I'm going to try assuming that only edge search generates
	new vertices
=#
search_graph = IG.ImplicitGraph{QC.Stabilizer}(anything -> true, possible_neighbours)

function state_path(initial_state, final_state)
	QC.canonicalize_gott!(initial_state)
	QC.canonicalize_gott!(final_state)
	IG.find_path(search_graph, initial_state, final_state)
end

"""
`gate_path(state_path)`

Our BFS procedure records which states are between the initial and
final state, but it doesn't tell us which CNot we used to get from each
state to the next. This function brute-force iterates over the possible
CNots to determine the one that takes you from each vertex to the next. 
"""
function gate_path(state_path)
	cnots = possible_cnots(QC.nqubits(state_path[1]))
	
	edge_cnot(dx) = begin
		in_state = state_path[dx]
		out_state = state_path[dx + 1]
		for cnot in cnots
			if neighbour_state(in_state, cnot) == out_state
				return cnot
			end
		end
		error("no CNot found")
	end

	map(edge_cnot, 1 : length(state_path) - 1)
end