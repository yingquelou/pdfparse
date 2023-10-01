cmake_minimum_required(VERSION 3.20)
project(pdfengin LANGUAGES C)

add_subdirectory(read)
add_subdirectory(list)
add_subdirectory(common)
add_library(pdfengin ${SHARED} test.c)

include_directories(${HEADPATH})
link_directories(${LIBPATH})
target_link_libraries(pdfengin pdfreadengin)


