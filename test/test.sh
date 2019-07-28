#!/bin/bash

export _HANDLER=index.handler
export LAMBDA_TASK_ROOT=$(pwd)/test
export AWS_LAMBDA_RUNTIME_API=localhost:8080

racket test/test.rkt & PROC_ID=$!

sleep 5s

racket runtime.rkt

