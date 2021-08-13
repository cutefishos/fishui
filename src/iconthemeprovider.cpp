#include "iconthemeprovider.h"
#include <QFile>
#include <QIcon>

IconThemeProvider::IconThemeProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap IconThemeProvider::requestPixmap(const QString &id, QSize *realSize,
                                         const QSize &requestedSize)
{
    // Sanitize requested size
    QSize size(requestedSize);
    if (size.width() < 1)
        size.setWidth(1);
    if (size.height() < 1)
        size.setHeight(1);

    // Return real size
    if (realSize)
        *realSize = size;

    if (QFile::exists(id)) {
        return QPixmap(id).scaled(size);
    }

    // Is it a path?
    if (id.startsWith(QLatin1Char('/')))
        return QPixmap(id).scaled(size);

    // Return icon from theme or fallback to a generic icon
    QIcon icon = QIcon::fromTheme(id);
    if (icon.isNull())
        icon = QIcon::fromTheme(QLatin1String("application-x-desktop"));

    return icon.pixmap(size);
}
