.PHONY: compile compile_branch_sample compile_branch_count compile_branches

compile_branches: src/states/parallel.json $(wildcard out/states/branches/*.json)
	mkdir -p out/states/branches
	jq -s '.[0] as $$base | .[1:] | reduce .[] as $$branch ($$base; .Parallel.Branches += [$$branch // []])' $^ > out/states/parallel.json

compile_branch_count: src/states/branches/execute_count/execute_count.json $(wildcard src/states/branches/execute_count/states/*.json)
	mkdir -p out/states/branches
	jq -s '.[0] as $$base | .[1:] | reduce .[] as $$state ($$base; .States += $$state)' $^ > out/states/branches/execute_count.json

compile_branch_sample: src/states/branches/execute_sample/execute_sample.json $(wildcard src/states/branches/execute_sample/states/*.json)
	mkdir -p out/states/branches
	jq -s '.[0] as $$base | .[1:] | reduce .[] as $$state ($$base; .States += $$state)' $^ > out/states/branches/execute_sample.json

compile_machine: src/state_machine.json $(wildcard out/states/*.json)
	mkdir -p out
	jq -s '.[0] as $$base | .[1:] | reduce .[] as $$state ($$base; .States += $$state)' $^ > out/state_machine.json

compile: src/state_machine.json $(wildcard out/states/*.json)
	mkdir -p out/states
	cp src/states/*.json out/states
	$(MAKE) compile_branch_count
	$(MAKE) compile_branch_sample
	$(MAKE) compile_branches
	$(MAKE) compile_machine
	cd infra/step_function && sam validate --lint

build:
	cd infra/step_function && sam build $(flags)

package:
	cd infra/step_function && sam package $(flags)

deploy:
	cd infra/step_function && sam deploy $(flags)

delete:
	cd infra/step_function && sam delete $(flags)

clean:
	rm -rf out
	rm -rf infra/step_function/.aws-sam
