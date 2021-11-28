set(TARGET FishUI)
set(MODULE_VERSION "1.0")

add_library(${TARGET} SHARED "")
target_sources(${TARGET} PRIVATE
        fishui.cpp
        iconthemeprovider.cpp
        thememanager.cpp

        newiconitem.cpp
        managedtexturenode.cpp
        wheelhandler.cpp

        desktop/menupopupwindow.cpp

        fishui.qrc
        fish-style/style.qrc
        )
if (MSVC)
    target_sources(${TARGET} PRIVATE
            platforms/windows/windowhelper.cpp platforms/windows/windowhelper.h
            platforms/windows/blurhelper/windowblur.cpp platforms/windows/blurhelper/windowblur.h
            platforms/windows/shadowhelper/boxshadowrenderer.cpp platforms/windows/shadowhelper/boxshadowrenderer.h
            platforms/windows/shadowhelper/tileset.cpp platforms/windows/shadowhelper/tileset.h
            platforms/windows/shadowhelper/windowshadow.cpp platforms/windows/shadowhelper/windowshadow.h
            )
    target_include_directories(${TARGET} PRIVATE platforms/windows)
elseif (APPLE)
    target_sources(${TARGET} PRIVATE
            platforms/mac/windowhelper.cpp platforms/mac/windowhelper.h
            platforms/mac/blurhelper/windowblur.cpp platforms/mac/blurhelper/windowblur.h
            platforms/mac/shadowhelper/boxshadowrenderer.cpp platforms/mac/shadowhelper/boxshadowrenderer.h
            platforms/mac/shadowhelper/tileset.cpp platforms/mac/shadowhelper/tileset.h
            platforms/mac/shadowhelper/windowshadow.cpp platforms/mac/shadowhelper/windowshadow.h
            )
    target_include_directories(${TARGET} PRIVATE platforms/mac)
else ()
    target_sources(${TARGET} PRIVATE
            platforms/linux/windowhelper.cpp platforms/linux/windowhelper.h
            platforms/linux/blurhelper/windowblur.cpp platforms/linux/blurhelper/windowblur.h
            platforms/linux/shadowhelper/boxshadowrenderer.cpp platforms/linux/shadowhelper/boxshadowrenderer.h
            platforms/linux/shadowhelper/tileset.cpp platforms/linux/shadowhelper/tileset.h
            platforms/linux/shadowhelper/windowshadow.cpp platforms/linux/shadowhelper/windowshadow.h
            )
    target_include_directories(${TARGET} PRIVATE platforms/linux)
endif ()
target_link_libraries(${TARGET}
        PUBLIC
        Qt5::Core
        Qt5::Gui
        Qt5::DBus
        Qt5::Widgets
        PRIVATE
        Qt5::Qml
        Qt5::Quick
        Qt5::QuickControls2
        Qt5::GuiPrivate
        )
if (UNIX)
    if (NOT APPLE)
        target_link_libraries(${TARGET} PRIVATE Qt5::X11Extras KF5::WindowSystem)
    endif ()
endif ()

generate_export_header(${TARGET} BASE_NAME ${TARGET})
install(TARGETS ${TARGET} EXPORT ${TARGET}Targets ${INSTALL_TARGETS_DEFAULT_ARGS})
install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# Install Controls
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# INSTALL STYLE
install(DIRECTORY fish-style DESTINATION ${INSTALL_QMLDIR}/QtQuick/Controls.2)
