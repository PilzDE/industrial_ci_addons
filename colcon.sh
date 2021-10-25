#!/bin/bash

# Only support cpp coverage. Re-use the build in target workspace.
# This requires setting CMAKE_ARGS: '-DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage"'
function run_coverage_build ()
{
    local extend=$1; shift
    local ws=$1; shift
    local pkg=$1

    COVERAGE_EXCLUDES=${COVERAGE_EXCLUDES-""}

    cd $ws/build
    lcov --capture --directory . --initial --output-file $pkg/${pkg}_coverage.base
    lcov --capture --directory . --output-file $pkg/${pkg}_coverage.info
    cd $pkg
    lcov --add-tracefile ${pkg}_coverage.base --add-tracefile ${pkg}_coverage.info --output-file ${pkg}_coverage.total
    lcov --remove ${pkg}_coverage.total "*/test/*" $COVERAGE_EXCLUDES --output-file ${pkg}_coverage.info.removed
    lcov --extract ${pkg}_coverage.info.removed "*/src/$pkg/*" --output-file ${pkg}_coverage.info.cleaned
}
