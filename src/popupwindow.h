#ifndef TOPLEVELMENU_H
#define TOPLEVELMENU_H

#include <QQuickWindow>
#include <QQuickItem>

class PopupWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *popupContentItem READ popupContentItem WRITE setPopupContentItem)
    Q_CLASSINFO("DefaultProperty", "popupContentItem")
    Q_PROPERTY(QQuickItem *parentItem READ parentItem WRITE setParentItem)

public:
    PopupWindow(QQuickWindow *parent = nullptr);

    QQuickItem *popupContentItem() const { return m_contentItem; }
    void setPopupContentItem(QQuickItem *popupContentItem);

    QQuickItem *parentItem() const { return m_parentItem; }
    virtual void setParentItem(QQuickItem *);

public slots:
    void show();
    void dismissPopup();

signals:
    void popupDismissed();
    void geometryChanged();

protected:
    void mousePressEvent(QMouseEvent *) override;
    void mouseReleaseEvent(QMouseEvent *) override;
    void mouseMoveEvent(QMouseEvent *) override;
    bool event(QEvent *) override;

protected slots:
    void applicationStateChanged(Qt::ApplicationState state);

private:
    QQuickItem *m_parentItem;
    QPointer<QQuickItem> m_contentItem;
    bool m_mouseMoved;
    bool m_dismissed;
};

#endif // POPUPWINDOW_H
