import CliffordBFS as CB
import QuantumClifford as QC

#=
	In this note, we're going to generate the sets of measurements we
	need in order to detect high-weight errors, then briefly discuss
	why we don't actually need to do that.
=#

#=
	As discussed in the paper, the last six gates are the only ones
	that can create or propagate dangerous errors. 
=#
gatelist = map(pr -> QC.sCNOT(pr...),
				[(1, 2), (2, 3), (2, 7), (3, 1), (7, 1), (1, 2)]);
circ = CB.Circuit(gatelist, 8)
all_errs = CB.output_errors(circ)

#=
	We only need to worry about the weights of errors after they've
	been multiplied by some appropriate stabilizer. 

	Here, we're going to do that using an exponential-time brute-force
	algorithm.

	Note that logical Xs are also stabilizers for this purpose. 
=#
stab_gens = [QC.P"XXXXIIII", QC.P"XXIIXXII",
				QC.P"XIXIXIXI", QC.P"IIIIXXXX",
				QC.P"ZZZZIIII", QC.P"ZZIIZZII",
				QC.P"ZIZIZIZI", QC.P"IIIIZZZZ"]
stab_group = CB.generated_group(stab_gens)
errs = CB.brute_force_minimize(all_errs, stab_group)

#=
	Let's see which of these errors can't be detected:
=#

stabs_832 = [QC.P"XXXXXXXX", QC.P"ZZZZIIII", QC.P"ZZIIZZII",
				QC.P"ZIZIZIZI", QC.P"IIIIZZZZ"]
dangerous_errs = CB.undetected_errors(errs, stabs_832)

#=
	We can see that the set is quite small, containing only two logical
	Z operators. 
	It's easy to see that an appropriate logical X operator can
	anticommute with both of them. 

	In an earlier version of this code, the set `dangerous_errs` above
	was being calculated incorrectly (only weight-1 errors were being
	produced after a CNot).
	However, we weren't checking explicitly for undetected errors, but
	rather errors with weight > 1, resulting in the circuit seen in the
	paper.
=#

