cmake_path(GET CMAKE_CURRENT_LIST_DIR STEM PROJ)
include_directories(${HEADPATH})
add_library(${PROJ} ${SHARED} listd.c)

