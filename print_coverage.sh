# Generating Coverage Report
printf "\e[33;1m%s\e[0m\n" '=== Generating Coverage Report ==='
lcov --summary packages/nostr/coverage/lcov.info | grep "lines\.*" | awk '{print "Package nostr, Total Coverage: " $2}'
lcov --summary packages/common/coverage/lcov.info | grep "lines\.*" | awk '{print "Package common, Total Coverage: " $2}'
lcov --summary packages/chat/coverage/lcov.info | grep "lines\.*" | awk '{print "Package chat, Total Coverage: " $2}'
lcov --summary packages/notes/coverage/lcov.info | grep "lines\.*" | awk '{print "Package notes, Total Coverage: " $2}'

if [ $? -ne 0 ]; then
	printf "\e[31;1m%s\e[0m\n" '=== Coverage report generation error ==='
fi    
