/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
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

#ifndef WINDOWSHADOW_H
#define WINDOWSHADOW_H

#include "tileset.h"


#include <QGuiApplication>
#include <QMap>
#include <QObject>
#include <QPainter>
#include <QPixmap>
#include <QQmlEngine>
#include <QQmlParserStatus>
#include <QRect>
#include <QWindow>
#include <QVector>

struct ShadowParams
{
    ShadowParams() = default;

    ShadowParams(const QPoint &offset, int radius, qreal opacity):
        offset(offset),
        radius(radius),
        opacity(opacity)
    {}

    QPoint offset;
    int radius = 0;
    qreal opacity = 0;
};

struct CompositeShadowParams
{
    CompositeShadowParams() = default;

    CompositeShadowParams(
            const QPoint &offset,
            const ShadowParams &shadow1,
            const ShadowParams &shadow2)
        : offset(offset)
        , shadow1(shadow1)
        , shadow2(shadow2) {}

    bool isNone() const
    { return qMax(shadow1.radius, shadow2.radius) == 0; }

    QPoint offset;
    ShadowParams shadow1;
    ShadowParams shadow2;
};

class WindowShadow : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QWindow *view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(qreal strength READ strength WRITE setStrength NOTIFY strengthChanged)

public:
    WindowShadow(QObject *parent = nullptr) noexcept;
    ~WindowShadow() override;

    static CompositeShadowParams lookupShadowParams(int shadowSizeEnum);

    void classBegin() override;
    void componentComplete() override;

    void setView(QWindow *view);
    QWindow *view() const;

    void setGeometry(const QRect &rect);
    QRect geometry() const;

    void setRadius(qreal value);
    qreal radius() { return m_radius; }

    qreal strength() const;
    void setStrength(qreal strength);

private slots:
    void onViewVisibleChanged(bool);

private:
    void configureTiles();
    TileSet shadowTiles();

    QMargins shadowMargins(TileSet) const;

signals:
    void geometryChanged();
    void enabledChanged();
    void viewChanged();
    void edgesChanged();
    void radiusChanged();
    void strengthChanged();

private:
    QWindow *m_view;
    QRect m_rect;
    TileSet m_shadowTiles;
    qreal m_radius = 10;
    qreal m_strength = 1.2;
};

#endif
