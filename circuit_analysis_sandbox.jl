import CliffordBFS as CB
import QuantumClifford as QC

"""
Generates the high-weight errors output from the circuit, and a pair of
stabilizers we need to measure in order to detect those errors, if such
a pair exists.
"""
function measurements_after_gatelist(gatelist; n_stabs=2)
	circ = CB.Circuit(gatelist, 8)

	stab_gens = [QC.P"XXXXIIII", QC.P"XXIIXXII",
					QC.P"XIXIXIXI", QC.P"IIIIXXXX",
					QC.P"ZZZZIIII", QC.P"ZZIIZZII",
					QC.P"ZIZIZIZI", QC.P"IIIIZZZZ"]

	stab_group = CB.generated_group(stab_gens)

	errs = CB.brute_force_minimize(CB.output_errors(circ), stab_group)
	high_weight_errs = filter(err -> CB.weight(err) > 1, errs)
	
	[stab_group[dxs] for dxs in
		postmeasurements(high_weight_errs, stab_group, n_stabs)]
end

gatelist = map(pr -> QC.sCNOT(pr...),
				[(1, 2), (2, 3), (2, 7), (3, 1), (7, 1), (1, 2)]);