cmake_minimum_required(VERSION 3.25)
project(PackageTest CXX)

find_package(my_lib CONFIG REQUIRED)



add_executable(test_package test_package.cpp)
target_link_libraries(test_package my_lib::my_lib)
