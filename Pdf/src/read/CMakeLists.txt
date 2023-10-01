cmake_minimum_required(VERSION 3.20)
project(pdfreadengin LANGUAGES C)

file(GLOB READSRC ./*.c)

add_library(pdfreadengin ${SHARED} ${READSRC})
target_link_libraries(pdfreadengin PUBLIC listUtil)
include_directories(${HEADPATH})
