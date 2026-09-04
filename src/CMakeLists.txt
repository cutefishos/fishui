set(TARGET FishUI)
set(MODULE_VERSION "1.0")

add_library(${TARGET} SHARED "")
target_sources(${TARGET} PRIVATE
        fishui.cpp
        iconthemeprovider.cpp
        thememanager.cpp

        iconitem.cpp
        managedtexturenode.cpp
        wheelhandler.cpp
        dpi.cpp
        qqmlsortfilterproxymodel.cpp

        desktop/menupopupwindow.cpp

        fishui.qrc

        )
target_sources(${TARGET} PRIVATE
        platforms/linux/windowhelper.cpp platforms/linux/windowhelper.h
        platforms/linux/blurhelper/windowblur.cpp platforms/linux/blurhelper/windowblur.h
        platforms/linux/blurhelper/waylandblurmanager.cpp platforms/linux/blurhelper/waylandblurmanager.h
        platforms/linux/shadowhelper/boxshadowrenderer.cpp platforms/linux/shadowhelper/boxshadowrenderer.h
        platforms/linux/shadowhelper/waylandshadowmanager.cpp platforms/linux/shadowhelper/waylandshadowmanager.h
        platforms/linux/shadowhelper/windowshadow.cpp platforms/linux/shadowhelper/windowshadow.h
        )
target_include_directories(${TARGET} PRIVATE platforms/linux)
target_link_libraries(${TARGET}
        PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::DBus
        Qt6::Widgets
        PRIVATE
        Cutefish::Appearance
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::GuiPrivate
        KF6::WindowSystem
        Plasma::KWaylandClient
        )
generate_export_header(${TARGET} BASE_NAME ${TARGET})
# The QML module directory is the only home: a second copy in the library
# directory would be loaded again alongside it, with its own type registrations.
install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# Install Controls
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# INSTALL STYLE
install(DIRECTORY Fish DESTINATION ${INSTALL_QMLDIR})
