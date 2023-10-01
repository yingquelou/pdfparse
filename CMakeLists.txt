cmake_minimum_required(VERSION 3.27.4)
project(test LANGUAGES C)

include(./utils.cmake)


list(APPEND DEBUGLIST Debug RelWithDebInfo)
isInList(DEBUGLIST ${CMAKE_BUILD_TYPE} RESULT)
if(${RESULT})
    set(SHARED)
else()
    set(SHARED SHARED)
endif()
set(TARGEOUT ${CMAKE_BINARY_DIR}/target)
set(LIBRARY_OUTPUT_PATH ${TARGEOUT}/bin)
set(EXECUTABLE_OUTPUT_PATH ${TARGEOUT}/bin)

add_subdirectory(Pdf)


