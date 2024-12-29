# set(CMAKE_TOOLCHAIN_FILE $ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake)
cmake_minimum_required(VERSION 3.10)
project(test LANGUAGES C CXX)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

add_executable(${PROJECT_NAME} test.cpp)
add_subdirectory(Pdf)
