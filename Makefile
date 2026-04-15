
bootstrap:
	melos bootstrap

pubget:
	melos exec --concurrency=1 -- flutter pub get

codegen:
	melos exec --concurrency=1 -- dart run build_runner build --delete-conflicting-outputs

l10n:
	melos exec --concurrency=1 --file-exists=l10n.yaml -- flutter gen-l10n

del_imports:
	melos exec --concurrency=1 -- dart fix --apply --code=unnecessary_import  --code=unused_import

test:
	melos exec --concurrency=1 -- flutter test --coverage
	./print_coverage.sh
	mkdir -p coverage
	for pkg in nostr common chat notes; do \
		if [ -f packages/$$pkg/coverage/lcov.info ]; then \
			sed "s|SF:|SF:packages/$$pkg/|g" packages/$$pkg/coverage/lcov.info > /tmp/lcov_$$pkg.info; \
		fi; \
	done
	lcov $$(for pkg in nostr common chat notes; do [ -f /tmp/lcov_$$pkg.info ] && echo "-a /tmp/lcov_$$pkg.info"; done) -o coverage/lcov.info
	@echo "Merged coverage written to coverage/lcov.info"

relay_up:
	bundle exec fastlane relay_up

relay_clean:
	bundle exec fastlane relay_clean

relay_down:
	bundle exec fastlane relay_down

appbundle:
	flutter build appbundle --release

# ffi-macos-crypto:
# 	cd cpp/ffi && cmake -B build-macos -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 && cmake --build build-macos

# ffi-macos-copy-crypto:
# 	rm -rf macos/ffi/crypto_module.framework
# 	cp -a cpp/ffi/build-macos/crypto_module.framework macos/ffi/
# 	cp cpp/ffi/macos/crypto_module.podspec  macos/ffi/crypto_module.podspec
# 	cd macos && rm -rf Pods Podfile.lock || true && pod install --repo-update && cd ..

ffi-macos-crypto:
	cd cpp/ffi && cmake -B build-macos && cmake --build build-macos --config Release && cd ..

ffi-macos-copy-crypto:
	rm -rf macos/ffi/crypto_module.framework
	cp -a cpp/ffi/build-macos/crypto_module.framework macos/ffi/
	cp cpp/ffi/macos/crypto_module.podspec  macos/ffi/crypto_module.podspec
	cp cpp/ffi/macos/Info.plist macos/ffi/crypto_module.framework/Resources/Info.plist
	cd macos && rm -rf Pods Podfile.lock || true && pod install --repo-update && cd ..

ffi-ios-crypto:
	cd cpp/ffi && cmake -B build-ios -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphoneos && \
	cmake --build build-ios --config Release && cd ..

ffi-ios-xcframework:
	rm -rf ios/ffi/crypto_module.framework
	cd cpp/ffi && \
	cmake -B build-ios-device -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphoneos && \
	cmake --build build-ios-device --config Release
	cd cpp/ffi && \
	cmake -B build-ios-sim -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphonesimulator && \
	cmake --build build-ios-sim --config Release
	rm -rf ios/ffi/crypto_module.xcframework
	cp cpp/ffi/ios/Info.plist cpp/ffi/build-ios-device/Release-iphoneos/crypto_module.framework/Info.plist
	cp cpp/ffi/ios/Info.plist cpp/ffi/build-ios-sim/Release-iphonesimulator/crypto_module.framework/Info.plist
	cp cpp/ffi/ios/Package.swift  ios/ffi/Package.swift
	xcodebuild -create-xcframework -framework cpp/ffi/build-ios-device/Release-iphoneos/crypto_module.framework -framework cpp/ffi/build-ios-sim/Release-iphonesimulator/crypto_module.framework -output ios/ffi/crypto_module.xcframework
# 	cd ios && rm -rf Pods Podfile.lock || true && pod install --repo-update && cd ..

ffi-ios-copy-crypto:
	rm -rf ios/ffi/crypto_module.framework
	cp -a cpp/ffi/build-ios/crypto_module.framework ios/ffi/
	cp cpp/ffi/ios/crypto_module.podspec  ios/ffi/crypto_module.podspec
	cd ios && rm -rf Pods Podfile.lock || true && pod install --repo-update && cd ..

NDK := $(HOME)/Library/Android/sdk/ndk/28.2.13676358

ffi-android-arm64-crypto:
	cd cpp/ffi && cmake -B build-android-arm64 -DCMAKE_TOOLCHAIN_FILE=$(NDK)/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 && \
	cmake --build build-android-arm64
	mkdir -p android/app/src/main/jniLibs/arm64-v8a
	cp cpp/ffi/build-android-arm64/bin/android/arm64-v8a/libcrypto_module.so android/app/src/main/jniLibs/arm64-v8a/crypto_module.so

ffi-android-x86_64-crypto:
	cd cpp/ffi && cmake -B build-android-x86_64 -DCMAKE_TOOLCHAIN_FILE=$(NDK)/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_PLATFORM=android-21 && \
	cmake --build build-android-x86_64
	mkdir -p android/app/src/main/jniLibs/x86_64
	cp cpp/ffi/build-android-x86_64/bin/android/x86_64/libcrypto_module.so android/app/src/main/jniLibs/x86_64/crypto_module.so

ffi-android: ffi-android-arm64-crypto ffi-android-arm64-crypto


ffi-gen-crypto_module:
	dart run ffigen --config ffigen_crypto_module.yaml