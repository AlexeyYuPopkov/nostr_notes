cmake_minimum_required(VERSION 3.10)
project(NostrNotes)

set(CMAKE_CXX_STANDARD 17)

# Включаем отладочную информацию
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

# set(EMCC_ROOT_DIR "/opt/homebrew/Cellar/emscripten/3.1.50/libexec/system/include")

# Добавляем директории с исходниками
include_directories(src)

# Определяем режим сборки
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")

    message(STATUS "=== 🔥 Building for WebAssembly with Emscripten ===")

    set(CMAKE_EXECUTABLE_SUFFIX ".wasm")

    # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s EXPORTED_FUNCTIONS='[\"_someFunction\",\"_encryptAes256Cbc\", \"_decryptAes256Cbc\", \"_malloc\", \"_free\"]'")
    # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s EXPORTED_RUNTIME_METHODS='[\"ccall\", \"cwrap\"]'")

    # Добавляем tiny-AES и обёртку
    add_executable(aes_module
        src/aes.c
        src/aes_256_cbc.cpp
        # src/wrapper.cpp
    )

    # target_link_options(aes_module PRIVATE
    #     "-sWASM=1"
    #     "-sMODULARIZE=1"
    #     "-sENVIRONMENT=web"
    #     "-sEXPORTED_FUNCTIONS=[\"_encryptAes256Cbc\",\"_decryptAes256Cbc\",\"_malloc\",\"_free\"]"
    #     "-sEXPORTED_RUNTIME_METHODS=[\"ccall\",\"cwrap\"]"
    # )

    target_link_options(aes_module PRIVATE
        "-sSTANDALONE_WASM"
        "-sEXPORTED_FUNCTIONS=[\"_someFunction\",\"_encryptAes256Cbc\",\"_decryptAes256Cbc\",\"_freeMemory\",\"_malloc\", \"_free\"]"
        "-sERROR_ON_UNDEFINED_SYMBOLS=0"
        "--no-entry"
    )

    target_include_directories(aes_module PRIVATE ${CMAKE_SOURCE_DIR}/src)

# Удаляем старую сборку
# rm -rf build-wasm
# mkdir build-wasm
# cd build-wasm
# emcmake cmake ..
# emmake make

# rm -rf build-wasm && mkdir build-wasm && cd build-wasm && emcmake cmake .. && emmake make

else()
    # Основная библиотека
    add_library(aes_256_cbc_lib 
        src/aes_256_cbc.cpp
        src/aes.c  # Добавляем AES реализацию
    )
    # target_include_directories(aes_256_cbc_lib)
    # target_link_libraries(aes_256_cbc_lib)

    # Основной исполняемый файл
    add_executable(main src/main.cpp)
    target_link_libraries(main aes_256_cbc_lib)

    # ==== CATCH2 ====

    # Подключаем Catch2 (установленный через brew)
    set(CMAKE_PREFIX_PATH "/opt/homebrew/share/catch2")

    find_package(Catch2 3 REQUIRED)

    # Тестовый бинарник
    add_executable(tests tests/test_main.cpp)
    target_link_libraries(tests PRIVATE aes_256_cbc_lib Catch2::Catch2WithMain)

    # Регистрируем тесты для ctest
    include(CTest)
    include(Catch)
    catch_discover_tests(tests)

endif()