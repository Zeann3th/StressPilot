import os
import sys
import json
import re
import urllib.request

def get_version():
    with open("pubspec.yaml", "r", encoding="utf-8") as f:
        content = f.read()
    match = re.search(r"^version:\s*([^\s+]+)", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not find version in pubspec.yaml")
    return match.group(1)

def main():
    token = os.environ.get("UPDATER_ADMIN_TOKEN")
    if not token:
        print("Error: UPDATER_ADMIN_TOKEN env var is not set")
        sys.exit(1)
    
    version = get_version()
    print(f"Publishing release version {version} to updater server...")
    
    # Construct download URLs
    windows_url = f"https://updater.stresspilot.zeann3th.com/releases/StressPilot-x86_64-{version}-Installer.exe"
    linux_url = f"https://updater.stresspilot.zeann3th.com/releases/stress-pilot_{version}_amd64.deb"
    
    payload = {
        "version": version,
        "downloads": {
            "windows": windows_url,
            "linux": linux_url
        },
        "releaseNotes": f"Automatically built and published StressPilot client v{version}"
    }
    
    data = json.dumps(payload).encode("utf-8")
    
    req = urllib.request.Request(
        "https://updater.stresspilot.zeann3th.com/version",
        data=data,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        },
        method="PUT"
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            res_body = response.read().decode("utf-8")
            print("Successfully updated version details on server:")
            print(res_body)
    except Exception as e:
        print(f"Error publishing to updater server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
