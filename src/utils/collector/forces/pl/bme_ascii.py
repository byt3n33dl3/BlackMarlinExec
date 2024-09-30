import pyfiglet
import random

custom_characters = "|\()-_][<>"

ascii_art = pyfiglet.figlet_format("BLACKMARLINEXEC")

custom_ascii_art = ''.join(random.choice(custom_characters) if char != ' ' else ' ' for char in ascii_art)

print(custom_ascii_art)
