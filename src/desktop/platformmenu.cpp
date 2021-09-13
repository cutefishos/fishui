#include "platformmenu.h"

PlatformMenu::PlatformMenu(QObject *parent)
    : QObject(parent)
    , m_complete(false)
{

}

QQmlListProperty<QObject> PlatformMenu::data()
{
    return QQmlListProperty<QObject>(this, nullptr, data_append, data_count, data_at, data_clear);
}

QQmlListProperty<PlatformMenuItem> PlatformMenu::items()
{
    return QQmlListProperty<PlatformMenuItem>(this, nullptr, items_append, items_count, items_at, items_clear);
}

PlatformMenu *PlatformMenu::parentMenu() const
{

}

void PlatformMenu::setParentMenu(PlatformMenu *menu)
{

}

void PlatformMenu::addItem(PlatformMenuItem *item)
{
    insertItem(m_items.count(), item);
}

void PlatformMenu::insertItem(int index, PlatformMenuItem *item)
{
    if (!item || m_items.contains(item))
        return;

    m_items.insert(index, item);
    m_data.append(item);
//    item->setMenu(this);
//    if (m_handle && item->create()) {
//        QQuickPlatformMenuItem *before = m_items.value(index + 1);
//        m_handle->insertMenuItem(item->handle(), before ? before->create() : nullptr);
//    }
//    sync();
    emit itemsChanged();
}

void PlatformMenu::removeItem(PlatformMenuItem *item)
{
    if (!item || !m_items.removeOne(item))
        return;

    m_data.removeOne(item);
//    if (m_handle)
//        m_handle->removeMenuItem(item->handle());
//    item->setMenu(nullptr);
//    sync();
    emit itemsChanged();
}

void PlatformMenu::addMenu(PlatformMenu *menu)
{
    insertMenu(m_items.count(), menu);
}

void PlatformMenu::insertMenu(int index, PlatformMenu *menu)
{
    if (!menu)
        return;

    menu->setParentMenu(this);
    insertItem(index, menu->menuItem());
}

void PlatformMenu::removeMenu(PlatformMenu *menu)
{
    if (!menu)
        return;

    menu->setParentMenu(nullptr);
    removeItem(menu->menuItem());
}

void PlatformMenu::clear()
{
    if (m_items.isEmpty())
        return;

//    for (QQuickPlatformMenuItem *item : qAsConst(m_items)) {
//        m_data.removeOne(item);
//        if (m_handle)
//            m_handle->removeMenuItem(item->handle());
//        item->setMenu(nullptr);
//        delete item;
//    }

    m_items.clear();
//    sync();
    emit itemsChanged();
}

void PlatformMenu::classBegin()
{

}

void PlatformMenu::componentComplete()
{
    m_complete = true;
}

void PlatformMenu::data_append(QQmlListProperty<QObject> *property, QObject *object)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);

    if (PlatformMenuItem *item = qobject_cast<PlatformMenuItem *>(object))
        menu->addItem(item);
    else if (PlatformMenu *subMenu = qobject_cast<PlatformMenu *>(object))
        menu->addMenu(subMenu);
    else
        menu->m_data.append(object);
}

qsizetype PlatformMenu::data_count(QQmlListProperty<QObject> *property)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    return menu->m_data.count();
}

QObject *PlatformMenu::data_at(QQmlListProperty<QObject> *property, qsizetype index)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    return menu->m_data.value(index);
}

void PlatformMenu::data_clear(QQmlListProperty<QObject> *property)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    menu->m_data.clear();
}

void PlatformMenu::items_append(QQmlListProperty<PlatformMenu> *property, PlatformMenuItem *item)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    menu->addItem(item);
}

qsizetype PlatformMenu::items_count(QQmlListProperty<PlatformMenu> *property)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    return menu->m_items.count();
}

PlatformMenuItem *PlatformMenu::items_at(QQmlListProperty<PlatformMenuItem> *property, qsizetype index)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    return menu->m_items.value(index);
}

void PlatformMenu::items_clear(QQmlListProperty<PlatformMenuItem> *property)
{
    PlatformMenu *menu = static_cast<PlatformMenu *>(property->object);
    menu->clear();
}
