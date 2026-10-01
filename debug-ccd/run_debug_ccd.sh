#!/bin/bash

[ -f ./test_project.sof ] || {
    echo ""
    echo "ERROR: cannot locate SOF file."
    echo ""
    #exit 1
}

[ -f ./test_project.jdi ] || {
    echo ""
    echo "ERROR: cannot locate JDI file."
    echo ""
    #exit 1
}

# launch the system console dashboard demo
pushd ./scripts/ >> /dev/null

./start_everything.sh

popd >> /dev/null

exit 0
