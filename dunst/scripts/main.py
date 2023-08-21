#!/usr/bin/env python3

import os
import subprocess
import sys
from datetime import datetime

now = datetime.now()


# Notification Settings #

notification_timeout = 5000
notification_command = "dunstify"  # You can change it to notify-send if you prefer
download_album_art = True  # Set to false if you want


#   Screenshot Settings #
USERNAME = os.getlogin()

screenshot_image_save = False
screenshot_folder = f"/home/{USERNAME}/Pictures/Screenshots"
screenshot_icon = ""

#   Volume  Settings    #
volume_limit = True
volume_down_percentage = 2
volume_up_percentage = 2
volume_icon_0 = "󰸈"
volume_icon_1 = ""
volume_icon_2 = ""
volume_icon_3 = ""

volume_play = "󰐎"
volume_pause = "󰐎"


#   Brightness Settings #

brightness_down_percentage = 5
brightness_up_percentage = 5
brightness_icon_0 = "󰃞"
brightness_icon_1 = "󰃟"
brightness_icon_2 = "󰃠"

#   Other Settings  #
mayus_on = "󰬶"
mayus_off = "󰬵"
num_on = "󰎠"
num_off = "󱧓"


#   Screenshot  #


def get_session_type():
    command = "echo $XDG_SESSION_TYPE"
    output = subprocess.run(
        command, shell=True, check=True, capture_output=True, text=True
    )
    output = output.stdout.strip()
    return output


def screenshot_folder_verif(folder):
    if not os.path.exists(folder):
        command = f"mkdir -pv {folder}"
        subprocess.run(command, shell=True, check=True)
    else:
        return f"The folder '{folder}' is already created"


def screenshot_image_verif(image):
    folder = screenshot_folder

    if os.path.isfile(f"{folder}/{image}") and screenshot_image_save:
        command = f"{notification_command} -t {notification_timeout} -i {folder}/{image} -u low  '{screenshot_icon}     Screenshot Saved'"
        subprocess.run(command, shell=True)
    else:
        command = f"{notification_command} -t {notification_timeout} -u low '{screenshot_icon}     Screenshot Copied to Clipboard' -i '/tmp/screenshot.png'"
        subprocess.run(command, shell=True)


def screenshot():
    time = now.strftime("%Y%m%d_%H%M%S")
    screenshot_format = f"Screenshot_{time}.png"
    session = str(get_session_type().replace(" ", ""))

    folder, image = screenshot_folder, screenshot_format
    screenshot_folder_verif(folder)

    if session == "wayland":
        if screenshot_image_save:
            command = (
                f'slurp | grim -g - "{folder}/{image}" && wl-copy < "{folder}/{image}"'
            )
            subprocess.run(command, shell=True)
            screenshot_image_verif(image)
        else:
            command = f'slurp | grim -g - "/tmp/screenshot.png" && wl-copy < "/tmp/screenshot.png"  '
            try:
                result = subprocess.run(command, shell=True, check=True)
                screenshot_image_verif("/tmp/screenshot.png")

            except subprocess.CalledProcessError as e:
                print(e)

    elif session == "x11" or session == "xorg":
        if screenshot_image_save:
            command = f"scrot -s {folder}/{image} && xclip -selection clipboard -t image/png -i {folder}/{image}"
            subprocess.run(command, shell=True)
            screenshot_image_verif(f"{folder}/{image}")
        else:
            command = f"scrot -s '/tmp/screenshot.png' && xclip -selection clipboard -t image/png -i '/tmp/screenshot.png'"
            subprocess.run(command, shell=True)
            screenshot_image_verif("/tmp/screenshot.png")


#   Brightness  #


def get_brightness_folder():
    command = "ls /sys/class/backlight/"
    try:
        output = subprocess.run(
            command, shell=True, check=True, capture_output=True, text=True
        )
        result = output.stdout.strip()
        return result
    except:
        print("Error:")


def get_brightness():
    brightness_folder = get_brightness_folder()
    brightness_path = f"/sys/class/backlight/{brightness_folder}/brightness"
    max_brightness_path = f"/sys/class/backlight/{brightness_folder}/max_brightness"

    if not os.path.exists(brightness_path) or not os.path.exists(max_brightness_path):
        print("Error: Brightness information not found.")
        return None, None

    with open(max_brightness_path, "r") as max_brightness_file:
        max_brightness = int(max_brightness_file.read().strip())

    with open(brightness_path, "r") as brightness_file:
        brightness = int(brightness_file.read().strip())

    return int((brightness / max_brightness) * 100)


def verify_brightness():
    br = get_brightness()
    if br >= 85:
        return brightness_icon_2
    elif br <= 25:
        return brightness_icon_0
    else:
        return brightness_icon_1


def show_brightness_notif():
    brightness_icon = verify_brightness()
    brightness = get_brightness()
    subprocess.run(
        [
            f"{notification_command}",
            "-t",
            str(notification_timeout),
            "-h",
            "string:x-dunst-stack-tag:brightness_notif",
            "-h",
            f"int:value:{brightness}",
            f"{brightness_icon}  {brightness}%",
            "-u",
            "low",
        ]
    )


#   Sound   #


def get_mute():
    command = "pactl get-sink-mute @DEFAULT_SINK@"
    output = subprocess.run(
        command, shell=True, check=True, capture_output=True, text=True
    )
    output = output.stdout.strip()
    if output == "Mute: no":
        output = False
        return output
    elif output == "Mute: yes":
        output = True
        return output


def get_volume():
    command = (
        "pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1"
    )
    try:
        volume = subprocess.run(
            command, shell=True, check=True, capture_output=True, text=True
        )
        volume = volume.stdout.strip()
        return int(volume)
    except:
        return "Error:"


def verify_volume():
    muted = get_mute()
    vl = get_volume()
    if vl >= 85:
        return volume_icon_3
    elif vl <= 25:
        return volume_icon_1
    elif vl == 0 or muted:
        return volume_icon_0
    else:
        return volume_icon_2


def show_volume_notif():
    volume_icon = verify_volume()
    volume = get_volume()
    image_path = get_album_art(download_album_art)

    if image_path and os.path.exists(image_path):
        subprocess.run(
            [
                f"{notification_command}",
                "-t",
                str(notification_timeout),
                "-h",
                "string:x-dunst-stack-tag:volume_notif",
                "-h",
                f"int:value:{volume}",
                f"{volume_icon}  {volume}%",
                "-u",
                "low",
                "-i",
                f"{image_path}",
            ]
        )
    else:
        subprocess.run(
            [
                f"{notification_command}",
                "-t",
                str(notification_timeout),
                "-h",
                "string:x-dunst-stack-tag:volume_notif",
                "-h",
                f"int:value:{volume}",
                f"{volume_icon}  {volume}%",
                "-u",
                "low",
            ]
        )


def show_mute_notif():
    vdown, vup = volume_down_percentage, volume_up_percentage
    volume_icon = volume_icon_0
    volume = get_volume()
    mute = get_mute()
    if mute:
        command = f"pactl set-sink-mute @DEFAULT_SINK@ {False}"

        subprocess.run(command, shell=True)
        show_volume_notif()

    else:
        command = f"pactl set-sink-mute @DEFAULT_SINK@ {True}"

        subprocess.run(command, shell=True)
        subprocess.run(
            [
                f"{notification_command}",
                "-t",
                str(notification_timeout),
                "-h",
                "string:x-dunst-stack-tag:volume_notif",
                "-h",
                f"int:value:{volume}",
                f"{volume_icon}  Muted",
                "-u",
                "low",
            ]
        )


#   Reproductor Media   #
#   I Programmed this while I was listening to:
#   SHYNESS BOY - Anri 🎵

# Natsu noooo pati dekoe

# Funcion creada por Nicholas Anand, yo solo la copié


def get_album_art(download_album_art):
    try:
        url = (
            subprocess.check_output(["playerctl", "-f", "{{mpris:artUrl}}", "metadata"])
            .decode()
            .strip()
        )
        if url.startswith("file://"):
            album_art = url[7:]
        elif url.startswith("http://") and download_album_art:
            filename = url.split("/")[-1]
            album_art = f"/tmp/{filename}"
            if not os.path.exists(album_art):
                subprocess.run(["wget", "-O", album_art, url])
        elif url.startswith("https://") and download_album_art:
            filename = url.split("/")[-1]
            album_art = f"/tmp/{filename}"
            if not os.path.exists(album_art):
                subprocess.run(["wget", "-O", album_art, url])
        else:
            album_art = ""
        return album_art
    except:
        return "Z"


#   Main Function   #


def main(option):
    global brightness_down_percentage, brightness_up_percentage, volume_limit
    bdown, bup = brightness_down_percentage, brightness_up_percentage
    vdown, vup = volume_down_percentage, volume_up_percentage
    brightness, volume = get_brightness(), get_volume()

    if option == "brightness_up":
        subprocess.run(["light", "-A", f"{bup}"])
        show_brightness_notif()
    elif option == "brightness_down":
        if brightness - bdown < 5:
            subprocess.run(["light", "-S", "5"])
        else:
            subprocess.run(["light", "-U", f"{bdown}"])
        show_brightness_notif()
    elif option == "volume_down":
        subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"-{vdown}%"])
        show_volume_notif()
    elif option == "volume_up":
        if volume_limit and volume + vup > 100:
            subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", "100%"])
        else:
            subprocess.run(["pactl", "set-sink-volume", "@DEFAULT_SINK@", f"+{vup}%"])
        show_volume_notif()
    elif option == "volume_mute":
        show_mute_notif()
    elif option == "screenshot":
        screenshot()
    else:
        print("Invalid")


if __name__ == "__main__":
    print("username: ", USERNAME)
    print("Brightness: ", get_brightness(), "%")
    print("Volume Level: ", get_volume(), "%")
    print("Muted: ", get_mute())
    print("Session Type:", get_session_type().replace(" ", ""))
    print("Images Enabled: ", download_album_art)

    try:
        main(sys.argv[1])
    except Exception as error:
        print("Exception:", error)
