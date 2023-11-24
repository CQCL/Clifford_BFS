from julia import Pkg
Pkg.activate(".")

from julia import CliffordBFS

assert CliffordBFS.add1(1) == 2