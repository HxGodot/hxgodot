

bootstrap:
	mkdir -p test/demo/bin

release: bootstrap
	haxe build-lib.hxml
	cp bin/HxGodot.dll test/demo/bin

debug: generate bootstrap
	haxe build-lib.hxml -debug
	cp bin/HxGodot-debug.dll test/demo/bin

generate:
	haxe build-gen.hxml

.PHONY: bootstrap release debug