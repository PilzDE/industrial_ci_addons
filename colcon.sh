#!/bin/bash

function run_coverage_build ()
{
    local extend=$1; shift
    local ws=$1; shift
    local pkg=$1

    local -a opts
    if [ "${PARALLEL_TESTS-true}" != true ]; then
        opts+=(--executor sequential)
    fi

    ici_exec_in_workspace "$extend" "$ws" colcon build "${opts[@]}" --cmake-target ${pkg}_coverage \
        --cmake-target-skip-unavailable --cmake-args -DENABLE_COVERAGE_TESTING=ON -DCMAKE_BUILD_TYPE=Debug
}
