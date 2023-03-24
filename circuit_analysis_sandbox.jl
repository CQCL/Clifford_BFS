#=
	As of August 11, 2022, only works if you
	`include("circuit_analysis.jl")` first.
=#

gatelist = map(pr -> QC.sCNOT(pr...),
				[(1, 2), (2, 3), (2, 7), (3, 1), (7, 1), (1, 2)])
circ = Circuit(gatelist, 8)

stab_gens = [QC.P"XXXXIIII", QC.P"XXIIXXII", QC.P"XIXIXIXI", QC.P"IIIIXXXX",
			QC.P"ZZZZIIII", QC.P"ZZIIZZII", QC.P"ZIZIZIZI", QC.P"IIIIZZZZ"]

stab_group = collect(map(sbst -> prod(sbst, init=identity_pauli(8)), IT.subsets(stab_gens)))

#=
Commands to run in order to generate the high-weight errors output from
the circuit, and the stabilizers we need to measure in order to detect
those errors.
=#

errs = output_errors(circ)
errs = brute_force_minimize(errs, stab_group)
high_weight_errs = filter(err -> weight(err) > 1, errs)
subsets = postmeasurements(high_weight_errs, stab_group, 2)
minimum_stabs = stab_group[subsets[1]];