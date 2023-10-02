cmake_minimum_required(VERSION ${CMV})
project(pdfDestroy LANGUAGES C)

file(GLOB READSRC *.c)
add_library(${PROJECT_NAME} ${SHARED} ${READSRC})
target_link_libraries(${PROJECT_NAME} listUtil)
include_directories(${HEADPATH})