# CMake generated Testfile for 
# Source directory: /Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src
# Build directory: /Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build/secp256k1/src
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test([=[secp256k1_noverify_tests]=] "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build/secp256k1/bin/noverify_tests")
set_tests_properties([=[secp256k1_noverify_tests]=] PROPERTIES  _BACKTRACE_TRIPLES "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;139;add_test;/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;0;")
add_test([=[secp256k1_tests]=] "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build/secp256k1/bin/tests")
set_tests_properties([=[secp256k1_tests]=] PROPERTIES  _BACKTRACE_TRIPLES "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;144;add_test;/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;0;")
add_test([=[secp256k1_exhaustive_tests]=] "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build/secp256k1/bin/exhaustive_tests")
set_tests_properties([=[secp256k1_exhaustive_tests]=] PROPERTIES  _BACKTRACE_TRIPLES "/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;153;add_test;/Users/alekseypopkov/Doc/upwork/gathr_1/cpp/secp256k1/src/CMakeLists.txt;0;")
