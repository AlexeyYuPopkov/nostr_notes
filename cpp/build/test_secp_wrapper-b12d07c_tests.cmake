add_test( deriveSharedKey /Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build/test_secp_wrapper deriveSharedKey  )
set_tests_properties( deriveSharedKey PROPERTIES WORKING_DIRECTORY /Users/alekseypopkov/Doc/upwork/gathr_1/cpp/build SKIP_RETURN_CODE 4)
set( test_secp_wrapper_TESTS deriveSharedKey)
