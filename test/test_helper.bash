__FILE__="${BASH_SOURCE[0]}"
export TESTS_DIR=$( cd "$( dirname "${__FILE__}" )" && pwd )
export RUN_SH=$(readlink -f $TESTS_DIR/../start.sh)

load ${TESTS_DIR}/shared/assertions.bash

MOCK_PROJECT="repo/project"
MOCK_BRANCH="branch"