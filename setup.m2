-* setup.m2

For users who are new to Macaulay2 / Python. Run this once, from the folder
containing this file, BEFORE loading CohomologyZeroLociInHomogeneousVarieties:

    load "setup.m2"

It checks whether Python, pip and NumPy are available to Macaulay2, and if
pip or NumPy are missing it tries to install them automatically. It never
touches anything outside a Python virtual environment it creates itself
(inside Macaulay2's own applicationDirectory()); it does not need admin/sudo
rights unless your system is missing basic Python tools, in which case it
tells you the exact command to run.
*-

needsPackage "Python";

if not (options Python).OptionalComponentsPresent then error ///
This Macaulay2 was not built with Python support, which
CohomologyZeroLociInHomogeneousVarieties requires.

Download a Macaulay2 binary that already includes Python (most official
releases do):
    https://github.com/Macaulay2/M2/releases
If you compiled Macaulay2 yourself, reconfigure with --with-python, rebuild,
and run this script again.
///;

-- returns true if "import moduleName" succeeds in the Python Macaulay2 is
-- currently using
hasModule = moduleName -> (
    py := toString ((import "sys")@@"executable");
    run(py | " -c \"import " | moduleName | "\" >/dev/null 2>&1") == 0
    );

-- creates an isolated venv (with pip preinstalled), points Macaulay2's
-- Python package at it, and installs numpy there
installNumPyInFreshVenv = () -> (
    venvDir := applicationDirectory() | "CohomologyZeroLociInHomogeneousVarieties-venv";
    if fileExists venvDir then
        print ("A virtual environment already exists at " | venvDir | " -- reusing it.")
    else (
        print ("Creating a Python virtual environment at " | venvDir | " ...");
        ok := true;
        try setupVirtualEnvironment venvDir else ok = false;
        if not ok then error ///
Could not create a Python virtual environment. This usually means your
system Python is missing its "venv" module.

On Debian/Ubuntu, open a terminal and run:
    sudo apt install python3-venv python3-pip
On Fedora/RHEL:
    sudo dnf install python3-venv python3-pip
On Windows/macOS, the easiest fix is to reinstall Python from
    https://www.python.org/downloads/
which bundles both pip and venv.

Then restart Macaulay2 and run:  load "setup.m2"
///;
        );
    venvPython := venvDir | "/bin/python3";
    print ("Installing numpy into " | venvPython | " ...");
    -- installed as an external process, not via M2's Python package: that
    -- package may already be loaded with a different executable in this
    -- session, and M2 does not allow switching executables without a restart
    if run(venvPython | " -m pip install numpy") != 0 then error ///
pip install numpy failed inside the virtual environment -- see the output
above for details.
///;
    print "";
    print "NumPy was installed successfully in the virtual environment.";
    print "";
    print "IMPORTANT: in every new Macaulay2 session, run this line BEFORE";
    print "loading CohomologyZeroLociInHomogeneousVarieties, so it keeps using";
    print "the same Python environment:";
    print "";
    print ("    loadPackage(\"Python\", Configuration => {\"executable\" => \"" | venvPython | "\"})");
    print "";
    print "You may want to add that line to your init.m2 (see the M2 manual";
    print "entry on \"initialization file\") so you don't have to type it every time.";
    );

print "Checking for NumPy in the Python that Macaulay2 is currently using...";

if hasModule "numpy" then (
    print "NumPy is already available -- you're all set. You can now run:";
    print "    needsPackage \"CohomologyZeroLociInHomogeneousVarieties\"";
    ) else (
    print "NumPy not found.";
    print "Checking for pip...";
    py := toString ((import "sys")@@"executable");
    havePip := run(py | " -m pip --version") == 0;
    if not havePip then (
        print "pip not found -- trying to bootstrap it with ensurepip...";
        havePip = run(py | " -m ensurepip --upgrade") == 0;
        );
    installed := false;
    if havePip then (
        print "pip is available. Installing numpy...";
        try (pipInstall "numpy"; installed = true) else (
            print "pip install failed for this Python (it may be a system-managed";
            print "installation that refuses direct installs).";
            );
        );
    if not installed then (
        print "Falling back to an isolated virtual environment...";
        -- installNumPyInFreshVenv installs into a separate venv Python, not
        -- the one "hasModule"/"havePip" above just checked, and it errors
        -- out itself on failure, so its own success is the signal here
        try (installNumPyInFreshVenv(); installed = true) else
            print "Automatic setup failed -- see the messages above for what to do.";
        );
    if installed then (
        print "";
        print "Setup complete.";
        );
    )
