.PHONY: build_cli
build_cli:
	cd cli && \
		cargo component build --release
	@echo "PASS: [+] Build for cli/"
	wac plug cli/target/wasm32-wasi/release/cli.wasm \
		--plug crypto/crypto.wasm \
		--plug githubapi/target/wasm32-wasi/release/githubapi.wasm \
		-o composed.wasm
	@echo "PASS: [+] wac plug"

.PHONY: build_crypto
build_crypto:
	cd crypto && \
		componentize-py \
			-d wit/world.wit \
			-w crypto \
			componentize app_crypto \
			-o crypto.wasm
	@echo "PASS: [+] Build for crypto/"

.PHONY: build_github_api
build_github_api:
	cd githubapi && \
		cargo component build --release
	@echo "PASS: [+] Build for githubapi/"

.PHONY: build
build: build_crypto build_github_api build_cli

.PHONY: run_gen_pass
run_gen_pass:
	wasmtime run composed.wasm -n password-gen -o gen_rand_pass

.PHONY: run_demo
run_demo:
	wasmtime run --env OPENAI_API_KEY="ABCD1234" --dir=. composed.wasm -n dipankar -o demo

.PHONY: run_get_latest_release
run_get_latest_release:
	wasmtime run -S inherit-network -S http composed.wasm -n dipankar -o pro_latest_release

.PHONY: clean
clean:
	rm -vrf cli/target crypto/crypto.wasm githubapi/githubapi.wasm composed.wasm
