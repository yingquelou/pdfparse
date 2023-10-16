cmake_minimum_required(VERSION 3.8)
project(path LANGUAGES CXX)

file(GLOB SRCFILES *.cpp)

add_library(${PROJECT_NAME} ${ISSHARED} ${SRCFILES})