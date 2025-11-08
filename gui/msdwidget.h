#pragma once

#pragma once

#include <QtWidgets/QWidget>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QLabel>
#include <QtWidgets/QTextEdit>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QRadioButton>

class MsdWidget : public QWidget {

Q_OBJECT

public:

    /* -- CTOR -- */

    explicit MsdWidget(QWidget *parent = nullptr);

private:

    /* -- Instance variables -- */

    QLabel *expression_label;
    QLabel *result_label;

    QTextEdit *expression_edit;
    QTextEdit *result_edit;

    QRadioButton *interp_radio;
    QRadioButton *pretty_print_radio;

    QPushButton *file_btn;
    QPushButton *submit_btn;
    QPushButton *reset_btn;

    QGroupBox *radio_group;

    QGridLayout *main_grid;

    QVBoxLayout *main_layout;

    /* -- Methods -- */

    void set_main_layout();

    void set_radio_group_layout();

    QString read_from_file(QString file_path);

    void show_error_dialog(QString err_msg);

private slots:

    /* -- Slot functions -- */

    void fill_result();

    void open_file_dialog();

    void reset();
};