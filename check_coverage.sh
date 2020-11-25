#!/bin/bash


function check_coverage ()
{
    ICI_ADDONS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    source "${ICI_SRC_PATH}/workspace.sh"
    source "${ICI_SRC_PATH}/util.sh"
    source "${ICI_ADDONS_PATH}/${BUILDER}.sh"

    echo "Checking coverage for [$*]"

    coverage_pass=true

    for pkg in "$@"; do
        echo "Creating coverage for [$pkg]"

        ws=~/target_ws
        extend="/opt/ros/$ROS_DISTRO"

        run_coverage_build "$extend" "$ws" "$pkg"

        if [ -a $ws/build/$pkg/${pkg}_coverage.info.cleaned ]; then
            echo "Coverage summary for $pkg ----------------------"
            lcov --summary $ws/build/$pkg/${pkg}_coverage.info.cleaned
            echo "---------------------------------------------------"

            line_cov_percentage=$(lcov --summary $ws/build/$pkg/${pkg}_coverage.info.cleaned 2>&1 | grep -Poi "lines\.*: \K[0-9.]*")
            required_coverage="100.0"
        else
            cd $HOME/.ros
            echo "Coverage summary for $pkg"
            python-coverage report --include "$ws/src/$TARGET_REPO_NAME/$pkg/*" --omit "*/$pkg/test/*"

            line_cov_percentage=$(python-coverage report --include "$ws/src/$TARGET_REPO_NAME/$pkg/*" --omit "*/$pkg/test/*" | grep -Poi "TOTAL.* ([0-9]*){2} \K[0-9]*")
            required_coverage="100"
        fi

        if [ "$line_cov_percentage" != "$required_coverage" ]; then
            result_str="$pkg: $line_cov_percentage%(required:$required_coverage%)\e[${ANSI_RED}m[failed]\e[0m"
            echo -e $result_str
            coverages+=("$result_str")
            coverage_pass=false
        else
            result_str="$pkg($line_cov_percentage%)\e[${ANSI_GREEN}m[pass]\e[0m"
            echo -e $result_str
            coverages+=("$result_str")
        fi

    done

    if [ "${coverages// }" != "" ]; then
        echo -e "Coverage results:"
        for coverage in "${coverages[@]}"; do
            echo -e " * $coverage"
        done
    fi

    if ! $coverage_pass; then
    exit 1;
    fi
}


