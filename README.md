# 12 GeV MOLLER Experiment at Jefferson Lab

This repository contains the *runtime environment* for the remoll simulation framework.

You can use this environment
* if you are happy with the existing pre-programmed functionality in the latest master release and/or development branch (both are available as runtime environments),
* if you are only seeking to make small modifications to the provided (comprehensive and documented) example macro,
* if you are only seeking to make small modifications to the MOLLER geometry which you have downloaded separately.

You should use the [full development environment](https://github.com/JeffersonLab/remoll) only
* if you want to modify the C++ code that underlies this simulation, primarily to add new functionality.
In that case you will want to subscribe to the simulation developers mailing list and call in to our regular developer phone meetings.

## Using singularity

This runtime environment should run on any system that has a recent version (2.4 or higher) of the container framework [singularity](http://singularity.lbl.gov/) developed at LBL. This includes the Jefferson Lab interactive and batch farm nodes.

At Jefferson Lab, you can load singularity using the following module command:
```
module load singularity-2.4
```
You can test whether this was successfull with `singularity --version`. You can add this line to your `.login` file and it will be run every time you log in.

To install singularity v2.4 or higher on your own Linux system, follow their [installation instructions](http://singularity.lbl.gov/install-linux). Other operating systems are supported as well, though your mileage may vary.

## Running simulations (quickstart)
To run the provided example macro (10k Møller scattering events with reasonable defaults), copy the following commands:
```
git clone https://github.com/JeffersonLab/remoll-run.git
./remoll-run.sh runexample.mac
```
The output ROOT file will be created in the `rootfiles` directory. The `./remoll-run.sh` command will automatically download the most recent version of remoll.

## Available docker and singularity images
* The docker images are on [Docker Hub](https://hub.docker.com/r/jeffersonlab/remoll/tags/).
* The singularity images are on [Singularity Hub](https://www.singularity-hub.org/collections/241).
