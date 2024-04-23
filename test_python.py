"""
python binding and a simple test
"""

# pylint:disable=no-name-in-module, wrong-import-position
from julia import Pkg
Pkg.activate(".")
from julia import CliffordBFS

assert CliffordBFS.add1(1) == 2
