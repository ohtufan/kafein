APP_NAME = Kafein
BUNDLE_ID = com.taostudio.kafein
BUILD_DIR = .build/release
APP_BUNDLE = build/$(APP_NAME).app
INSTALL_DIR = /Applications

.PHONY: build bundle install clean test run

build:
	swift build -c release

test:
	swift test

bundle: build
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	@mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	@cp "$(BUILD_DIR)/Kafein" "$(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)"
	@cp "Resources/Info.plist" "$(APP_BUNDLE)/Contents/"
	@cp "Resources/AppIcon.icns" "$(APP_BUNDLE)/Contents/Resources/"
	@echo "Built $(APP_BUNDLE)"

install: bundle
	@cp -R "$(APP_BUNDLE)" "$(INSTALL_DIR)/"
	@echo "Installed to $(INSTALL_DIR)/$(APP_NAME).app"

run: bundle
	@open "$(APP_BUNDLE)"

clean:
	swift package clean
	rm -rf build/
