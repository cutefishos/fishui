/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#ifndef MANAGEDTEXTURENODE_H
#define MANAGEDTEXTURENODE_H

#include <QSGSimpleTextureNode>
#include <QSGTexture>
#include <QSharedPointer>
#include <qglobal.h>

class ManagedTextureNode : public QSGSimpleTextureNode
{
    Q_DISABLE_COPY(ManagedTextureNode)

public:
    ManagedTextureNode();

    void setTexture(QSharedPointer<QSGTexture> texture);

private:
    QSharedPointer<QSGTexture> m_texture;
};

#endif
