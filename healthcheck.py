#!/usr/bin/env python3
import sys
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

# Kill anoying SSL cert warnings
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


PROXIES = [
    "http://172.28.0.2:6666",
    "http://172.28.0.3:6666",
    "http://172.28.0.4:6666",
]


def pretty_test():
    print("\033[36mTesting 3 Tor HTTPTunnel proxies...\033[0m\n")
    for proxy in PROXIES:
        try:
            r = requests.get(
                "https://check.torproject.org/api/ip",
                proxies={"http": proxy, "https": proxy},
                timeout=15,
                verify=False
            )
            if r.status_code == 200 and r.json().get("IsTor"):
                ip = r.json()["IP"]
                print(f"{proxy:26} → \033[32m{ip}\033[0m  [TOR]")
            else:
                print(f"{proxy:26} → \033[33mweak/non-Tor response\033[0m")
        except Exception:
            print(f"{proxy:26} → \033[31mDOWN\033[0m")
    print()


def health_check():
    alive = 0
    for proxy in PROXIES:
        try:
            r = requests.get(
                "https://check.torproject.org/api/ip",
                proxies={"http": proxy, "https": proxy},
                timeout=8,
                verify=False
            )
            if r.status_code == 200 and r.json().get("IsTor"):
                alive += 1
        except Exception:
            pass
    sys.exit(0 if alive >= 2 else 1)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "health":
        health_check()
    else:
        pretty_test()
