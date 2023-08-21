# A Dunst-Python OSD Project

An OSD made in Python, currently supports:
   * Brightness Display
   * Sound Display
   * Spotify Display
   * Screenshots  

TODO:  
   * Adjust compatibility with xorg
   * Num Lock and Caps Lock Display State

Original Project:  
 [Nmoleo/i3-volume-brightness-indicator](https://gitlab.com/Nmoleo/i3-volume-brightness-indicator)

 Preview:

<img src="/images/Preview1.jpg"> <img src="/images/Preview2.jpg">  
<img src="/images/Preview3.jpg"> <img src="/images/Preview4.jpg">


### Dependencies

To run the script successfully on your Linux system, you'll need the following dependencies:

   Wayland
   ```
   light dunst pulseaudio playerctl grim slurp wl-clipboard
   ```
   Xorg/X11
   ```
   xbacklight dunst pulseaudio playerctl scrot xclip
   ```

Ensure that you have the necessary permissions to execute these commands and make changes to the brightness and volume settings on your system. Once you have installed these dependencies, the script should work correctly.  

`Note: I'm not an expert, but I tried my best considering compatibilities in Wayland and Xorg.`

## Usage
You need to manually bind the keybindings that you wanna use for the actions:

Example on [Hyprland](https://github.com/hyprwm/Hyprland):

```bash
# Using hyprland.conf

# Volume-Brightness Keybindings #
binde = $mainMod, F8, exec, ~/.config/dunst/scripts/main.py volume_up
binde = $mainMod, F7, exec, ~/.config/dunst/scripts/main.py volume_down
bindr = $mainMod, F6, exec, ~/.config/dunst/scripts/main.py volume_mute

binde = $mainMod, code:69 , exec, ~/.config/dunst/scripts/main.py brightness_up
binde = $mainMod, code:68 , exec, ~/.config/dunst/scripts/main.py brightness_down

```

### List of Actions
- volume_up
- volume_down
- volume_mute 
- brightness_up
- brightness_down
- screenshot
