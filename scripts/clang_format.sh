#!/bin/bash
#-------------------------------------------------------------------------------
# Runs clang-format to all implementation files
#-------------------------------------------------------------------------------
echo "Running clang-format to all source files in current directory"
find . -iname *.hpp -o -iname *.cpp -o -iname *.h -o -iname *.c | xargs clang-format -i -style=file
echo "Done."
