cmake_minimum_required(VERSION 3.20)
project(listUtil LANGUAGES C)

add_library(listUtil ${SHARED} listd.c)

include_directories(${HEADPATH})

