
// ****************************************************************************
// File: MainDialog.cpp
// Desc: Main Dialog
//
// ****************************************************************************
#include "stdafx.h"
#include "MainDialog.h"

#include <QtWidgets/QDialogButtonBox>


MainDialog::MainDialog(BOOL &optionPlaceStructs, BOOL &optionProcessStatic, BOOL &optionOverwriteComments, BOOL &optionAudioOnDone, BOOL &optionClean, BOOL &optionFullClear) : QDialog(QApplication::activeWindow(), 0)
{
    // Required for static library resources
    Q_INIT_RESOURCE(QtResource);

    setupUi(this);
    setWindowFlags(windowFlags() & ~Qt::WindowContextHelpButtonHint);
    buttonBox->addButton("CONTINUE", QDialogButtonBox::AcceptRole);
    buttonBox->addButton("CANCEL", QDialogButtonBox::RejectRole);

    #define INITSTATE(obj,state) obj->setCheckState((state == TRUE) ? Qt::Checked : Qt::Unchecked);
    INITSTATE(checkBox1, optionPlaceStructs);
    INITSTATE(checkBox2, optionProcessStatic);
    INITSTATE(checkBox3, optionOverwriteComments);
    INITSTATE(checkBox4, optionAudioOnDone);
    INITSTATE(checkBox5, optionClean);
    INITSTATE(checkBox6, optionFullClear);
    #undef INITSTATE

    // Apply style sheet
    QFile file(STYLE_PATH"style.qss");
    if (file.open(QFile::ReadOnly | QFile::Text))
        setStyleSheet(QTextStream(&file).readAll());
}

// Do main dialog, return TRUE if canceled
BOOL DoMainDialog(BOOL &optionPlaceStructs, BOOL &optionProcessStatic, BOOL &optionOverwriteComments, BOOL &optionAudioOnDone, BOOL &optionClean, BOOL &optionFullClear)
{
    MainDialog dlg = MainDialog(optionPlaceStructs, optionProcessStatic, optionOverwriteComments, optionAudioOnDone, optionClean, optionFullClear);
    if (dlg.exec())
    {
        #define CHECKSTATE(obj,var) var = dlg.obj->isChecked()
        CHECKSTATE(checkBox1, optionPlaceStructs);
        CHECKSTATE(checkBox2, optionProcessStatic);
        CHECKSTATE(checkBox3, optionOverwriteComments);
        CHECKSTATE(checkBox4, optionAudioOnDone);
        CHECKSTATE(checkBox5, optionClean);
        CHECKSTATE(checkBox6, optionFullClear);
        #undef CHECKSTATE

        return(FALSE);
    }
    return(TRUE);
}