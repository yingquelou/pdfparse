cmake_minimum_required(VERSION 3.20)
project(pdf LANGUAGES C)

set(HEADPATH ${PROJECT_SOURCE_DIR}/include)
add_executable(${PROJECT_NAME} test.c)
add_subdirectory(src)
include_directories(./include)
target_link_libraries(${PROJECT_NAME} pdfengin pdfDestroy)

link_directories(lib)

