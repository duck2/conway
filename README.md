# conway

A Game of Life implementation for the Mojo v3 board(Spartan 6 xc6slx9).

The implementation gives output to 1280x1024@60Hz VGA, with 3 bit color support.

# Building and running

A Makefile derived from the [Xilinx ISE Makefile project](https://github.com/duskwuff/Xilinx-ISE-Makefile) is provided. It is able to use Xilinx ISE tools for building and the [Mojo loader](https://alchitry.com/pages/mojo-loader) for loading the bitstream into the board. The paths to the executables are specified in the `project.cfg` file.

Running `make` should run the ISE tools in succession and finally load the resulting `.bin` file into the board through `/dev/ttyACM0`. The USB port can be specified in the Makefile.

The `screen.mem` file defines the initial state. By default, it includes a spaceship pattern. You can create other initial states from 64x64 .png images using the `mkmem.py` script. Some other default states are provided in the `img/` directory.

To get output, connect P15, P12 and P10 to VGA RGB through 470Ω(analog signal, internal impedance of screen is 75Ω!) and connect P6, P2 to VGA hsync, vsync. You should see the image scaled to 1280x1024 on the screen.
