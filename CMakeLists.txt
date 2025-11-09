cmake_minimum_required(VERSION 3.27)
project(msd-script CXX)
set(CMAKE_CXX_STANDARD 11)

# Enable Qt meta-object compilation
set(CMAKE_AUTOMOC ON)

# Qt 6 Widgets
find_package(Qt6 COMPONENTS Widgets REQUIRED)

# CLI executable
add_executable(msd-script
    src/main.cpp
    src/cmdline.cpp
    src/cmdline.h
    src/Expr.cpp
    src/Expr.h
    src/parse.cpp
    src/parse.h
    src/Val.cpp
    src/Val.h
    src/Env.cpp
    src/Env.h
    src/pointers.h
    src/catch.h
    tests/unit/tests.cpp
    src/tests.cpp
)

# GUI executable
add_executable(msd-gui
    gui/main.cpp
    gui/msdwidget.cpp
    gui/msdwidget.h
    src/cmdline.cpp
    src/Expr.cpp
    src/Expr.h
    src/parse.cpp
    src/parse.h
    src/Val.cpp
    src/Val.h
    src/Env.cpp
    src/Env.h
    src/pointers.h
)

# Include backend headers for GUI
target_include_directories(msd-gui PRIVATE ${CMAKE_SOURCE_DIR}/src)

# Link GUI to Qt Widgets
target_link_libraries(msd-gui PRIVATE Qt6::Widgets)

# Fuzz Tester Executable
add_executable(test_msdscript
    tests/fuzz/drivers/harness.cpp
    tests/fuzz/drivers/exec.cpp
    tests/fuzz/drivers/exec.h
)
