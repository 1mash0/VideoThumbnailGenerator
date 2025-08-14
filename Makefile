COMMAND_NAME = vtg

.PHONY: install
install:
	swift build -c release
	sudo cp .build/release/$(COMMAND_NAME) /usr/local/bin/$(COMMAND_NAME)

.PHONY: uninstall
uninstall:
	sudo rm -f /usr/local/bin/$(COMMAND_NAME)