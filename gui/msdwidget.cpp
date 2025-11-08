#include <fstream>
#include <sstream>
#include <string>

#include <QtWidgets/QFileDialog>
#include <QtWidgets/QMessageBox>
#include <QtCore/QStandardPaths>
#include <QtCore/QString>

#include "msdwidget.h"
#include "parse.h"
#include "Val.h"


MsdWidget::MsdWidget(QWidget *parent) : QWidget{parent} {
    /* -- Initialize instance variables -- */

    // Row 0
    file_btn = new QPushButton("Read from file");

    // Row 1
    expression_label = new QLabel("Expression:");
    expression_edit = new QTextEdit();
    expression_edit->setStyleSheet("QTextEdit { font-size: 16pt; }");


    // Row 2
    radio_group = new QGroupBox();
    interp_radio = new QRadioButton("Interp");
    pretty_print_radio = new QRadioButton("Pretty Print");

    // Row 3
    submit_btn = new QPushButton("Submit");

    // Row 4
    result_label = new QLabel("Result:");
    result_edit = new QTextEdit();
    result_edit->setStyleSheet("QTextEdit { font-size: 16pt; }");

    // Row 5
    reset_btn = new QPushButton("Reset");

    // Main
    main_grid = new QGridLayout();
    main_layout = new QVBoxLayout();

    /* -- Call methods -- */

    set_main_layout();

    setWindowTitle("MSDSCRIPT");

    // default w, h
    resize(700, 600);

    /* -- Slot functions -- */

    connect(file_btn, &QPushButton::clicked, this, &MsdWidget::open_file_dialog);

    connect(submit_btn, &QPushButton::clicked, this, &MsdWidget::fill_result);

    connect(reset_btn, &QPushButton::clicked, this, &MsdWidget::reset);
}

void MsdWidget::set_main_layout() {
    // Row 0
    main_grid->addWidget(file_btn, 0, 2);
    main_grid->addItem(new QSpacerItem(0, 40), 0, 0); // h space
    main_grid->addItem(new QSpacerItem(20, 10), 0, 1); // v space

    // Row 1    
    main_grid->addWidget(expression_label, 1, 0);
    main_grid->addWidget(expression_edit, 1, 2);
    main_grid->addItem(new QSpacerItem(0, 40), 1, 0); // h space

    // Row 2
    set_radio_group_layout();
    main_grid->addWidget(radio_group, 2, 2);
    main_grid->addItem(new QSpacerItem(0, 40), 2, 0); // h space

    // Row 3
    main_grid->addWidget(submit_btn, 3, 2);
    main_grid->addItem(new QSpacerItem(0, 40), 3, 0); // h space

    // Row 4    
    main_grid->addWidget(result_label, 4, 0);
    main_grid->addWidget(result_edit, 4, 2);
    main_grid->addItem(new QSpacerItem(0, 40), 5, 0); // h space

    // Row 5
    main_grid->addWidget(reset_btn, 5, 2);

    // Window-level
    main_layout->addItem(main_grid);

    setLayout(main_layout);
}

void MsdWidget::set_radio_group_layout() {
    QGridLayout *radio_grid_layout = new QGridLayout();

    radio_grid_layout->addWidget(interp_radio, 0, 0);
    radio_grid_layout->addWidget(pretty_print_radio, 1, 0);

    radio_group->setLayout(radio_grid_layout);
}

void MsdWidget::fill_result() {
    std::string expr_str, display_str;

    QString expr_q_str = expression_edit->toPlainText();
    expr_str = expr_q_str.toUtf8().constData();

    if (expr_str.empty()) {
        display_str = "Enter an expression";
    } else {

        if (interp_radio->isChecked()) {
            display_str = parse_expr(expr_str)->interp()->to_string();
        } else if (pretty_print_radio->isChecked()) {
            display_str = parse_expr(expr_str)->to_pretty_string();
        } else {
            display_str = "Select a run mode";
        }

    }

    result_edit->setText(QString::fromStdString(display_str));
}

void MsdWidget::open_file_dialog() {
    /* Get the Desktop location for the machine using Qt Library functions */
    QStringList desktop_paths = QStandardPaths::standardLocations(
            QStandardPaths::DesktopLocation);

    if (desktop_paths.isEmpty()) {
        show_error_dialog("Desktop path not found");
        return;
    }

    QString desktop_path = desktop_paths.first();

    /* Display dialog and assign user's eventual selection to file_path */
    QString file_path = QFileDialog::getOpenFileName(
            this, "MSD", desktop_path, tr("Image (*.txt)"));

    /* Get plaintext from file */
    QString file_data = read_from_file(file_path);

    /* Place the file contents in the TextEdit */
    expression_edit->setText(file_data);
}

QString MsdWidget::read_from_file(QString file_path) {
    std::ifstream f_stream(file_path.toStdString().c_str());

    if (!f_stream.good()) {
        show_error_dialog("Unable to open file " + file_path);
        return "";
    }

    std::stringstream s_stream("");
    std::string line;
    while (true) {
        getline(f_stream, line);
        s_stream << line;
        if (f_stream.eof()) { break; }
    }

    /* stream --> std::string --> QString */
    return QString::fromStdString(s_stream.str());
}

void MsdWidget::show_error_dialog(QString err_msg) {
    QMessageBox::critical(nullptr, "Error", err_msg, QMessageBox::Ok);
}

void MsdWidget::reset() {
    expression_edit->setText("");
    result_edit->setText("");

    interp_radio->setAutoExclusive(false);
    interp_radio->setChecked(false);
    interp_radio->setAutoExclusive(true);

    pretty_print_radio->setAutoExclusive(false);
    pretty_print_radio->setChecked(false);
    pretty_print_radio->setAutoExclusive(true);

    result_edit->setText("");
}
