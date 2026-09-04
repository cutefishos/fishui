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

#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <appearance.h>
#include <QHash>
#include <QFont>
#include <QColor>

#define ACCENTCOLOR_BLUE   0
#define ACCENTCOLOR_RED    1
#define ACCENTCOLOR_GREEN  2
#define ACCENTCOLOR_PURPLE 3
#define ACCENTCOLOR_PINK   4
#define ACCENTCOLOR_ORANGE 5
#define ACCENTCOLOR_GREY   6

class ThemeManager : public Appearance
{
    Q_OBJECT
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QColor blueColor READ blueColor CONSTANT)
    Q_PROPERTY(QColor redColor READ redColor CONSTANT)
    Q_PROPERTY(QColor greenColor READ greenColor CONSTANT)
    Q_PROPERTY(QColor purpleColor READ purpleColor CONSTANT)
    Q_PROPERTY(QColor pinkColor READ pinkColor CONSTANT)
    Q_PROPERTY(QColor orangeColor READ orangeColor CONSTANT)
    Q_PROPERTY(QColor greyColor READ greyColor CONSTANT)
    Q_PROPERTY(qreal fontSize READ fontSize NOTIFY fontSizeChanged)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    QColor accentColor() const { return m_accentColor; }
    qreal fontSize() const { return fontPointSize(); }

    QColor blueColor() const { return m_blueColor; }
    QColor redColor() const { return m_redColor; }
    QColor greenColor() const { return m_greenColor; }
    QColor purpleColor() const { return m_purpleColor; }
    QColor pinkColor() const { return m_pinkColor; }
    QColor orangeColor() const { return m_orangeColor; }
    QColor greyColor() const { return m_greyColor; }

    // Whether the icon theme draws @p name as a single-colour glyph, the kind
    // that is meant to be recoloured to match the text around it. Full colour
    // icons have to be left alone: tinting one paints it over as a solid
    // block of text colour.
    Q_INVOKABLE bool isMonochromeIcon(const QString &name);

signals:
    void accentColorChanged();
    void fontSizeChanged();

private slots:
    void updateAccentColor();

private:
    QColor m_blueColor   = QColor(51,  133, 255);   // #3385FF
    QColor m_redColor    = QColor(255, 92,  109);   // #FF5C6D
    QColor m_greenColor  = QColor(53,  191, 86);    // #35BF56
    QColor m_purpleColor = QColor(130, 102, 255);   // #8266FF
    QColor m_pinkColor   = QColor(202, 100, 172);   // #CA64AC
    QColor m_orangeColor = QColor(254, 160, 66);    // #FEA042
    QColor m_greyColor   = QColor(79, 89, 107);     // #4F596B

    QColor m_accentColor;

    // isMonochromeIcon() has to rasterise the icon to answer, so the verdict
    // is remembered per icon name.
    QHash<QString, bool> m_monochromeIcons;
};

#endif // THEMEMANAGER_H
