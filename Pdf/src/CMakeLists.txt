cmake_minimum_required(VERSION ${CMV})
project(pdfengin LANGUAGES C)

add_subdirectory(reader)
add_subdirectory(list)
add_subdirectory(common)
add_subdirectory(writer)

add_library(${PROJECT_NAME} ${SHARED} test.c)

include_directories(${HEADPATH})
target_link_libraries(${PROJECT_NAME} pdfreader)
