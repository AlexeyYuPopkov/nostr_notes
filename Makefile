
codegen:
	dart run build_runner build --delete-conflicting-outputs

l10n:
	flutter gen-l10n

del_imports:
	dart fix --apply --code=unnecessary_import  --code=unused_import

relay_up:
	bundle exec fastlane relay_up

relay_clean:
	bundle exec fastlane relay_clean

relay_down:
	bundle exec fastlane relay_down

appbundle:
	flutter build appbundle --release