# 2023ESWContest_free_1136
## [ UWB로 구현한 V2X System ]

![자유공모_1136_V2X_작품사진](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/assets/109073690/3ffa971b-8347-4578-bb22-23048ea2cdd4)



### 🚙 프로젝트 소개
------
UWB(Ultra wide band) 통신 모듈을 활용하여 V2X(Vehicle-to-everything) 시스템을 구현

### 🕰️ 개발 기간
------
* 23.03.02 ~ 23.08.31

### 🧑‍🤝‍🧑 멤버 구성
------
- 팀장  채도윤 _ 회로 및 PCB 설계, FPGA 설계, 펌웨어 및 리눅스 디스플레이 드라이버 개발, 기구 설계
- 팀원  김영빈 _ 데이터 처리 및 분석, STM 펌웨어 작성 
- 팀원  이찬현 _ 곡선 차선 여부 검출을 위한 영상처리 및 객체인식 
- 팀원  홍선주 _ pyQT GUI 개발, 거리 측정 알고리즘 작성, 위치 측위 Testbed 구성



### 📋 개발내용
------
* UWB_STM32F411_Module
  - [Schematic](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/blob/main/UWB_STM32_Module/Schematic.pdf)
  - [F/W](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/tree/main/UWB_STM32_Module/F%3AW)  

* FPGA_UART_Module
  - [Schematic](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/blob/main/FPGA_UART_Module/Schematic.pdf)
  - [FPGA RTL](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/tree/main/FPGA_UART_Module/RTL)

* Linux_Mother_Board
  - [Schematic](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/blob/main/Linux_Mother_Board/Schematic.pdf)
  - [GUI_pyQT](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/tree/main/Linux_Mother_Board/pyQT)
 
* Linux_LCD_Driver
  - [Driver](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/tree/main/Linux_LCD_Driver)
 
* Mechanical_design
  - [Render](https://github.com/UWBV2Xsystem/2023ESWContest_free_1136/tree/main/Mechanical_design)



### ⚙️ 개발환경
------
|    **구분**     |              **내용**               |
|:-------------:|:---------------------------------:|
| **Language**  |       C, Python3.8.10, VHDL       |
|    **IDE**    |       STM32CudeIDE, Pycharm       |
| **Framework** |               pyQt5               |
|   **Tool**    | Kicad, Fusion360, Lattice Diamond |
|    **OS**     |              Debian               |
|  **Library**  |              OpenCV               |


### 📌 주요기능
------
UWB 모듈을 통해 거리와 상대각도를 측정하여 GUI에 출력




### 🎥 작동 영상
------
[![Video Label](http://img.youtube.com/vi/2-DkrryEUOI/0.jpg)](https://youtu.be/2-DkrryEUOI)








