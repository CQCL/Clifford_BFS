struct Circuit
    gatelist
    nq
end

qubits(circuit::Circuit) = qubits(circuit.gatelist)

qubits(gatelist) = reduce(union, map(qubits, gatelist))

qubits(gate::QC.sCNOT) = [gate.q1, gate.q2]
qubits(gate::QC.sCPHASE) = [gate.q1, gate.q2]

qubits(gate::QC.sHadamard) = [gate.q]
qubits(gate::QC.sPhase) = [gate.q]
qubits(gate::QC.sInvPhase) = [gate.q]

output_errors(circuit) = union(output_errors_from_input(circuit),
                                output_errors_from_gates(circuit))
 
output_errors_from_input(circuit::Circuit) = map(err -> apply(circuit, err), input_errors(circuit))

function output_errors_from_gates(circuit::Circuit)
    output_errors = []
    
    to_output(circ_frag) = p -> apply(circ_frag, p)
    
    for dx = 1 : length(circuit.gatelist) - 1
        gate = circuit.gatelist[dx]
        final_circ = circuit.gatelist[dx + 1 : end]
        gate_errors = map(to_output(final_circ), paulis_on(circuit.nq, qubits(gate)))
        output_errors = union(output_errors, gate_errors)
    end
    
    gate = circuit.gatelist[end]
    output_errors = union(output_errors, paulis_on(circuit.nq, qubits(gate)))

    output_errors
end

apply(circuit::Circuit, pauli) = apply(circuit.gatelist, pauli)

function apply(circuit, pauli)
    output_pauli = deepcopy(pauli)
    for gate in circuit
        output_pauli = apply_gate(output_pauli, gate)
    end
    output_pauli
end

function apply_gate(pauli::QC.PauliOperator, gate)
    QC.apply!(QC.Stabilizer([pauli]), gate)[1]
end

function apply_gate(stab::QC.Stabilizer, gate)
    QC.apply!(stab, gate)
end

function input_errors(circuit::Circuit)
    reduce(union, map(q -> paulis_on(circuit.nq, q), qubits(circuit)))
end

function paulis_on(nq, qubit::Int64)
    [QC.single_z(nq, qubit),
    QC.single_x(nq, qubit),
    QC.single_y(nq, qubit)]
end

function paulis_on(nq, qubits)
    if isempty(qubits)
        return Vector{QC.PauliOperator}()
    end
    
    id = identity_pauli(nq)
    single_paulis = map(q -> vcat([id], paulis_on(nq, q)), qubits)
    big_paulis = map(ps -> reduce(*, ps, init=id),
                        Iterators.product(single_paulis...))
    
    setdiff(flatten(big_paulis), [id])
end

function weight_one_paulis_on(nq, qubits)
    if isempty(qubits)
        return Vector{QC.PauliOperator}()
    end
    
    vcat(map(q -> paulis_on(nq, q), qubits)...)
end

flatten(mat) = reduce(vcat, mat)

identity_pauli(nq) = QC.PauliOperator(repeat([false], 2 * nq))

"""
We'd like to know which output errors are weight-1 when minimized over
the stabilizer group. 
"""
function brute_force_minimize(paulis, stab_group)
    map(p -> argmin(weight, [p] .* stab_group), paulis)
end

"""
Which elements of the stabilizer group, if measured, would detect a 
given set of errors?
n_meas is the number of different operators we could measure. 
"""
function postmeasurements(errors, stab_group, n_meas)
    commutator_values = map(s -> map(p -> QC.comm(s, p), errors), stab_group)
    output_subsets = []
    for subset in IT.subsets(1 : length(stab_group), n_meas)
        if !any(sum(commutator_values[subset]) .== 0x00)
            push!(output_subsets, subset)
        end
    end
    output_subsets
end

function generated_group(gens)
    n_q = gens[1].nqubits
    pauli_product = subset -> prod(subset, init=identity_pauli(n_q))
    collect(map(pauli_product, IT.subsets(gens)))
end

"""
`undetected_errors(errors, stabs)`

Which errors from an input list would go undetected by the flawless
measurement of a set of stabilizers? 
"""
function undetected_errors(errors, stabs)
    filter(err -> is_undetected(err, stabs), errors)
end

function is_undetected(err, stabs)
    syndrome(stabs, err) = map(s -> QC.comm(s, err), stabs)
    all(syndrome(stabs, err) .== 0x00)
end