set(TARGET MeuiKit)
set(MODULE_VERSION "1.0")

set(SOURCES
    meuikit.cpp
    iconthemeprovider.cpp
    thememanager.cpp
    shadowhelper/windowshadow.cpp
    shadowhelper/boxshadowrenderer.cpp
    shadowhelper/tileset.cpp
    blurhelper/windowblur.cpp
    blurhelper/windowblur.h
    windowhelper.cpp
    iconitem.cpp
    managedtexturenode.cpp

    desktop/menupopupwindow.cpp

    meuikit.qrc
    meui-style/style.qrc
)

add_library(${TARGET} SHARED ${SOURCES})

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
        Qt5::X11Extras
        KF5::WindowSystem
)

generate_export_header(${TARGET} BASE_NAME ${TARGET})
install(TARGETS ${TARGET} EXPORT ${TARGET}Targets ${INSTALL_TARGETS_DEFAULT_ARGS})

install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# Install Controls
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# INSTALL STYLE
install(DIRECTORY meui-style DESTINATION ${INSTALL_QMLDIR}/QtQuick/Controls.2)
