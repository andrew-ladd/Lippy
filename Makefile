PROJECT := Clippy.xcodeproj
SCHEME := Clippy
CONFIGURATION ?= Debug
DERIVED_DATA ?= /tmp/LippyDerivedData
APP_NAME := Clippy.app
BUILT_APP := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/$(APP_NAME)
INSTALL_DIR := /Applications
INSTALLED_APP := $(INSTALL_DIR)/$(APP_NAME)

.PHONY: build install reinstall uninstall clean

build:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		build \
		CODE_SIGNING_ALLOWED=NO

install: build
	-killall Clippy
	rm -rf "$(INSTALLED_APP)"
	ditto "$(BUILT_APP)" "$(INSTALLED_APP)"
	codesign --force --deep --sign - "$(INSTALLED_APP)"

reinstall: install
	open "$(INSTALLED_APP)"

uninstall:
	-killall Clippy
	rm -rf "$(INSTALLED_APP)"

clean:
	xcodebuild -project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		clean
