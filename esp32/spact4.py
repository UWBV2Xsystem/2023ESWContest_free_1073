import cv2
import numpy as np
import time

# 차선 검출을 위한 함수
# cap = cv2.VideoCapture("IMG_9740.MOV")


def detect_lanes(frame):
    global c_h_f_line_y
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred_frame = cv2.GaussianBlur(gray_frame, (5, 5), 0)
    edges = cv2.Canny(blurred_frame, 30, 100)


    height, width = edges.shape
    h_data = int(height * 0.8)
    mask = np.zeros_like(edges)
    region_of_interest = np.array([[
        (0, height),
        (width // 2 - 50, height // 2 + 50),
        (width // 2 + 50, height // 2 + 50),
        (width, height),
    ]], dtype=np.int32)
    cv2.fillPoly(mask, region_of_interest, 255)
    masked_edges = cv2.bitwise_and(edges, mask)

    # 확장된 Hough 변환을 사용하여 곡선 검출
    lines = cv2.HoughLinesP(masked_edges, 0.8, np.pi / 80, 50, minLineLength = 0, maxLineGap = 400)

    line_angle = []
    line_angle_xy = []


    for i in lines:
        x1, y1, x2, y2 = i[0][0], i[0][1], i[0][2], i[0][3]
        slope, _in = np.polyfit([x1, x2], [y1,y2],1)

        x_new_top = (c_h_f_line_y-_in)//slope
        x_new_bot = (h_data - _in)//slope

        line_angle.append(slope)
        line_angle_xy.append([int(x_new_bot), h_data, int(x_new_top), int(c_h_f_line_y)])

    plus_list = []
    plus_list = list()

    minus_list = []
    minus_list = list()

    for i in range(len(line_angle)):
        if line_angle[i] > 0 :
            plus_list.append(line_angle[i])
            
        else:
            minus_list.append(line_angle[i])
            
    first_line_index = line_angle.index(max(plus_list))
    sec_line_index = line_angle.index(min(minus_list))

    return first_line_index, sec_line_index, line_angle_xy



# 차량 인식을 위한 함수 (Haar Cascade 사용)
def detect_vehicles(frame):
    global c_h_f_line_y
    # (h_img, w_img) = (frame.shape[0], frame.shape[1])
    h_img = 480
    w_img = 640
    # 필요한 전처리 작업 (e.g., 이미지 크기 조정, 색상 공간 변환 등)
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # 차량을 위한 Haar Cascade XML 파일 로드
    car_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_car.xml')
    # car_cascade = cv2.CascadeClassifier('cars.xml')

    # 차량 검출
    vehicles = car_cascade.detectMultiScale(gray_frame, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    # 원본 이미지에 검출된 차량을 그립니다.
    if type(vehicles) is np.ndarray:
        for (x,y,w,h) in vehicles:
            if y > 450:
                c_h = 450
            else:
                c_h = y

    elif type(vehicles) is tuple : 
        c_h = int(h_img * 0.5)
        c_h_f_line_y = int(h_img * 0.55)

    # cv2.imshow("out", out)

    return 0, vehicles

# 메인 함수
def main():
    global c_h_f_line_y
    R_bot_x = 0
    R_bot_y = 0

    R_top_x = 0
    R_top_y = 0

    L_bot_x = 0
    L_bot_y = 0

    L_top_x = 0
    L_top_y = 0


    # 카메라 초기화
    srt = "http://192.168.35.111:81/stream"
    camera = cv2.VideoCapture(srt)
    # retval, frames = cap.read()
    
    camera.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    camera.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    # (h_img, w_img) = (camera.shape[0], camera.shape[1])
    h_img = 480
    w_img = 640

    while True:
        # 현재 프레임 가져오기
        
        ret, frames = camera.read()
        # ret, frames = cap.read()
        if not ret:
            break


        try:
            H_1st_index, H_sec_index, line_xy = detect_lanes(frames)    
        except:
            pass


        # 차량 인식
        _, cars = detect_vehicles(frames)


        try:
            R_bot_x = line_xy[H_1st_index][0]
            R_bot_y = line_xy[H_1st_index][1]

            R_top_x = line_xy[H_1st_index][2]
            R_top_y = line_xy[H_1st_index][3]

            L_bot_x = line_xy[H_sec_index][0]
            L_bot_y = line_xy[H_sec_index][1]

            L_top_x = line_xy[H_sec_index][2]
            L_top_y = line_xy[H_sec_index][3]


            cv2.line(frames, (R_bot_x, R_bot_y),(R_top_x, R_top_y), (0, 255, 0), 2)
            cv2.line(frames, (L_bot_x, L_bot_y),(L_top_x, L_top_y), (255, 255, 0), 2)

            cv2.line(frames, (L_top_x, L_top_y),(R_top_x, R_top_y), (0, 0, 255), 2)
            cv2.line(frames, (L_bot_x, L_bot_y),(R_bot_x, R_bot_y), (0, 0, 255), 2)
        except:
            pass


        for (x,y,w,h) in cars:
            c_h_f_line_x = (x+x+h)//2
            c_h_f_line_y = (y+y+w)//2 +h //5
            
            if (c_h_f_line_x >= L_top_x) and (c_h_f_line_x <= R_top_x):
                cv2.circle(frames, (c_h_f_line_x, c_h_f_line_y), 10, (0,255,0), 3)
        
        

        # 화면에 출력
        cv2.imshow("Combined Lanes Detection", frames)

        # 키보드 'q' 입력으로 종료
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # 종료 시 리소스 해제
    camera.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
