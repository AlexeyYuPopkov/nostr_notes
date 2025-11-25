cmake_minimum_required(VERSION 3.10)
project(NostrNotes)

set(CMAKE_CXX_STANDARD 17)

# RU: Включаем отладочную информацию
# EN: Enable debug information
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

# RU: Добавляем директории с исходниками
# EN: Add source directories
include_directories(src)

add_subdirectory(secp256k1)

# RU: Определяем режим сборки
# EN: Define the build mode
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")

    message(STATUS "=== 🔥 Building for WebAssembly with Emscripten ===")

    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")

    # RU: Определяем экспортируемые заголовки для WebAssembly
    # EN: Specify exported headers for WebAssembly
    add_executable(crypto_module
        src/aes.c
        src/aes_256_cbc.cpp
        src/secp_wrapper.cpp
        src/nip04.cpp
        src/base64/base64.c
        src/base64/cencode.c
        src/base64/cdecode.c
    )

    # RU: Линкуем с secp256k1
    # EN: Link with secp256k1
    target_link_libraries(crypto_module PRIVATE secp256k1)

    # RU: Указываем экспортируемые функции
    # EN: Specify exported functions
    file(WRITE ${CMAKE_BINARY_DIR}/exported_functions.txt "
        _encryptAes256Cbc
        _decryptAes256Cbc
        _deriveSharedKey
        _freeMemory
        _nip04encrypt
        _nip04decrypt
        _nip04decryptOld
        _malloc
        _free
        ")

    # target_link_options(crypto_module PRIVATE
    #     "-sSTANDALONE_WASM"
    #     "-sEXPORTED_FUNCTIONS=@${CMAKE_BINARY_DIR}/exported_functions.txt"
    #     "--no-entry"
    # )

    # RU: Настройки линковки для Emscripten
    # EN: Linker settings for Emscripten
    target_link_options(crypto_module PRIVATE
        "-sSTANDALONE_WASM=1"
        "-sEXPORTED_FUNCTIONS=@${CMAKE_BINARY_DIR}/exported_functions.txt"
        "-sEXPORTED_RUNTIME_METHODS=['cwrap','getValue','setValue','UTF8ToString','stringToUTF8','lengthBytesUTF8']"
        "--no-entry"
        "-sENVIRONMENT=web"
        "-sNO_FILESYSTEM=1"
        "-sDISABLE_EXCEPTION_CATCHING=1"
        "-fno-exceptions"
        "-fno-rtti"
        # RU: Минимальные флаги для работы без WASI
        # EN: Minimal flags for WASI-free operation
        "-sASSERTIONS=0"
        "-Os"
        "-sERROR_ON_UNDEFINED_SYMBOLS=0"
        "-sMALLOC=emmalloc"
        "-sALLOW_UNIMPLEMENTED_SYSCALLS=1"
    )

    # RU: Включаем оптимизации для WebAssembly
    # EN: Enable optimizations for WebAssembly
    target_include_directories(crypto_module PRIVATE 
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/secp256k1/include
        ${CMAKE_SOURCE_DIR}/src/base64
    )
    

# RU: Сборка для WebAssembly с Emscripten
# EN: Build for WebAssembly with Emscripten
# rm -rf build-wasm
# mkdir build-wasm
# cd build-wasm
# emcmake cmake ..
# emmake make

# rm -rf build-wasm && mkdir build-wasm && cd build-wasm
# emcmake cmake .. && emmake make && cd ../

# RU: заглушить fprintf, чтобы убрать зависимости от WASI
# EN: stub out fprintf to remove WASI dependencies
# secp256k1/src/util.h
# ifdef __EMSCRIPTEN__
# include <stdio.h>
# define printf(...) ((void)0)
# define fprintf(...) ((void)0)
# endif

# RU: Проверка на зависимости от WASI
# EN: Check for WASI dependencies
# wasm-objdump -x crypto_module.wasm | grep wasi


# cd secp256k1
# emconfigure ./autogen.sh
# emconfigure ./configure --disable-benchmark --disable-tests --disable-examples --disable-cli --enable-module-ecdh --enable-module-recovery
# emmake make clean
# emmake make

else()
    # RU: Основная библиотека
    # EN: Main library
    add_library(aes_256_cbc_lib 
        src/aes_256_cbc.cpp
        src/aes.c  
        src/secp_wrapper.cpp
        src/nip04.cpp
        src/tools.cpp
        src/base64/base64.c
        src/base64/cencode.c
        src/base64/cdecode.c
    )

    # RU: Линкуем с secp256k1
    # EN: Link with secp256k1
    target_link_libraries(aes_256_cbc_lib PRIVATE secp256k1)

    # RU: Основной исполняемый файл
    # EN: Main executable
    add_executable(main src/main.cpp)
    target_link_libraries(main aes_256_cbc_lib)

    # RU: Включаем директории с заголовками
    # EN: Include header directories
    target_include_directories(aes_256_cbc_lib PRIVATE 
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/secp256k1/include
        ${CMAKE_SOURCE_DIR}/src/base64
    )

    # RU: Включаем директории с заголовками
    # EN: Include header directories
    target_include_directories(main PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/secp256k1/include
        ${CMAKE_SOURCE_DIR}/src/base64
    )

    # ==== CATCH2 ====

    # RU: Подключаем Catch2 (установленный через brew)
    # EN: Include Catch2 (installed via brew)
    set(CMAKE_PREFIX_PATH "/opt/homebrew/share/catch2")

    find_package(Catch2 3 REQUIRED)

    # RU: Тестовый бинарник
    # EN: Test binary
    add_executable(test_aes_256_cbc tests/test_aes_256_cbc.cpp)
    add_executable(test_secp_wrapper tests/test_secp_wrapper.cpp)
    add_executable(test_nip04 tests/test_nip04.cpp)
    add_executable(test_base64 tests/test_base64.cpp)
    
    target_link_libraries(test_aes_256_cbc PRIVATE aes_256_cbc_lib Catch2::Catch2WithMain)
    target_link_libraries(test_secp_wrapper PRIVATE aes_256_cbc_lib Catch2::Catch2WithMain)
    target_link_libraries(test_nip04 PRIVATE aes_256_cbc_lib Catch2::Catch2WithMain)
    target_link_libraries(test_base64 PRIVATE aes_256_cbc_lib Catch2::Catch2WithMain)
    
    target_include_directories(test_aes_256_cbc PRIVATE ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/base64)
    target_include_directories(test_secp_wrapper PRIVATE ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/base64)
    target_include_directories(test_nip04 PRIVATE ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/base64)
    target_include_directories(test_base64 PRIVATE ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/src/base64)

    # RU: Регистрируем тесты для ctest
    # EN: Register tests for ctest
    include(CTest)
    include(Catch)
    catch_discover_tests(test_aes_256_cbc)
    catch_discover_tests(test_secp_wrapper)
    catch_discover_tests(test_nip04)


# rm -rf build && mkdir build && cd build
# cmake .. && cmake --build . && cd ../

endif()