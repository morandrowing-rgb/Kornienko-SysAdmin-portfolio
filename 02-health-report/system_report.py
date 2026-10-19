#!/usr/bin/env python3
"""Отчёт о состоянии Linux-сервера: диски, память, нагрузка, службы, порты.
Только стандартная библиотека. Использование: ./system_report.py [--json report.json] [--services nginx,ssh]"""
import argparse, json, platform, shutil, socket, subprocess, sys
from datetime import datetime
from pathlib import Path

def run(cmd):
    try: return subprocess.run(cmd, capture_output=True, text=True, timeout=10).stdout.strip()
    except Exception as e: return f"n/a ({e})"

def service_state(name):
    if not shutil.which("systemctl"): return "unknown (нет systemctl)"
    return run(["systemctl", "is-active", name]) or "unknown"

def port_open(port, host="127.0.0.1"):
    try:
        with socket.create_connection((host, port), timeout=2): return True
    except OSError: return False

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--json"); ap.add_argument("--services", default="ssh,cron")
    ap.add_argument("--ports", default="22,80,443"); a = ap.parse_args()
    total, used, free = shutil.disk_usage("/")
    report = {
        "host": platform.node(), "os": f"{platform.system()} {platform.release()}",
        "time": datetime.now().isoformat(timespec="seconds"),
        "disk_root": {"total_gb": round(total/2**30,1), "used_pct": round(used/total*100,1), "free_gb": round(free/2**30,1)},
        "loadavg": run(["cat","/proc/loadavg"]).split()[:3],
        "memory": run(["free","-m"]),
        "uptime": run(["uptime","-p"]) or run(["uptime"]),
        "services": {s: service_state(s) for s in a.services.split(",") if s},
        "ports_open_local": {p: port_open(int(p)) for p in a.ports.split(",") if p},
    }
    print(f"=== {report['host']} | {report['time']} | {report['os']} ===")
    print(f"Диск /: занято {report['disk_root']['used_pct']}% , свободно {report['disk_root']['free_gb']} ГБ")
    print(f"Load average: {' '.join(report['loadavg'])} | Uptime: {report['uptime']}")
    print("Службы:", ", ".join(f"{k}={v}" for k,v in report["services"].items()))
    print("Порты localhost:", ", ".join(f"{k}={'open' if v else 'closed'}" for k,v in report["ports_open_local"].items()))
    if report["disk_root"]["used_pct"] >= 90: print("ВНИМАНИЕ: диск заполнен >=90%")
    if a.json: Path(a.json).write_text(json.dumps(report, ensure_ascii=False, indent=2)); print(f"JSON: {a.json}")
if __name__ == "__main__": main()
