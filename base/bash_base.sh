#!/bin/bash
#-------------------------------------------------------------------------------
# Base bash script for argument parsing and help
#-------------------------------------------------------------------------------

set -e

PWD=$(pwd)

while [[ $# -gt 0 ]]
do

key="$1"
case $key in
    -h|--help)
    HELP=YES
    ;;
    # Without argument
    -ex1|--example1)
    EXAMPLE1=YES
    ;;
    -ex2|--example2)
    # With argument
    EXAMPLE=$2
    shift
    ;;
    *)
    HELP=YES
    ;;
esac
shift # past argument or value
done

function show_help {
    echo "-------------------------"
    echo "Help"
    echo "-------------------------"

    echo "Supported parameters are:"
    echo "-h|--help                 Print this help"
}

if [ -n "$HELP" ]; then
    show_help
    exit
fi

