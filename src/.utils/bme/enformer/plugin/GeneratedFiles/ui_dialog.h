/********************************************************************************
** Form generated from reading UI file 'dialog.ui'
**
** Created by: Qt User Interface Compiler version 5.5.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_DIALOG_H
#define UI_DIALOG_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QDialog>
#include <QtWidgets/QDialogButtonBox>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>

QT_BEGIN_NAMESPACE

class Ui_Dialog
{
public:
    QDialogButtonBox *buttonBox;
    QCheckBox *checkBox1;
    QCheckBox *checkBox2;
    QCheckBox *checkBox3;
    QCheckBox *checkBox4;
    QCheckBox *checkBox5;
    QCheckBox *checkBox6;
    QLabel *linkLabel;
    QLabel *image;
    QLabel *versionLabel;

    void setupUi(QDialog *Dialog)
    {
        if (Dialog->objectName().isEmpty())
            Dialog->setObjectName(QStringLiteral("Dialog"));
        Dialog->resize(292, 308);
        QSizePolicy sizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(Dialog->sizePolicy().hasHeightForWidth());
        Dialog->setSizePolicy(sizePolicy);
        Dialog->setWindowTitle(QStringLiteral("Class Informer"));
        QIcon icon;
        icon.addFile(QStringLiteral(":/classinf/icon.png"), QSize(), QIcon::Normal, QIcon::Off);
        Dialog->setWindowIcon(icon);
#ifndef QT_NO_TOOLTIP
        Dialog->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        Dialog->setModal(true);
        buttonBox = new QDialogButtonBox(Dialog);
        buttonBox->setObjectName(QStringLiteral("buttonBox"));
        buttonBox->setGeometry(QRect(120, 275, 156, 23));
        buttonBox->setOrientation(Qt::Horizontal);
        buttonBox->setStandardButtons(QDialogButtonBox::NoButton);
        buttonBox->setCenterButtons(false);
        checkBox1 = new QCheckBox(Dialog);
        checkBox1->setObjectName(QStringLiteral("checkBox1"));
        checkBox1->setGeometry(QRect(15, 95, 121, 17));
        QFont font;
        font.setFamily(QStringLiteral("Noto Sans"));
        font.setPointSize(10);
        checkBox1->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox1->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        checkBox2 = new QCheckBox(Dialog);
        checkBox2->setObjectName(QStringLiteral("checkBox2"));
        checkBox2->setGeometry(QRect(15, 125, 256, 17));
        checkBox2->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox2->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        checkBox3 = new QCheckBox(Dialog);
        checkBox3->setObjectName(QStringLiteral("checkBox3"));
        checkBox3->setGeometry(QRect(15, 155, 201, 17));
        checkBox3->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox3->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        checkBox4 = new QCheckBox(Dialog);
        checkBox4->setObjectName(QStringLiteral("checkBox4"));
        checkBox4->setGeometry(QRect(15, 185, 151, 17));
        checkBox4->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox4->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        checkBox5 = new QCheckBox(Dialog);
        checkBox5->setObjectName(QStringLiteral("checkBox5"));
        checkBox5->setGeometry(QRect(15, 215, 151, 17));
        checkBox5->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox5->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        checkBox6 = new QCheckBox(Dialog);
        checkBox6->setObjectName(QStringLiteral("checkBox6"));
        checkBox6->setGeometry(QRect(15, 245, 151, 17));
        checkBox6->setFont(font);
#ifndef QT_NO_TOOLTIP
        checkBox6->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        linkLabel = new QLabel(Dialog);
        linkLabel->setObjectName(QStringLiteral("linkLabel"));
        linkLabel->setGeometry(QRect(15, 280, 136, 16));
        linkLabel->setFont(font);
        linkLabel->setFrameShadow(QFrame::Sunken);
        linkLabel->setTextFormat(Qt::AutoText);
        linkLabel->setOpenExternalLinks(true);
        image = new QLabel(Dialog);
        image->setObjectName(QStringLiteral("image"));
        image->setGeometry(QRect(0, 0, 292, 74));
#ifndef QT_NO_TOOLTIP
        image->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        image->setTextFormat(Qt::PlainText);
        image->setPixmap(QPixmap(QString::fromUtf8(":/classinf/banner.png")));
        image->setTextInteractionFlags(Qt::NoTextInteraction);
        versionLabel = new QLabel(Dialog);
        versionLabel->setObjectName(QStringLiteral("versionLabel"));
        versionLabel->setGeometry(QRect(225, 45, 61, 21));
        QFont font1;
        font1.setFamily(QStringLiteral("Noto Sans"));
        font1.setPointSize(9);
        versionLabel->setFont(font1);
#ifndef QT_NO_TOOLTIP
        versionLabel->setToolTip(QStringLiteral(""));
#endif // QT_NO_TOOLTIP
        versionLabel->setTextFormat(Qt::PlainText);
        versionLabel->setTextInteractionFlags(Qt::NoTextInteraction);

        retranslateUi(Dialog);
        QObject::connect(buttonBox, SIGNAL(accepted()), Dialog, SLOT(accept()));
        QObject::connect(buttonBox, SIGNAL(rejected()), Dialog, SLOT(reject()));

        QMetaObject::connectSlotsByName(Dialog);
    } // setupUi

    void retranslateUi(QDialog *Dialog)
    {
        checkBox1->setText(QApplication::translate("Dialog", "Place structures", 0));
        checkBox2->setText(QApplication::translate("Dialog", "Process static initializers && terminators", 0));
        checkBox3->setText(QApplication::translate("Dialog", "Overwrite anterior comments", 0));
        checkBox4->setText(QApplication::translate("Dialog", "Audio on completion", 0));
        checkBox5->setText(QApplication::translate("Dialog", "Clean", 0));
        checkBox6->setText(QApplication::translate("Dialog", "Full Clear", 0));
        linkLabel->setText(QApplication::translate("Dialog", "<a href=\"http://www.macromonkey.com/bb/index.php/topic,13.0.html\" style=\"color:#AA00FF;\">Class Informer Fourm</a>", 0));
        image->setText(QString());
        versionLabel->setText(QApplication::translate("Dialog", "Version: 2.0\n"
"By Sirmabus", 0));
        Q_UNUSED(Dialog);
    } // retranslateUi

};

namespace Ui {
    class Dialog: public Ui_Dialog {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_DIALOG_H
