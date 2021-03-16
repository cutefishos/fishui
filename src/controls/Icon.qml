/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Zsombor Egri <zsombor.egri@canonical.com>
 *          Loic Molinari <loic.molinari@canonical.com>
 */

import QtQuick 2.4

/*!
    \qmltype Icon
    \inqmlmodule Ubuntu.Components
    \inherits Item
    \ingroup ubuntu
    \brief The Icon component displays an icon from the icon theme.
    The icon theme contains a set of standard icons referred to by their name.
    Using icons whenever possible enhances consistency accross applications.
    Each icon has a name and can have different visual representations depending
    on the size requested.
    Icons can also be colorized. Setting the \l color property will make all pixels
    with the \l keyColor (by default #808080) colored.
    Example:
    \qml
    Icon {
        width: 64
        height: 64
        name: "search"
    }
    \endqml
    Example of colorization:
    \qml
    Icon {
        width: 64
        height: 64
        name: "search"
        color: UbuntuColors.warmGrey
    }
    \endqml
    Icon themes are created following the
    \l{http://standards.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html}{Freedesktop Icon Theme Specification}.
*/

Item {
    id: icon

    /*!
       The name of the icon to display.
       \qmlproperty string Icon::name
       If both name and source are set, name will be ignored.
       \note The complete list of icons available in Ubuntu is not published yet.
           For now please refer to the folders where the icon themes are installed:
           \list
             \li Ubuntu Touch: \l file:/usr/share/icons/suru
             \li Ubuntu Desktop: \l file:/usr/share/icons/ubuntu-mono-dark
           \endlist
           These 2 separate icon themes will be merged soon.
    */
    property string name

    /*!
       The color that all pixels that originally are of color \l keyColor should take.
       \qmlproperty color Icon::color
    */

    property alias color: colorizedImage.keyColorOut

    /*!
       The color of the pixels that should be colorized.
       By default it is set to #808080.
       \qmlproperty color Icon::keyColor
    */
    property alias keyColor: colorizedImage.keyColorIn

    /*!
       The source url of the icon to display. It has precedence over name.
       If both name and source are set, name will be ignored.
       \since Ubuntu.Components 1.1
       \qmlproperty url Icon::source
    */

    property alias source: image.source

    /*!
      \qmlproperty bool Icon::asynchronous
      The property drives the image loading of the icon. Defaults to false.
    */
    property alias asynchronous: image.asynchronous

    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight

    Component.onCompleted: image.completed = true

    Image {
        id: image
        objectName: "image"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit

        sourceSize {
            width: icon.width
            height: icon.height
        }

        property bool completed: false
        source: completed && icon.name ? "image://theme/%1".arg(icon.name) : ""

        cache: true
        visible: !colorizedImage.visible
        asynchronous: false
    }

    ShaderEffect {
        id: colorizedImage
        objectName: "shader"

        anchors.fill: parent

        // Whether or not a color has been set.
        visible: image.status == Image.Ready && keyColorOut != Qt.rgba(0.0, 0.0, 0.0, 0.0)

        property Image source: image
        property color keyColorOut: Qt.rgba(0.0, 0.0, 0.0, 0.0)
        property color keyColorIn: "#808080"
        property real threshold: 0.1

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform highp vec4 keyColorOut;
            uniform highp vec4 keyColorIn;
            uniform lowp float threshold;
            uniform lowp float qt_Opacity;
            void main() {
                lowp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                gl_FragColor = mix(keyColorOut * vec4(sourceColor.a), sourceColor, step(threshold, distance(sourceColor.rgb / sourceColor.a, keyColorIn.rgb))) * qt_Opacity;
            }"
    }
}