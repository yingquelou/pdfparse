cmake_minimum_required(VERSION ${CMV})
project(listUtil LANGUAGES C)

add_library(${PROJECT_NAME} ${SHARED} listd.c)

include_directories(${HEADPATH})

