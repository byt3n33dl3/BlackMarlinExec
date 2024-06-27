import os
import sys
import time

import cv2
from moviepy.editor import VideoFileClip
from PIL import Image
from playsound import playsound

VIDEO_NAME = "examples/bad_apple.mp4"

AUDIO_NAME = ".".join(VIDEO_NAME.split(".")[:-1]) + ".mp3"
FRAME_TIME = 33333000

if not os.path.exists(AUDIO_NAME):
    videoclip = VideoFileClip(VIDEO_NAME)
    audioclip = videoclip.audio
    audioclip.write_audiofile(AUDIO_NAME)
    audioclip.close()
    videoclip.close()

vidcap = cv2.VideoCapture(VIDEO_NAME)
playsound(AUDIO_NAME, False)
old = time.time_ns()

os.system("clear")
while True:
    success, frame = vidcap.read()
    im_pil = Image.fromarray(frame)
    width, height = im_pil.size
    BUFFER = ""

    for y in range(0, height, int(height / 100)):
        for x in range(0, width, int(width / 200)):
            r, g, b = im_pil.getpixel((x, y))
            v = (r + g + b) / 3
            BUFFER += "#" if v > 50 else " "
        BUFFER += "\n"
    os.system(f"tput cup 0 0; echo '{BUFFER}'")
    actualFramteTime = time.time_ns() - old
    sleeptime = FRAME_TIME - actualFramteTime
    if sleeptime > 0:
        time.sleep(sleeptime / 1000000000)
    old = time.time_ns()
