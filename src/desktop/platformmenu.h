#ifndef PLATFORMMENU_H
#define PLATFORMMENU_H

#include <QObject>
#include <QQmlParserStatus>
#include <qqmllist.h>
#include <qqml.h>

#include "platformmenuitem.h"

class PlatformMenu : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QQmlListProperty<QObject> data READ data FINAL)
    Q_PROPERTY(QQmlListProperty<PlatformMenuItem> items READ items NOTIFY itemsChanged FINAL)

    Q_CLASSINFO("DefaultProperty", "data")

public:
    explicit PlatformMenu(QObject *parent = nullptr);

    QQmlListProperty<QObject> data();
    QQmlListProperty<PlatformMenuItem> items();

    PlatformMenu *parentMenu() const;
    void setParentMenu(PlatformMenu *menu);

    Q_INVOKABLE void addItem(PlatformMenuItem *item);
    Q_INVOKABLE void insertItem(int index, PlatformMenuItem *item);
    Q_INVOKABLE void removeItem(PlatformMenuItem *item);

    Q_INVOKABLE void addMenu(PlatformMenu *menu);
    Q_INVOKABLE void insertMenu(int index, PlatformMenu *menu);
    Q_INVOKABLE void removeMenu(PlatformMenu *menu);

    Q_INVOKABLE void clear();

signals:
    void itemsChanged();

protected:
    void classBegin() override;
    void componentComplete() override;

    static void data_append(QQmlListProperty<QObject> *property, QObject *object);
    static qsizetype data_count(QQmlListProperty<QObject> *property);
    static QObject *data_at(QQmlListProperty<QObject> *property, qsizetype index);
    static void data_clear(QQmlListProperty<QObject> *property);

    static void items_append(QQmlListProperty<PlatformMenu> *property, PlatformMenuItem *item);
    static qsizetype items_count(QQmlListProperty<PlatformMenu> *property);
    static PlatformMenuItem *items_at(QQmlListProperty<PlatformMenuItem> *property, qsizetype index);
    static void items_clear(QQmlListProperty<PlatformMenuItem> *property);

private:
    bool m_complete;
    QList<QObject *> m_data;
    QList<PlatformMenuItem *> m_items;
};

#endif // PLATFORMMENU_H
