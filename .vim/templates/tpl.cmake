cmake_minimum_required (VERSION 3.4.3)

# projectname is the same as the main-executable
project(%HERE%%FDIR%
    VERSION 1.0.0
    LANGUAGES CXX
)

# Use plain -std=c++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(${PROJECT_NAME} ${PROJECT_NAME}.cpp)
# add_library(${PROJECT_NAME} SHARED ${PROJECT_NAME}.cpp)
target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/inc
)
target_link_libraries(${PROJECT_NAME}
    PRIVATE
)
install(${PROJECT_NAME})

