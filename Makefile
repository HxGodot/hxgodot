
UNAME := $(shell uname)

bootstrap:
	mkdir -p test/demo/bin

release: bootstrap
	haxe build-lib.hxml
ifeq ($(UNAME),Windows_NT)
	cp bin/HxGodot.dll test/demo/bin
endif
ifeq ($(UNAME),Darwin)
	cp bin/HxGodot.dylib test/demo/bin
endif

debug: bootstrap
	haxe build-lib.hxml -debug
ifeq ($(UNAME),Windows_NT)
	cp bin/HxGodot-debug.dll test/demo/bin
endif
ifeq ($(UNAME),Darwin)
	cp bin/HxGodot-debug.dylib test/demo/bin
endif

.PHONY: bootstrap release debug