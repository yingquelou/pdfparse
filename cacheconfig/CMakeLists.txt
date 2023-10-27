cmake_minimum_required(VERSION 3.20)
cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME fileName)
project(${fileName} LANGUAGES CXX)
file(GLOB CSRCLIST *.cpp)
add_library(${PROJECT_NAME} ${SHAREDOK} ${CSRCLIST})
target_link_libraries(${PROJECT_NAME} PRIVATE cjson stdc++)

