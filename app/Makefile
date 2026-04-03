.PHONY: all clean get gen icons splash run build_apk build_ios

# Default target
all: get gen

clean:
	@echo "🧹 Cleaning project..."
	@flutter clean
	@flutter pub get

get:
	@echo "📦 Fetching dependencies..."
	@flutter pub get

gen:
	@echo "⚡ Generating code..."
	@dart run build_runner build --delete-conflicting-outputs

ffi:
	@echo "🔗 Generating FFI bindings..."
	@dart run ffigen --config ffigen.yaml

# icons:
# 	@echo "🎨 Generating icons..."
# 	@flutter pub run flutter_launcher_icons:main


run:
	@echo "▶️ Running app..."
	@flutter run -d windows
