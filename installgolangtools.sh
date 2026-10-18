#!/bin/bash

# go install 로 설치된 패키지 모두 업데이트
# gup update
#
# 에러 패키지 체크해서 있으면 제거
# gup check | rg -i error
# gup remove 패키지1, 패키지2...
#
# 패키지 목록 파악 설치 커맨드로 변경시
# gup list | awk '{sub(/@.*/, "@latest", $2); print "go install " $2}' | pbcopy
#
# install tools to $GOPATH/bin
go install github.com/air-verse/air@latest
go install github.com/ysoftman/aleng@latest
go install github.com/klauspost/asmfmt/cmd/asmfmt@latest
go install golang.org/x/tools/cmd/bisect@latest
go install golang.org/x/tools/cmd/callgraph@latest
go install github.com/maaslalani/confetty@latest
go install github.com/CondensedMilk7/countryfetch/cmd/countryfetch@latest
go install github.com/ysoftman/cutstring@latest
go install golang.org/x/tools/cmd/deadcode@latest
go install golang.org/x/tools/cmd/digraph@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/eg@latest
go install github.com/ysoftman/enchash@latest
go install github.com/kisielk/errcheck@latest
go install golang.org/x/tools/cmd/file2fuzz@latest
go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
go install github.com/ysoftman/findm@latest
go install github.com/onsi/ginkgo/v2/ginkgo@latest
go install github.com/abice/go-enum@latest
go install github.com/google/go-licenses@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/twpayne/go-jsonstruct/v3/cmd/gojsonstruct@latest
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
go install github.com/fatih/gomodifytags@latest
go install golang.org/x/tools/cmd/gonew@latest
go install golang.org/x/tools/gopls@latest
go install github.com/securego/gosec/v2/cmd/gosec@latest
go install github.com/jstemmer/gotags@latest
go install github.com/rakyll/gotest@latest
go install github.com/cweill/gotests/gotests@latest
go install gotest.tools/gotestsum@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
go install golang.org/x/tools/cmd/goyacc@latest
go install github.com/nao1215/gup@latest
go install github.com/koron/iferr@latest
go install github.com/qeesung/image2ascii@latest
go install github.com/josharian/impl@latest
go install github.com/tmc/json-to-struct@latest
go install github.com/birdayz/kaf/cmd/kaf@latest
go install github.com/kakao/kubectl-cilium@latest
go install github.com/evilmartians/lefthook@latest
go install loov.dev/lensm@latest
go install github.com/vektra/mockery/v3@latest
go install go.uber.org/mock/mockgen@latest
go install github.com/fatih/motion@latest
go install github.com/mgechev/revive@latest
go install github.com/kyoh86/richgo@latest
go install mvdan.cc/sh/v3/cmd/shfmt@latest
go install golang.org/x/tools/cmd/ssadump@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install golang.org/x/tools/cmd/stress@latest
go install golang.org/x/tools/cmd/stringer@latest
go install github.com/swaggo/swag/cmd/swag@latest
go install github.com/mfridman/tparse@latest
go install github.com/tsenart/vegeta@latest
go install github.com/ysoftman/watchDust@latest
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
