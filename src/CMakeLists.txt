set(TARGET FishUI)
set(MODULE_VERSION "1.0")

add_library(${TARGET} SHARED "")
target_sources(${TARGET} PRIVATE
        fishui.cpp
        iconthemeprovider.cpp
        thememanager.cpp
        shadowhelper/windowshadow.cpp
        shadowhelper/boxshadowrenderer.cpp
        shadowhelper/tileset.cpp

        iconitem.cpp
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
            )
    target_include_directories(${TARGET} PRIVATE platforms/windows)
else()
    target_sources(${TARGET} PRIVATE
            platforms/linux/windowhelper.cpp platforms/linux/windowhelper.h
            platforms/linux/blurhelper/windowblur.cpp platforms/linux/blurhelper/windowblur.h
            )
    target_include_directories(${TARGET} PRIVATE platforms/linux)
endif ()
target_link_libraries (${TARGET}
    PUBLIC
        Qt5::Core
        Qt5::Gui
        Qt5::DBus
    PRIVATE
        Qt5::Qml
        Qt5::Quick
        Qt5::QuickControls2
        Qt5::GuiPrivate
        KF5::WindowSystem
)
if (UNIX)
    target_link_libraries(${TARGET} PRIVATE Qt5::X11Extras)
endif ()

generate_export_header(${TARGET} BASE_NAME ${TARGET})
install(TARGETS ${TARGET} EXPORT ${TARGET}Targets ${INSTALL_TARGETS_DEFAULT_ARGS})
install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# Install Controls
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# INSTALL STYLE
install(DIRECTORY fish-style DESTINATION ${INSTALL_QMLDIR}/QtQuick/Controls.2)
