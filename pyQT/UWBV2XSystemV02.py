import sys
import threading
import mraa
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QToolTip
from PyQt5.QtGui import QIcon, QPixmap, QFont, QFontDatabase
from PyQt5.QtCore import QCoreApplication, QTimer, QSize, Qt

file_dir = "/home/rock/PyQt5"
img_dir = file_dir + "/Qt_img"
font_dir = file_dir
font_path = font_dir + "/utoimagegothicBTTF.ttf"

X_matrix_P = 0.25
X_matrix_N = -0.25
y_matrix_C = 1.5
y_matrix_F = 3.0

White = "color:#FFFFFF"
Red = "color: #BE0000"
Green = "color: #059100"
Orange = "color: #D65B00"
Pink = "color:#FF26A7"

T_q = False


def exit_program():  # Exit Button
    global T_q
    T_q = True
    QCoreApplication.quit()


def MovingAverage(List, data):
    List.append(data)
    if len(List) >= 10:
        List = List[-10:]
    AvedData = sum(List) / len(List)
    return List, AvedData


class UWB_V2X_System(QWidget):
    def __init__(self):
        super().__init__()

        # car Img Location X, Y, W, H
        self.CarFarCenter = [914, 109, 93, 105]
        self.CarCloseCenter = [880, 204, 160, 179]
        self.CarFarLeft = [737, 109, 151, 96]
        self.CarCloseLeft = [586, 212, 245, 155]
        self.CarFarRight = [1032, 109, 151, 96]
        self.CarCloseRight = [1090, 212, 245, 155]

        self.CoordPdoa = [1423, 71, 336, 96]
        self.CoordDist = [1381, 192, 336, 96]
        self.CoordDX = [440, 419, 336, 96]
        self.CoordDy = [1177, 419, 336, 96]
        self.TlCoord = {"R": 65, "Y": 203, "G": 341}
        self.TlTime = [38, 65, 336, 96]

        # Thread & Timer
        self.t = None
        self.timer = QTimer()

        self.u = None
        self.In_Uart = ""
        self.Uart_data = {}

        self.Uart_Car_x = 0
        self.Uart_Car_y = 0
        self.Uart_Car_DIST = 0
        self.Uart_Car_PDoA = 0

        self.Car_moving_y = []
        self.Car_moving_x = []
        self.Car_moving_Dist = []
        self.Car_moving_PDoA = []
        # data

        self.Uart_Car = None

        self.Uart_Traffic_Light = None
        self.Uart_Traffic_Light_PDoA = None
        self.Uart_Traffic_Light_Time = None

        self.key = None
        self.value = None
        self.pairs = None

        self.exit_btn = None
        self.font_uto_gothic_B = None

        self.BackGround_Img = QLabel(self)
        self.TrafficLight_Img = QLabel(self)
        self.Front_Car_Img = QLabel(self)

        self.UI_init()

    def UI_init(self):
        self.setWindowTitle('UWB V2X System')

        self.setGeometry(0, 0, 1920, 515)
        pixmap = QPixmap(img_dir + '/bg.png').scaled(1920, 515)
        self.BackGround_Img.setPixmap(pixmap)

        # Set UART parameters
        self.SetUart("/dev/ttyS2", 115200)

        # Font
        font_id = QFontDatabase.addApplicationFont(font_path)
        self.font_uto_gothic_B = QFontDatabase.applicationFontFamilies(font_id)[0]

        # Pain Label
        self.Uart_Car_x_label = QLabel(self)
        self.Uart_Car_y_label = QLabel(self)
        self.Uart_Car_PDoA_label = QLabel(self)
        self.Uart_Car_DIST_label = QLabel(self)
        self.Uart_T_time_label = QLabel(self)

        self.paintLabelSetting(self.Uart_Car_PDoA_label, Pink, 70, Qt.AlignRight, *self.CoordPdoa)
        self.paintLabelSetting(self.Uart_Car_DIST_label, Green, 70, Qt.AlignRight, *self.CoordDist)
        self.paintLabelSetting(self.Uart_Car_x_label, White, 42, Qt.AlignLeft, *self.CoordDX)
        self.paintLabelSetting(self.Uart_Car_y_label, White, 42, Qt.AlignLeft, *self.CoordDy)
        self.paintLabelSetting(self.Uart_T_time_label, White, 42, Qt.AlignLeft, *self.TlTime)

        self.RunTread()
        self.RunTimer()

        # Exit
        # self.btn_exit()

        # AP par
        self.showFullScreen()
        self.setCursor(Qt.BlankCursor)

    def SetUart(self, Port, rate):
        self.u = mraa.Uart(Port)
        self.u.setBaudRate(rate)
        self.u.setMode(8, mraa.UART_PARITY_NONE, 1)
        self.u.setFlowcontrol(False, False)

    def paintLabelSetting(self, Label, Color, FontSize, Align, X, Y, w, h):
        Label.setGeometry(X, Y, w, h)
        Label.setAlignment(Align)
        Label.setStyleSheet(Color)
        font = QFont(self.font_uto_gothic_B, FontSize)
        Label.setFont(font)
        Label.show()

    def RunTimer(self):
        self.timer.timeout.connect(self.UpdateTrafficLightColor)
        self.timer.timeout.connect(self.UpdateCarLocation)
        self.timer.timeout.connect(self.UpdateText)
        self.timer.timeout.connect(self.GetDataFromUart)

        self.timer.start(100)

    def RunTread(self):
        self.t = threading.Thread(target=self.Uart_receive)
        self.t.daemon = True
        self.t.start()

    def Uart_receive(self):  # Thread
        while True:
            if T_q:
                break

            if self.u.dataAvailable() > 0:
                self.In_Uart += str(self.u.readStr(1))

                try:
                    if self.In_Uart[-1] == '\n':
                        self.pairs = self.In_Uart[1:-2].split(',')
                        self.In_Uart = ""

                        for self.pair in self.pairs:
                            self.key, self.value = self.pair.split(':')
                            # Remove space
                            self.key = self.key.strip()
                            self.value = self.value.strip()
                            self.Uart_data[self.key] = self.value

                        try:
                            if self.Uart_data['type'] == 'Tli':  # if Traffic Light
                                self.Uart_Traffic_Light = self.Uart_data
                                self.Uart_data = {}
                            elif self.Uart_data['type'] == 'car':  # if Car
                                self.Uart_Car = self.Uart_data
                                self.Uart_data = {}
                        except:
                            pass
                except:
                    self.In_Uart = ""
                    pass

    def GetDataFromUart(self):  # QTimer
        try:
            self.Uart_Traffic_Light_PDoA = int(self.Uart_Traffic_Light['PDoA'])
            self.Uart_Traffic_Light_Time = int(self.Uart_Traffic_Light['Time'])

            self.Uart_Car_PDoA = int(self.Uart_Car['PDoA']) // 2
            self.Uart_Car_DIST = round(float(self.Uart_Car['DIST']) - 0.2, 2)
            self.Uart_Car_x = round(float(self.Uart_Car['X']), 2)
            self.Uart_Car_y = round(float(self.Uart_Car['Y']), 2)

            # moving average
            self.Car_moving_Dist, self.Uart_Car_DIST = \
                MovingAverage(self.Car_moving_Dist, self.Uart_Car_DIST)
            self.Car_moving_PDoA, self.Uart_Car_PDoA = \
                MovingAverage(self.Car_moving_PDoA, self.Uart_Car_PDoA)

            self.Car_moving_x, self.Uart_Car_x = \
                MovingAverage(self.Car_moving_x, self.Uart_Car_x)
            self.Car_moving_y, self.Uart_Car_y = \
                MovingAverage(self.Car_moving_y, self.Uart_Car_y)

            self.Uart_Car_DIST = round(float(self.Uart_Car_DIST), 2)
            self.Uart_Car_PDoA = int(self.Uart_Car_PDoA)

        except:
            pass

    def UpdateText(self):  # QTimer
        try:
            self.Uart_Car_x_label.setText(f"ΔX: {self.Uart_Car_x:.2f} m")
            self.Uart_Car_y_label.setText(f"ΔY: {self.Uart_Car_y:.2f} m")
            self.Uart_Car_DIST_label.setText(f"{self.Uart_Car_DIST:.2f} m")
            self.Uart_Car_PDoA_label.setText(f"{self.Uart_Car_PDoA}\260")
            self.Uart_T_time_label.setText(f"{self.Uart_Traffic_Light_Time}")

        except:
            pass

    def UpdateCarLocation(self):  # QTimer
        global y_matrix_C, y_matrix_F, X_matrix_N, X_matrix_P

        self.Uart_Car_DIST_label.setStyleSheet(Green)

        try:
            if self.Uart_Car_x > y_matrix_F:  # Too Far
                self.Front_Car_Img.hide()

            else:  # in display range
                if abs(self.Uart_Car_x) < X_matrix_P:  # if center
                    if self.Uart_Car_y < y_matrix_C:  # and Close
                        self.Uart_Car_DIST_label.setStyleSheet(Red)
                        pixmap = QPixmap(img_dir + '/car_center_close.png').scaled(160, 204)
                        self.Front_Car_Img.setGeometry(*self.CarCloseCenter)

                    elif self.Uart_Car_y < y_matrix_F:  # and Far
                        self.Uart_Car_DIST_label.setStyleSheet(Orange)
                        pixmap = QPixmap(img_dir + '/car_center_far.png').scaled(93, 118)
                        self.Front_Car_Img.setGeometry(*self.CarFarCenter)

                elif self.Uart_Car_x < X_matrix_N:  # if Left
                    if self.Uart_Car_y < y_matrix_C:  # and close
                        pixmap = QPixmap(img_dir + '/car_left_close.png').scaled(245, 155)
                        self.Front_Car_Img.setGeometry(*self.CarCloseLeft)
                    elif self.Uart_Car_y < y_matrix_F:  # and Far
                        pixmap = QPixmap(img_dir + '/car_left_far.png').scaled(151, 96)
                        self.Front_Car_Img.setGeometry(*self.CarFarLeft)

                elif X_matrix_P < self.Uart_Car_x:  # if Right
                    if self.Uart_Car_y < y_matrix_C:  # and Close
                        pixmap = QPixmap(img_dir + '/car_Right_close.png').scaled(245, 155)
                        self.Front_Car_Img.setGeometry(*self.CarCloseRight)

                    elif self.Uart_Car_y < y_matrix_F:  # and Far
                        pixmap = QPixmap(img_dir + '/car_Right_far.png').scaled(151, 96)
                        self.Front_Car_Img.setGeometry(*self.CarFarRight)

                self.Front_Car_Img.setPixmap(pixmap)
                self.Front_Car_Img.show()

        except:
            pass

    def UpdateTrafficLightColor(self):  # QTimer
        try:
            if self.Uart_Traffic_Light['data'] in self.TlCoord:
                self.TrafficLight_Img.setGeometry(38, self.TlCoord[self.Uart_Traffic_Light['data']], 108, 108)
                pixmap = QPixmap(img_dir + '/Traffic_light_' + self.Uart_Traffic_Light['data'] + '.png') \
                    .scaled(108, 108)
                self.TrafficLight_Img.setPixmap(pixmap)
                self.TrafficLight_Img.show()

            else:
                self.TrafficLight_Img.hide()

        except:
            pass

    def btn_exit(self):
        self.exit_btn = QPushButton(self)
        self.exit_btn.setIcon(QIcon('/home/rock/PyQt5/test_uart/img01/OFF.png'))
        self.exit_btn.setStyleSheet('background-color: transparent; border: none;')
        self.exit_btn.setIconSize(QSize(50, 50))
        self.exit_btn.setGeometry(1870, 0, 50, 50)
        self.exit_btn.clicked.connect(exit_program)


PROGRAM = QApplication(sys.argv)
Run_instance = UWB_V2X_System()
PROGRAM.exec()
