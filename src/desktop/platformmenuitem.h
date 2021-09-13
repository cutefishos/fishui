#ifndef PLATFORMMENUITEM_H
#define PLATFORMMENUITEM_H

#include <QObject>

class PlatformMenuItem : public QObject
{
    Q_OBJECT
public:
    explicit PlatformMenuItem(QObject *parent = nullptr);

signals:

};

#endif // PLATFORMMENUITEM_H
