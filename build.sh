#!/bin/sh
if [ ! -e /bin/zip ]; then
	echo "zip utility is not installed in your system!"
	echo "install it using package manager available in your system!"
	echo "Example for Ubuntu/Debian based systems :"
	echo "	\$ sudo apt install zip"
	echo "Example for Redhat/Fedora/CentOS based systems :"
	echo "	\$ sudo dnf install zip"
	echo "Example for Archlinux based systems :"
	echo "	\$ sudo pacman -S zip"
	echo "Example for OpenSUSE based systems :"
	echo "	\$ sudo zypper install zip"
	exit -1
fi

if [ ! -e /bin/luajit ]; then
	echo "liajit is not installed in your system!"
	echo "install it using package manager available in your system!"
	echo "Example for Ubuntu/Debian based systems :"
	echo "	\$ sudo apt install luajit"
	echo "Example for Redhat/Fedora/CentOS based systems :"
	echo "	\$ sudo dnf install luajit"
	echo "Example for Archlinux based systems :"
	echo "	\$ sudo pacman -S luajit"
	echo "Example for OpenSUSE based systems :"
	echo "	\$ sudo zypper install luajit"
	exit -1
fi

echo "Cleaning up and make it ready..."

# remove builded game
rm -f ./game.love

# cleanup build directory and make it again
rm -rf ./build 
mkdir -p ./build 

# copy game into build folder
cd ./game
cp -r ./ ../build
cd ..

echo "Compiling sources into bytecode..."
# enter build directory
cd ./build

# function to run on any lua file
compile(){
	echo "Compiling $1..."
	luajit -b $1 $1
	return $?
}
export -f compile # make function available in subshells

# find all lus files and compile it
find . -name '*.lua' -print0 | xargs -0 -I {} bash -c 'compile "$@"' _ {}

echo "Packing your game into archive..."
zip -9 -r ../game.love ./ # and pack into zip archive
