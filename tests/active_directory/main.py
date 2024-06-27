import sys
from PyQt5.QtWidgets import (
    QApplication
)
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import  QFont, QColor, QPalette,QIcon
from PyQt5.QtWidgets import QApplication, QStyleFactory
from ADSuite import ADSuite


QApplication.setFont(QFont('Arial', 10))
palette = QPalette()
palette.setColor(QPalette.Window, QColor(53, 53, 53))
palette.setColor(QPalette.WindowText, Qt.white)
palette.setColor(QPalette.Base, QColor(25, 25, 25))
palette.setColor(QPalette.AlternateBase, QColor(53, 53, 53))
palette.setColor(QPalette.ToolTipBase, Qt.white)
palette.setColor(QPalette.ToolTipText, Qt.white)
palette.setColor(QPalette.Text, Qt.white)
palette.setColor(QPalette.Button, QColor(Qt.red, Qt.green, Qt.blue)) 
palette.setColor(QPalette.ButtonText, Qt.black)
palette.setColor(QPalette.BrightText, Qt.red)
palette.setColor(QPalette.Highlight, QColor(142, 45, 197).lighter())
palette.setColor(QPalette.HighlightedText, Qt.black)

def main():
    app = QApplication(sys.argv) 
    app.setApplicationName('AD Suite')
    app.setWindowIcon(QIcon('/usr/share/adsuit/icon.jpg'))
    palette = QPalette()
    palette.setColor(QPalette.Window, QColor(53, 53, 53))
    palette.setColor(QPalette.WindowText, Qt.white)

    app.setPalette(palette)  

    app.setStyle(QStyleFactory.create("Fusion"))  

    ex = ADSuite()
    ex.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()