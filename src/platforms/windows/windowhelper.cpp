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

#include "windowhelper.h"

#include <QGuiApplication>
#include <QCursor>
#include <QDebug>


WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
{
}

void WindowHelper::startSystemMove(QWindow *w)
{
    doStartSystemMoveResize(w, 16);
}

void WindowHelper::startSystemResize(QWindow *w, Qt::Edges edges)
{
    doStartSystemMoveResize(w, edges);
}

void WindowHelper::minimizeWindow(QWindow *w)
{
    qWarning() << "not implement";
}

void WindowHelper::doStartSystemMoveResize(QWindow *w, int edges)
{
    qWarning() << "not implement";
}
