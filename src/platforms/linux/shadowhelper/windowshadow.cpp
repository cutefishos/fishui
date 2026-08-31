#include "windowshadow.h"

WindowShadow::WindowShadow(QObject *parent) noexcept
    : QObject(parent)
{
}

void WindowShadow::setView(QWindow *view)
{
    if (m_view == view)
        return;
    m_view = view;
    emit viewChanged();
}

QWindow *WindowShadow::view() const
{
    return m_view;
}

void WindowShadow::setGeometry(const QRect &rect)
{
    if (m_rect == rect)
        return;
    m_rect = rect;
    emit geometryChanged();
}

QRect WindowShadow::geometry() const
{
    return m_rect;
}

void WindowShadow::setRadius(qreal value)
{
    if (m_radius == value)
        return;
    m_radius = value;
    emit radiusChanged();
}

void WindowShadow::setStrength(qreal strength)
{
    if (m_strength == strength)
        return;
    m_strength = strength;
    emit strengthChanged();
}
