cmake_minimum_required(VERSION 3.15)
project(crypto_module)


set(MACOS FALSE)
set(IOS FALSE)
set(ANDROID FALSE)

# Определение платформы
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND NOT IOS)
    set(MACOS TRUE)
    message(STATUS "Configuring for macOS")
elseif(IOS OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(IOS TRUE)
    message(STATUS "Configuring for iOS")
elseif(ANDROID OR CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(ANDROID TRUE)
    message(STATUS "Configuring for Android")
else()
    message(WARNING "Unknown platform - configuration might not work correctly")
endif()

# Пути к исходникам и заголовкам
set(SRC_DIR "${CMAKE_SOURCE_DIR}/../src")
set(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../include")
set(SECP256K1_DIR "${CMAKE_SOURCE_DIR}/../secp256k1")

# Настройки для разных платформ
if(MACOS OR IOS)
    # Общие настройки для Apple платформ
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum OS deployment version")
    
    if(IOS)
        # Специфичные настройки для iOS
        set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET ${CMAKE_OSX_DEPLOYMENT_TARGET})
        set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED FALSE)
        set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")
        
        # Настройка архитектур для iOS
        set(IOS_ARCH arm64 x86_64) # arm64 для устройств, x86_64 для симулятора
        set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCH} CACHE STRING "Build architectures for iOS")
        
        add_library(crypto_module SHARED
            ${SRC_DIR}/secp_wrapper.cpp
            # Добавьте другие исходники по необходимости
        )
        
        target_link_libraries(crypto_module "-framework Foundation")
        set_target_properties(crypto_module PROPERTIES
            FRAMEWORK TRUE
            FRAMEWORK_VERSION A
            MACOSX_FRAMEWORK_IDENTIFIER com.crypto.module
            PUBLIC_HEADER "${INCLUDE_DIR}/secp_wrapper.h"
            XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
        )
        
    else() # macOS
        
        add_library(crypto_module SHARED
            ${SRC_DIR}/secp_wrapper.cpp
            # Добавьте другие исходники по необходимости
        )
        
        # Специфичные настройки только для macOS (если есть)
        target_link_libraries(crypto_module "-framework CoreFoundation")
        
        set_target_properties(crypto_module PROPERTIES
            FRAMEWORK TRUE
            FRAMEWORK_VERSION A
            MACOSX_FRAMEWORK_IDENTIFIER com.alexey.yu.popkov.crypto_module
            PUBLIC_HEADER "${INCLUDE_DIR}/secp_wrapper.h"
            XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
            )
    endif()

elseif(ANDROID)
    # Настройки для Android
    # Требуется запускать cmake с:
    # -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake
    # -DANDROID_ABI=arm64-v8a или x86_64
    # -DANDROID_PLATFORM=android-21

    if(NOT ANDROID_ABI)
        set(ANDROID_ABI "arm64-v8a" CACHE STRING "Android ABI")
    endif()
    if(NOT ANDROID_PLATFORM)
        set(ANDROID_PLATFORM "android-21" CACHE STRING "Android platform")
    endif()

    # Выводить .so в отдельную папку для ABI
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/android/${ANDROID_ABI})

    add_library(crypto_module SHARED
        ${SRC_DIR}/secp_wrapper.cpp
        # Добавьте другие исходники по необходимости
    )

    # Можно добавить дополнительные опции компилятора, если нужно
    target_compile_options(crypto_module PRIVATE -fPIC)

    # Пример: если нужны дополнительные зависимости, добавьте их здесь
    # target_link_libraries(crypto_module ...)

    message(STATUS "Android ABI: ${ANDROID_ABI}")
    message(STATUS "Android platform: ${ANDROID_PLATFORM}")
endif()

# Общие настройки (для всех платформ)
if(TARGET crypto_module)
    if(EXISTS ${INCLUDE_DIR})
        target_include_directories(crypto_module PUBLIC ${INCLUDE_DIR})
    endif()
    target_include_directories(crypto_module PUBLIC ${SRC_DIR})
    target_include_directories(crypto_module PUBLIC ${SECP256K1_DIR}/include)

    # Линковка с secp256k1 (если требуется)
    add_subdirectory(${SECP256K1_DIR} ${CMAKE_BINARY_DIR}/secp256k1_build)
    target_link_libraries(crypto_module secp256k1)
endif()

# ---
# Пример вызова для Android:
# cmake -B build-android-arm64 -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21
# cmake --build build-android-arm64
#
# Для x86_64:
# cmake -B build-android-x86_64 -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI=x86_64 -DANDROID_PLATFORM=android-21
# cmake --build build-android-x86_64
#
# Пример вызова для macOS:
# cmake -B build-macos -G Xcode
# cmake --build build-macos --config Release
#
# Пример вызова для iOS:
# cmake -B build-ios -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=iphoneos
# cmake --build build-ios --config Release

