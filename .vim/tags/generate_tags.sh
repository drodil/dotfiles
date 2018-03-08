#!/bin/bash

# constants
INVALID_ARGS=255
INVALID_INPUT_DIR=1

# funcs
function help()
{
    echo "Usage: `basename $0` [-d /path/to/input/dir]"
    echo "Optional parameters:"
    echo "  [-o /path/to/file]"
    echo "      Write tags to given file"
    echo "  [-i type]"
    echo "      Folder type to be ignored"
    echo "  [-l lang]"
    echo "      Programming language (default=c++)"
    echo "  [-q]"
    echo "      Quiet"


}

function print_progress()
{
    if [ ! -z "$verbose" ]; then
        if [ ! -z "$1" ]; then
            echo "$1"
        fi
    fi
}

function print_error()
{
    if [ ! -z "$1" ]; then
        echo "Error: $1"
    else
        echo "Error occured"
    fi
}

if [ $# -lt 1 ]
then
    help
    exit $INVALID_ARGS
fi

# default values
# verbose values are:
#   0=quiet
#   1=script progress prints
#   2=verbose (script progress+ctags prints)
#   default is 1
verbose=1
lang="c++"

# parse parameters
while getopts "d:o:i:l:qvh?" options; do
    case $options in
        d ) input_dir=$OPTARG;;
        o ) output_file=$OPTARG;;
        i ) types_ignored=$OPTARG;;
        l ) lang=$OPTARG;;
        q ) verbose=0;;
        v ) verbose=2;;
        h ) help
            exit $INVALID_ARGS;;
        \? ) help
            exit $INVALID_ARGS;;
        * ) help
        exit $INVALID_ARGS;;
    esac
done
shift `expr $OPTIND - 1`

ctags_prints=""
if [ $verbose -eq 2 ]; then
    ctags_prints="-V"
fi

# check validity of params
if [ ! -d "$input_dir" ]; then
    print_error "Input directory $input_dir does not exist."
    exit $INVALID_INPUT_DIR
fi

print_progress "Sed ignore pattern list"
echo $types_ignored
if [ ! -z "$types_ignored" ]; then
    list="--exclude=$(echo "$types_ignored"| sed 's/\ /\ --exclude=/g')"
    echo $list
fi
print_progress "Input directory:  $input_dir"


if [ ! -z "$output_file" ]
then
    echo print_progress "Output file: $output_file"
    ctags -R $ctags_prints --sort=yes --$lang-kinds=+pl --fields=+iaS --extra=+q \
        --exclude="\.git"\
        --exclude="\.svn"\
        $list \
        -f $output_file \
        $input_dir
else
    ctags -R $ctags_prints --sort=yes --$lang-kinds=+pl --fields=+iaS --extra=+q  \
        --exclude="\.git"\
        --exclude="\.svn"\
        $list \
        $input_dir
fi

# end of script

