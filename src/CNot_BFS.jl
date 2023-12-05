module CNot_BFS

#=
    In this module, I'm going to try to figure out a CNot network that
    prepares a given CSS stabiliser state using a breadth-first search
    on an implicit graph whose nodes are stabiliser states.

    Two nodes will be connected by an edge iff the stabiliser states
    can be transformed into one another using a single CNot on a
    user-provided layout. 

    If no layout is provided, all-to-all connectivity will be assumed.
=#

"""
`canonical_state(state)`

We don't want to change a state inplace if it comes from a higher level
of scope. 
Also, we can't have our qubits permuted if we're trying to stick to a
layout.
"""
function canonical_state(state)
    QC.canonicalize_rref!(copy(state))[1]
end

function cnot_network(initial_state, final_state, layout = nothing)
    gate_path(state_path(initial_state, final_state, layout))
end

function possible_cnots(n_qubits, layout = nothing)
    if isnothing(layout)
        layout = collect(IT.subsets(1:n_qubits, 2))
    end

    layout = vcat(layout, map(reverse, layout))
    map(pair -> QC.sCNOT(pair...), layout)
end

function neighbour_state(current_state, gate)
    canonical_state(gate * current_state)
end

function possible_neighbours(layout)
    neighbs(current_state) = begin
        cnots = possible_cnots(QC.nqubits(current_state), layout)
        map(cnot -> neighbour_state(current_state, cnot), cnots)
    end

    neighbs
end

@inline weight(p::QC.PauliOperator) = count_ones(p.xz[1] | p.xz[2])

"""
`is_separable(state)`

For now, we check to see whether a stabilizer state is separable by
checking whether every stabilizer is weight-one after the state has
been canonicalized.  
"""
function is_separable(state)
    all(map(p -> weight(p) == 1, canonical_state(state)))
end

function state_path(start, target::QC.Stabilizer, layout = nothing, max_states = 0)
    #=
    For now, I'm going to try assuming that only edge search generates
    new vertices
    =#
    graph = IG.ImplicitGraph{QC.Stabilizer}(anything -> true, possible_neighbours(layout))

    IG.find_path(graph, canonical_state(start), canonical_state(target), max_states)
end

function state_path(start, target::Function, layout = nothing, max_states = 0)
    graph = IG.ImplicitGraph{QC.Stabilizer}(anything -> true, possible_neighbours(layout))

    IG.find_path(graph, canonical_state(start), target, max_states)
end

"""
`gate_path(state_path)`

Our BFS procedure records which states are between the initial and
final state, but it doesn't tell us which CNot we used to get from each
state to the next. This function brute-force iterates over the possible
CNots to determine the one that takes you from each vertex to the next. 
"""
function gate_path(state_path, layout = nothing)
    cnots = possible_cnots(QC.nqubits(state_path[1]), layout)

    edge_cnot(dx) = begin
        in_state = state_path[dx]
        out_state = state_path[dx+1]
        for cnot in cnots
            if neighbour_state(in_state, cnot) == out_state
                return cnot
            end
        end
        error("no CNot found")
    end

    map(edge_cnot, 1:length(state_path)-1)
end

end # module CNot_BFS