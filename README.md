# floodwall-
Design of demountable flood barrier using julia and freecad.
# Operation
To ensure the proper functioning of the program, a bash / batch script exists in this project at barrier.sh or barrier.bat for windows.
Changing the parameters will change the dimensions of the barrier.
The main program written in julia is barrier1.jl. It depends of other julia scripts used in the design and estimation of the dimensions.
The main program accepts commandline arguments specified by the user from which it designs the flood barrier wall.
The julia program calculates the design dimensions which are then passed to a python script(FreeCAD).
The python script then outputs step files (in the simulations directory) that can be utilized by other CAD programs.
# Help
To see what command line options are available, run the main script with the help option specified,
  barrier1.jl --help
More documentation is to be provided soon.
# Dependecies.
Julia above v0.4 is needed.
CSV and Argparse libraries have to be installed via Pkg.add() in the julia console.
FreeCAD above version 0.16 is needed.




