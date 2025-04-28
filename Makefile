.PHONY: build install uninstall clean

BINARY = r2cli

build:
	cargo build --release

install:
	cp target/release/$(BINARY) ~/.cargo/bin/$(BINARY)

uninstall:
	rm -f ~/.cargo/bin/$(BINARY)

clean:
	cargo clean