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

#include <QGuiApplication>

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusInterface>
#include <QDebug>

static const QString Service = "com.cutefish.Settings";
static const QString ObjectPath = "/Theme";
static const QString Interface = "com.cutefish.Theme";

ThemeManager::ThemeManager(QObject *parent) 
    : QObject(parent)
    , m_darkMode(false)
    , m_accentColorIndex(-1)
    , m_accentColor(m_blueColor) // The default is blue
{
    QDBusServiceWatcher *serviceWatcher = new QDBusServiceWatcher(Service, QDBusConnection::sessionBus(),
                                                                  QDBusServiceWatcher::WatchForRegistration);
    connect(serviceWatcher, &QDBusServiceWatcher::serviceRegistered, this, [=] {
        initData();
        initDBusSignals();
    });

    initDBusSignals();
    initData();
}

qreal ThemeManager::devicePixelRatio() const
{
    return qApp->devicePixelRatio();
}

void ThemeManager::initData()
{
    QDBusInterface iface(Service, ObjectPath, Interface, QDBusConnection::sessionBus(), this);

    if (iface.isValid()) {
        m_darkMode = iface.property("isDarkMode").toBool();
        int accentColorID = iface.property("accentColor").toInt();
        setAccentColor(accentColorID);

        emit darkModeChanged();
    }
}

void ThemeManager::initDBusSignals()
{
    QDBusInterface iface(Service, ObjectPath, Interface, QDBusConnection::sessionBus(), this);

    if (iface.isValid()) {
        QDBusConnection::sessionBus().connect(Service, ObjectPath, Interface, "darkModeChanged",
                                              this, SLOT(onDBusDarkModeChanged(bool)));
        QDBusConnection::sessionBus().connect(Service, ObjectPath, Interface, "accentColorChanged",
                                              this, SLOT(onDBusAccentColorChanged(int)));
    }
}

void ThemeManager::onDBusDarkModeChanged(bool darkMode)
{
    if (m_darkMode != darkMode) {
        m_darkMode = darkMode;
        emit darkModeChanged();
    }
}

void ThemeManager::onDBusAccentColorChanged(int accentColorID)
{
    setAccentColor(accentColorID);
}

void ThemeManager::setAccentColor(int accentColorID)
{
    if (m_accentColorIndex == accentColorID)
        return;

    m_accentColorIndex = accentColorID;

    switch (accentColorID) {
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
    default:
        m_accentColor = m_blueColor;
        break;
    }

    emit accentColorChanged();
}
