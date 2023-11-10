import sys
import time
import os
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QToolTip
from PyQt5.QtGui import QIcon, QPixmap, QFont, QMovie
from PyQt5.QtCore import QCoreApplication, QTimer, QSize, QByteArray
from time import sleep
import threading

# In_UART_Line =  ['S','S','S','S','S','S','S','L','L','L','L','L','L','L','L','L',
#              'S','S','S','S','S','S','S','S','S','R','R','R','R','R','R','R',
#              'L','L','L','L','L','L','L','L','L','S','S','S','S','S','S','S',
#              'R','R','R','R','R','R','R','S','S','S','S','S','S','S','S','S',
#              'L','L','L','L','L','L','L','L','L','S','S','S','S','S','S','S']

In_UART_Line = ['S', 'L', 'S', 'L', 'S', 'S', 'S', 'R', 'R', 'R', 'R', 'S', 'S', 'R', 'S', 'S',
                'S', 'S', 'R', 'R', 'R', 'S', 'S', 'R', 'R', 'R', 'R', 'L', 'S', 'R', 'S', 'S',
                'S', 'S', 'R', 'R', 'R', 'R', 'S', 'S', 'R', 'S', 'S', 'S', 'S', 'R', 'R', 'R',
                'R', 'S', 'S', 'R', 'S', 'S', 'S', 'S', 'R', 'R', 'R', 'R', 'S', 'S', 'L', 'S']


file_dir = "/pyqt"
img_dir = file_dir + "/Qt_img/"


# def resource_path(relative_path):
#     try:
#         base_path = sys._MEIPASS
#     except Exception:
#         base_path = os.path.abspath(".")
#     return os.path.join(base_path, relative_path)


class V2X_Driving_Mode(QWidget):
    def __init__(self):
        super().__init__()

        self.Curve_GIF = QLabel(self)
        self.Line_Img = QLabel(self)
        self.BackSide_Img = QLabel(self)

        self.gif_timer = QTimer(self)

        self.prev = None
        self.curr = None

        self.Uart_Line = ['S', 'S']

        self.Straight_Line()

        # self.Line_Img.clear()
        self.Right_Gif()  # 처음에 gif 한번은 실행해줘야 됨

        self.UIinit()

    def UIinit(self):
        self.setWindowTitle('V2X driving mode')
        self.setGeometry(0, 300, 1920, 515)

        self.RunTread()

        self.BackSide()

        # self.Right_Gif()

        self.update_Line()

        # self.Detect_Line()

        self.btn_exit()
        self.show()
        # self.showFullScreen()

    def BackSide(self):
        pixmap = QPixmap(img_dir + 'BackSide.png').scaled(1920, 515)
        self.BackSide_Img.setPixmap(pixmap)
        self.BackSide_Img.setGeometry(0, 0, 1920, 515)

    def Right_Gif(self):
        self.RightCurve = QMovie(img_dir+"V2X_RightCurve.gif", QByteArray(), self)
        self.RightCurve.setCacheMode(QMovie.CacheAll)
        self.Curve_GIF.setMovie(self.RightCurve)
        self.RightCurve.start()

    def Reverse_Right_Gif(self):
        self.ReverseRightCurve = QMovie(img_dir+"V2X_ReverseRightCurve.gif", QByteArray(), self)
        self.ReverseRightCurve.setCacheMode(QMovie.CacheAll)
        self.Curve_GIF.setMovie(self.ReverseRightCurve)
        self.ReverseRightCurve.start()

    def Left_Gif(self):
        self.LeftCurve = QMovie(img_dir+"V2X_LeftCurve.gif", QByteArray(), self)
        self.LeftCurve.setCacheMode(QMovie.CacheAll)
        self.Curve_GIF.setMovie(self.LeftCurve)
        self.LeftCurve.start()

    def Reverse_Left_Gif(self):
        self.ReverseLeftCurve = QMovie(img_dir+"V2X_ReverseLeftCurve.gif", QByteArray(), self)
        self.ReverseLeftCurve.setCacheMode(QMovie.CacheAll)
        self.Curve_GIF.setMovie(self.ReverseLeftCurve)
        self.ReverseLeftCurve.start()


    def Left_Line(self):
        pixmap = QPixmap(img_dir + 'V2X_LeftCurveImg.png').scaled(1920, 515)
        self.Line_Img.setPixmap(pixmap)
        self.Line_Img.setGeometry(0, 0, 1920, 515)

    def Right_Line(self):
        pixmap = QPixmap(img_dir + 'V2X_RightCurveImg.png').scaled(1920, 515)
        self.Line_Img.setPixmap(pixmap)
        self.Line_Img.setGeometry(0, 0, 1920, 515)

    def Straight_Line(self):
        pixmap = QPixmap(img_dir + 'V2X_Straight.png').scaled(1920, 515)
        self.Line_Img.setPixmap(pixmap)
        self.Line_Img.setGeometry(0, 0, 1920, 515)

    def suppose_LineDate(self):
        self.running = True
        j = 0
        while self.running:
            if j < len(In_UART_Line):
                self.Uart_Line.append(In_UART_Line[j])
                # self.prev = self.curr
                # self.curr = self.Uart_Line[-1]
                j += 1
            else:
                break
            sleep(1)

    def RunTread(self):
        self.t = threading.Thread(target=self.suppose_LineDate)
        self.t.start()

    def update_Line(self):
        self.gif_timer.timeout.connect(self.Detect_Line)
        self.gif_timer.start(3500)  # 3초마다 Line 업데이트

    def Detect_Line(self):
        self.prev = self.curr
        self.curr = self.Uart_Line[-1]
        # self.prev = self.Uart_Line[-2]

        print("prev:", self.prev, "curr:", self.curr)

        self.Left_Gif()

        # if self.prev != self.curr :
        #     if self.curr == 'L':
        #         self.Left_Gif()
        #         #sleep(2)
        #     elif self.curr == 'R':
        #         self.Right_Gif()
        #         #sleep(2)
        #     elif self.curr == 'S':
        #         if self.prev == 'L':
        #             self.Reverse_Left_Gif()
        #             #sleep(2)
        #         elif self.prev == 'R':
        #             self.Reverse_Right_Gif()
        #             #sleep(2)
        # else: 
        #     if self.curr == 'L':
        #             self.Left_Gif()
        #             #self.Left_Line()
        #     elif self.curr == 'R':
        #             #self.Right_Line()
        #             self.Right_Gif()
        #     elif self.curr == 'S':
        #             self.Straight_Line()
        #             #self.Right_Line()

        if self.prev != self.curr:
            self.Line_Img.hide()
            if self.curr == 'L':
                self.Left_Gif()

                # sleep(2)
            elif self.curr == 'R':
                self.Right_Gif()

                # sleep(2)
            elif self.curr == 'S':
                if self.prev == 'L':
                    self.Reverse_Left_Gif()

                    # sleep(2)
                elif self.prev == 'R':
                    self.Reverse_Right_Gif()
                    # sleep(2)
        else:
            self.Curve_GIF.clear()
            if self.curr == 'L':
                # self.Left_Gif()
                self.Left_Line()
            elif self.curr == 'R':
                self.Right_Line()
                # self.Right_Gif()
            elif self.curr == 'S':
                # self.Left_Gif()
                # self.Right_Line()
                self.Straight_Line()

    def exit_program(self):
        QCoreApplication.quit()

    def btn_exit(self):
        self.exit_btn = QPushButton(self)
        self.exit_btn.setIcon(QIcon(img_dir + 'img01/OFF.png'))
        self.exit_btn.setStyleSheet('background-color: transparent; border: none;')
        self.exit_btn.setIconSize(QSize(50, 50))
        self.exit_btn.setGeometry(1870, 0, 50, 50)
        self.exit_btn.clicked.connect(self.exit_program)


PROGRAM = QApplication(sys.argv)
Run_instance = V2X_Driving_Mode()
PROGRAM.exec()
