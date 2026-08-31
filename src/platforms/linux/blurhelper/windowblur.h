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

#ifndef WINDOWBLUR_H
#define WINDOWBLUR_H

#include <QObject>
#include <QPointer>
#include <QQmlParserStatus>
#include <QRegion>

class QWindow;

namespace KWayland
{
namespace Client
{
class Blur;
class Surface;
}
}

/**
 * Blur behind a translucent window.
 *
 * The blurred region is the window itself, rounded off by windowRadius; there
 * is nothing for a caller to place, which is why there is no geometry property.
 * The one that used to be here was bound to the window's own x, y, width and
 * height in every single user, and that is a binding loop as soon as one of
 * them depends on the content's implicit size.
 */
class WindowBlur : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QWindow *view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(qreal windowRadius READ windowRadius WRITE setWindowRadius NOTIFY windowRadiusChanged)
    Q_INTERFACES(QQmlParserStatus)

public:
    WindowBlur(QObject *parent = nullptr) noexcept;
    ~WindowBlur() override;

    void classBegin() override;
    void componentComplete() override;

    void setView(QWindow *view);
    QWindow *view() const;

    void setEnabled(bool enabled);
    bool enabled() const;

    void setWindowRadius(qreal radius);
    qreal windowRadius() const;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void viewChanged();
    void enabledChanged();
    void windowRadiusChanged();

private:
    void scheduleUpdate();
    void updateBlur();
    void forget();
    QRegion blurRegion() const;

    QPointer<QWindow> m_view;
    QPointer<KWayland::Client::Blur> m_blur;
    KWayland::Client::Surface *m_surface = nullptr;
    QRegion m_region;
    bool m_enabled = false;
    bool m_complete = false;
    qreal m_windowRadius = 0.0;
};

#endif
