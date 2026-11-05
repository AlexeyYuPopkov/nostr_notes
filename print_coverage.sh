# Generating Coverage Report
# Usage: ./print_coverage.sh [package ...]   (default: all packages)
printf "\e[33;1m%s\e[0m\n" '=== Generating Coverage Report ==='

packages=${*:-nostr common chat notes}
status=0
for pkg in $packages; do
	lcov --summary "packages/$pkg/coverage/lcov.info" | grep "lines\.*" | awk -v pkg="$pkg" '{print "Package " pkg ", Total Coverage: " $2}' || status=1
done

if [ $status -ne 0 ]; then
	printf "\e[31;1m%s\e[0m\n" '=== Coverage report generation error ==='
fi
