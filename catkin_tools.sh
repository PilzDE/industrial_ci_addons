#!/bin/bash

function run_coverage_build ()
{
    local extend=$1; shift
    local ws=$1; shift
    local pkg=$1

    local -a opts
    if [ "${PARALLEL_TESTS-true}" != true ]; then
        opts+=(-j1)
    fi

    ici_exec_in_workspace "$extend" "$ws" catkin config --cmake-args -DENABLE_COVERAGE_TESTING=ON -DCMAKE_BUILD_TYPE=Debug
    ici_exec_in_workspace "$extend" "$ws" catkin build $pkg -v --no-deps --catkin-make-args tests
    ici_exec_in_workspace "$extend" "$ws" catkin build $pkg -v "${opts[@]}" --no-deps --catkin-make-args ${pkg}_coverage
}
