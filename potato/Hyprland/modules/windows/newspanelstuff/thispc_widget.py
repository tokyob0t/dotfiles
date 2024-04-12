from json import loads as json_loads

from PotatoWidgets import Bash, Variable

HOSTNAMECTL = json_loads(Bash.get_output("hostnamectl --json short"))


def get_cpu() -> str:
    CPU = Bash.get_output("cat /proc/cpuinfo").splitlines()
    CPU = next(i.split() for i in CPU if "model name" in i)
    CPU = " ".join(i for i in CPU[3:])
    return CPU


def get_gpu() -> str:
    GPU = Bash.get_output("ls -1 /proc/driver/nvidia/gpus").splitlines()[0]
    GPU_INFO = Bash.get_output(
        f"cat /proc/driver/nvidia/gpus/{GPU}/information"
    ).splitlines()
    GPU_INFO = next(i.split() for i in GPU_INFO if "Model:" in i)
    GPU_INFO = " ".join(i for i in GPU_INFO if i != "Model:")
    return GPU_INFO


def get_kernel() -> str:
    return HOSTNAMECTL["KernelRelease"]


def get_host() -> str:
    return HOSTNAMECTL["Hostname"]


def get_hardware_model() -> str:
    return HOSTNAMECTL["HardwareModel"]


def get_architecture() -> str:
    return Bash.get_output("uname -m")


def get_packages() -> str:
    return Bash.get_output("pacman -Q | wc -l").splitlines()[0]


def get_zshversion() -> str:
    return " ".join(Bash.get_output("zsh --version").splitlines()[0].split()[:2])


def get_wm() -> str:
    wm = Bash.get_env("DESKTOP_SESSION")

    return wm


def get_system_info():
    return {
        "host": get_host(),
        "kernel": get_kernel(),
        "pc": get_hardware_model(),
        "packages": get_packages(),
        "desktop": get_wm(),
        "cpu": get_cpu(),
        "gpu": get_gpu(),
        "architecture": get_architecture(),
    }


ThisPCInfo = Variable(get_system_info())
