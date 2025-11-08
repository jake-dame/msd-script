#include <QtWidgets/QApplication>

#include "msdwidget.h"

int main(int argc, char **argv) {
    QApplication app(argc, argv);

    auto *main = new MsdWidget();

    main->show();

    return QApplication::exec();
}