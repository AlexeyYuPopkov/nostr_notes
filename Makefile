
codegen:
	dart run build_runner build --delete-conflicting-outputs

l10n:
	flutter gen-l10n

del_imports:
	dart fix --apply --code=unnecessary_import  --code=unused_import