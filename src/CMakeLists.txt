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
        qqmlsortfilterproxymodel.cpp

        desktop/menupopupwindow.cpp

        fishui.qrc

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
            platforms/linux/shadowhelper/windowshadow.cpp platforms/linux/shadowhelper/windowshadow.h
            )
    target_include_directories(${TARGET} PRIVATE platforms/linux)
endif ()
target_link_libraries(${TARGET}
        PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::DBus
        Qt6::Widgets
        PRIVATE
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::GuiPrivate
        )
generate_export_header(${TARGET} BASE_NAME ${TARGET})
install(TARGETS ${TARGET} EXPORT ${TARGET}Targets ${INSTALL_TARGETS_DEFAULT_ARGS})
install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# Install Controls
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/${TARGET})

# INSTALL STYLE
install(DIRECTORY Fish DESTINATION ${INSTALL_QMLDIR})
