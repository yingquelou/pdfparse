project(pdf LANGUAGES C CXX)

set(HEADPATH ${PROJECT_SOURCE_DIR}/include)
add_executable(${PROJECT_NAME} test.c)
add_subdirectory(src)
include_directories(./include)
target_link_libraries(${PROJECT_NAME} pdfengin pdfDestroy pdfwriter)

link_directories(lib)

