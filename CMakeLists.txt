cmake_minimum_required(VERSION 3.16)

set(FISHUI_VERSION 1.0)
project(fishui VERSION ${FISHUI_VERSION})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#DEFAULT COMPONENTS DEFINITIONS
option(COMPONENT_EDITOR "Build editor component" ON)
option(COMPONENT_FM "Build filemanager component" ON)
option(COMPONENT_ACCOUNTS "Build accounts component" ON)
option(COMPONENT_TERMINAL "Build terminal component" ON)
option(COMPONENT_STORE "Build store component" OFF)
option(COMPONENT_TAGGING "Build tagging component" ON)
option(COMPONENT_SYNCING "Build syncing component" ON)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

set(QT Core Gui Widgets Quick QuickControls2 DBus Qml)
find_package(Qt6 REQUIRED ${QT})
find_package(Qt6Gui CONFIG QUIET COMPONENTS Private)
if(NOT TARGET Qt6::GuiPrivate)
    find_package(Qt6 REQUIRED COMPONENTS GuiPrivate)
endif()
# KWindowShadow owns the Wayland shadow protocol and its native surface
# lifecycle.
find_package(KF6WindowSystem REQUIRED)
# org_kde_kwin_blur, for the region behind a translucent window.
find_package(KWayland REQUIRED)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../cutefish-framework/appearance
                 ${CMAKE_CURRENT_BINARY_DIR}/cutefish-framework-appearance-build)

include(GenerateExportHeader)
include(GNUInstallDirs)
include(ECMGenerateHeaders)

# Get the installation directory from Qt 6
find_program(QT_PATHS_EXECUTABLE NAMES qtpaths6 REQUIRED)

execute_process(COMMAND ${QT_PATHS_EXECUTABLE} -query QT_INSTALL_QML
        OUTPUT_VARIABLE INSTALL_QMLDIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
if (INSTALL_QMLDIR)
    message(STATUS "qml directory:" "${INSTALL_QMLDIR}")
else ()
    message(FATAL_ERROR "qml directory cannot be detected.")
endif ()

# Install

# Qt Widgets Style
#if (UNIX)
#    find_package(ECM REQUIRED NO_MODULE)
#    set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
#    include(ECMQueryQmake)
#    query_qmake(CMAKE_INSTALL_QTPLUGINDIR QT_INSTALL_PLUGINS)
#    add_subdirectory(qtwidgets-style)
#endif ()

add_subdirectory(src)


