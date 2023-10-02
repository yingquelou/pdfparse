cmake_minimum_required(VERSION ${CMV})
project(pdfreader LANGUAGES C)

file(GLOB READSRC ./*.c)

add_library(${PROJECT_NAME} ${SHARED} ${READSRC})
target_link_libraries(${PROJECT_NAME} PUBLIC listUtil)
include_directories(${HEADPATH})
