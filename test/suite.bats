#!/usr/bin/env bats

load test_helper

@test "Assert ${RUN_SH} exists" {
  run ls ${RUN_SH}
  assert_success
}

@test "Assert mocked azk exists" {
  run command -v azk
  assert_success
}

@test "Assert run.sh with repo" {
  result=$( cat ${RUN_SH} | sh -s ${MOCK_PROJECT} )
  run echo $result
  assert_output "azk agent start azk start -o ${MOCK_PROJECT}"
}

@test "Assert run.sh with repo and branch" {
  result=$( cat ${RUN_SH} | sh -s ${MOCK_PROJECT} ${MOCK_BRANCH} )
  run echo $result
  assert_output "azk agent start azk start -o ${MOCK_PROJECT} --git-ref ${MOCK_BRANCH}"
}

@test "Refute run.sh without repo" {
  result=$( cat ${RUN_SH} | sh ) || true
  run echo $result
  assert_match "It seems you haven't copied the whole command"
}

@test "Refute run.sh without azk" {
  AZK_DIR=$(which azk)
  mv ${AZK_DIR} ${AZK_DIR}.bkp
  result=$( cat ${RUN_SH} | sh -s ${MOCK_PROJECT} ${MOCK_BRANCH} ) || true
  run echo $result
  assert_match "It seems you don't have azk installed on your machine yet"
  mv ${AZK_DIR}.bkp ${AZK_DIR}
}