/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefish <cutefishos@foxmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "thememanager.h"

#include <QIcon>
#include <QImage>

ThemeManager::ThemeManager(QObject *parent) 
    : QObject(parent)
    , m_accentColor(m_blueColor)
{
    connect(&m_appearance, &Appearance::darkModeChanged, this, &ThemeManager::darkModeChanged);
    connect(&m_appearance, &Appearance::blurEnabledChanged, this, &ThemeManager::blurEnabledChanged);
    connect(&m_appearance, &Appearance::fontPointSizeChanged, this, &ThemeManager::fontSizeChanged);
    connect(&m_appearance, &Appearance::fontFamilyChanged, this, &ThemeManager::fontFamilyChanged);
    connect(&m_appearance, &Appearance::accentColorIndexChanged, this, &ThemeManager::updateAccentColor);

    updateAccentColor();
}

void ThemeManager::updateAccentColor()
{
    switch (m_appearance.accentColorIndex()) {
    case ACCENTCOLOR_BLUE:
        m_accentColor = m_blueColor;
        break;
    case ACCENTCOLOR_RED:
        m_accentColor = m_redColor;
        break;
    case ACCENTCOLOR_GREEN:
        m_accentColor = m_greenColor;
        break;
    case ACCENTCOLOR_PURPLE:
        m_accentColor = m_purpleColor;
        break;
    case ACCENTCOLOR_PINK:
        m_accentColor = m_pinkColor;
        break;
    case ACCENTCOLOR_ORANGE:
        m_accentColor = m_orangeColor;
        break;
    case ACCENTCOLOR_GREY:
        m_accentColor = m_greyColor;
        break;
    default:
        m_accentColor = m_blueColor;
        break;
    }

    emit accentColorChanged();
}

// A single-colour glyph rasterises to one colour throughout: the icon themes
// that follow the colour scheme draw them from one `currentColor` fill. A full
// colour icon has several, and often covers its whole box, which is what turns
// into a solid rectangle when it is tinted.
bool ThemeManager::isMonochromeIcon(const QString &name)
{
    if (name.isEmpty())
        return false;

    const auto cached = m_monochromeIcons.constFind(name);
    if (cached != m_monochromeIcons.constEnd())
        return cached.value();

    static const int probeSize = 32;
    const QImage image = QIcon::fromTheme(name).pixmap(probeSize, probeSize).toImage()
                             .convertToFormat(QImage::Format_ARGB32);

    bool uniform = !image.isNull();
    bool seen = false;
    QRgb first = 0;

    for (int y = 0; y < image.height() && uniform; ++y) {
        for (int x = 0; x < image.width(); ++x) {
            const QRgb pixel = image.pixel(x, y);

            // The edges of a glyph are antialiased against nothing, so their
            // colour says nothing about the artwork.
            if (qAlpha(pixel) < 250)
                continue;

            const QRgb opaque = pixel | 0xff000000;
            if (!seen) {
                seen = true;
                first = opaque;
                continue;
            }

            if (opaque != first) {
                uniform = false;
                break;
            }
        }
    }

    // A glyph drawn in one strong colour of its own - a blue badge, say - is
    // not a colour scheme icon either, and painting it in the text colour
    // would throw its meaning away.
    const bool monochrome = uniform && seen && QColor(first).saturation() < 24;

    m_monochromeIcons.insert(name, monochrome);
    return monochrome;
}
