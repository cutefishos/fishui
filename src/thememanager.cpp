#include "thememanager.h"

#include <QDBusConnection>
#include <QDBusServiceWatcher>
#include <QDBusInterface>
#include <QDebug>

static const QString Service = "org.cutefish.Settings";
static const QString ObjectPath = "/Theme";
static const QString Interface = "org.cutefish.Theme";

ThemeManager::ThemeManager(QObject *parent) 
    : QObject(parent)
    , m_darkMode(false)
    , m_accentColorID(-1)
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
    // Need to set m_accentColorID to -1 during initialization
    if (m_accentColorID == accentColorID)
        return;

    m_accentColorID = accentColorID;

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
