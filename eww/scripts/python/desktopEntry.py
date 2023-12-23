#!/usr/bin/python

import os
import json
from os.path import join
from os import listdir as ls
from magic import from_file
from _common import getIcon, updateEww

HOME = os.environ.get("HOME")
DESKTOP = f"{HOME}"
FILES = ls(f"{HOME}")
ELEMENTS_PER_ROW = 10

def getType(FILE):
    path = f"{DESKTOP}/{FILE}"
    if os.path.isdir(path):
        return "directory", None
    else:
        magic_result = from_file(path).split(" ")[0].lower()
        file_extension = os.path.splitext(FILE)[1][1:].lower()
        return magic_result, file_extension

def getAction(FILE):
    file_type, _ = getType(FILE)

    if file_type == "directory":
        return f"nautilus {DESKTOP}/{FILE}  > /dev/null 2>&1"
    elif file_type == "image":
        return f"imv {DESKTOP}/{FILE}  > /dev/null 2>&1"
    elif file_type == "video":
        return f"mpv {DESKTOP}/{FILE}  > /dev/null 2>&1"
    else:
        return f"codium {DESKTOP}/{FILE}  > /dev/null 2>&1"

# Crear la matriz FILETYPES
FILETYPES = []
row = []
for i in range(len(FILES)):
    if not FILES[i].startswith("."):
        file_data = {
            "id": i,
            "name": FILES[i].capitalize(),
            "type": getType(FILES[i])[0],
            "onclick": getAction(FILES[i]),
            "icon": (
                getIcon("folder") if "directory" in getType(FILES[i]) else
                getIcon("text-x-python") if "py" in getType(FILES[i]) else
                getIcon("text-x-lua") if "lua" in getType(FILES[i]) else
                getIcon("text-markdown") if "md" in getType(FILES[i]) else
                getIcon("application-json") if "json" in getType(FILES[i]) else
                getIcon("text-plain")
            )
        }
        row.append(file_data)
        if len(row) == ELEMENTS_PER_ROW:
            FILETYPES.append(row)
            row = []

if row:
    FILETYPES.append(row)

print(json.dumps(FILETYPES))
