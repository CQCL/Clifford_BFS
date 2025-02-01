"""
python binding and a simple test
"""

def test_binding():
    """
    test binding
    just add1 function so testing the
    import vs the CliffordBFS functionality
    """
    # pylint:disable = import-error, import-outside-toplevel, no-name-in-module
    from julia import Pkg
    Pkg.activate(".")
    from julia import CliffordBFS
    assert CliffordBFS.add1(1) == 2

if __name__ == "__main__":
    test_binding()
