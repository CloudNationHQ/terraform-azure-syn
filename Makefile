.PHONY: test test_extended

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./syn_test.go

test_extended:
	cd tests && env go test -v -timeout 60m -run TestVault ./syn_extended_test.go
