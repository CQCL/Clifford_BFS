# Clifford_BFS

This is a slight upgrade of a script I used to show that a hand-derived circuit contains the least CNots of any possible circuit that non-fault-tolerantly prepares the transversal logical $\left \vert + \right \rangle$ state of the smallest interesting colour code. 

## How to Replicate The Paper

In order to generate a circuit for non-fault-tolerant preparation of the $\left \vert \bar{+}\bar{+}\bar{+} \right \rangle$ state, we do the following:

```julia
	           _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.8.5 (2023-01-08)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> include("CNot_BFS.jl")
Main.CNot_BFS

julia> include("CNot_BFS_Sandbox.jl")
WARNING: replacing module CNot_BFS.
planar_cube_prep

julia> thing = all_partitions_cube_prep()
10-element Vector{QuantumClifford.sCNOT}:
 Symbolic two-qubit gate on qubit 1 and 5
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 1 and 6
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 1 and 7
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 2 and 5
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 3 and 6
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 4 and 7
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 6 and 8
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 2 and 6
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 4 and 6
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ
 Symbolic two-qubit gate on qubit 6 and 1
X₁ ⟼ + XX
X₂ ⟼ + _X
Z₁ ⟼ + Z_
Z₂ ⟼ + ZZ

```