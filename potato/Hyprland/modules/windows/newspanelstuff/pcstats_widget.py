from psutil import cpu_stats, disk_usage, sensors_temperatures, virtual_memory


def core_temps():
    return sensors_temperatures().get("coretemp", [])[1:]


def nvme_usage():
    return disk_usage("/dev/nvme0n1")._asdict()


def ram_usage():
    return {
        i: j / 1024
        for i, j in virtual_memory()._asdict().items()
        if i not in ["cached", "buffers", "shared", "slab", "inactive", "percent"]
    }


import pprint

pprint.pprint(
    {
        "disk": nvme_usage(),
        "ram": ram_usage(),
        "core": core_temps(),
    }
)
