import os
import sys
import shutil

files = [
    "master_switch.ahk",
    "text_x.ahk"
]

def build():
    if(not os.path.exists("./build")):
        os.mkdir("./build")
    
    for file in files:
        f_name = file.split(".")[0]
        os.system(fr'C:\Users\TruUser\AppData\Local\Programs\AutoHotkey\Compiler\Ahk2Exe.exe /in .\{file} /out ./build/{f_name}.exe')

def release():
    if(not os.path.exists("./dist")):
        os.mkdir("./dist")
    build()
    for file in os.listdir("./build"):
        shutil.copy(
            os.path.join("./build", file), 
            os.path.join("./dist", file))
    shutil.copytree("./resources/", "./dist/resources")
    # shutil.copy("config.ini", )

if __name__ == "__main__":
    build()