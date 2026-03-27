cmake_minimum_required(VERSION 3.22.1)

project(metronome)

add_library(
    metronome
    SHARED
    metronome.cpp
)

add_subdirectory(oboe)

target_link_libraries(
    metronome
    oboe
    log
)