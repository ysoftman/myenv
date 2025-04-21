#!/bin/bash

go_fumpt_files() {
    # gofumpt 는 gofmt, goimports 기능을 포함하면서 더 엄격한 포맷팅 규칙을 적용하는 확장된 포맷팅 방식이다.
    # go install mvdan.cc/gofumpt@latest
    # .go 파일들에 대해 포맷팅
    gofumpt -w -l "$(fd --type file .go)"
}

go_pls_check() {
    # go install golang.org/x/tools/gopls@latest
    # gopls 체크사항 확인
    gopls check "$(fd --type file .go)"
}

go_modernize() {
    # modernize 방식으로 일괄 변경
    go run golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest -test -fix ./...
}

go_ci_lint() {
    # go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
    golangci-lint run
}
