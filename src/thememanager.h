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

#include <QObject>
#include <QFont>
#include <QColor>

#define ACCENTCOLOR_BLUE   0
#define ACCENTCOLOR_RED    1
#define ACCENTCOLOR_GREEN  2
#define ACCENTCOLOR_PURPLE 3
#define ACCENTCOLOR_PINK   4
#define ACCENTCOLOR_ORANGE 5
#define ACCENTCOLOR_GREY   6

class ThemeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool darkMode READ darkMode NOTIFY darkModeChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QColor blueColor READ blueColor CONSTANT)
    Q_PROPERTY(QColor redColor READ redColor CONSTANT)
    Q_PROPERTY(QColor greenColor READ greenColor CONSTANT)
    Q_PROPERTY(QColor purpleColor READ purpleColor CONSTANT)
    Q_PROPERTY(QColor pinkColor READ pinkColor CONSTANT)
    Q_PROPERTY(QColor orangeColor READ orangeColor CONSTANT)
    Q_PROPERTY(QColor greyColor READ greyColor CONSTANT)
    Q_PROPERTY(qreal devicePixelRatio READ devicePixelRatio CONSTANT)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    qreal devicePixelRatio() const;

    bool darkMode() { return m_darkMode; }
    QColor accentColor() { return m_accentColor; }

    QColor blueColor() { return m_blueColor; }
    QColor redColor() { return m_redColor; }
    QColor greenColor() { return m_greenColor; }
    QColor purpleColor() { return m_purpleColor; }
    QColor pinkColor() { return m_pinkColor; }
    QColor orangeColor() { return m_orangeColor; }
    QColor greyColor() { return m_greyColor; }

signals:
    void darkModeChanged();
    void accentColorChanged();

private slots:
    void initData();
    void initDBusSignals();
    void onDBusDarkModeChanged(bool darkMode);
    void onDBusAccentColorChanged(int accentColorID);

private:
    void setAccentColor(int accentColorID);

private:
    bool m_darkMode;
    int m_accentColorIndex;

    QColor m_blueColor   = QColor(51,  133, 255);   // #3385FF
    QColor m_redColor    = QColor(255, 92,  109);   // #FF5C6D
    QColor m_greenColor  = QColor(53,  191, 86);    // #35BF56
    QColor m_purpleColor = QColor(130, 102, 255);   // #8266FF
    QColor m_pinkColor   = QColor(202, 100, 172);   // #CA64AC
    QColor m_orangeColor = QColor(254, 160, 66);    // #FEA042
    QColor m_greyColor   = QColor(79, 89, 107);     // #4F596B

    QColor m_accentColor;
};

#endif // THEMEMANAGER_H
