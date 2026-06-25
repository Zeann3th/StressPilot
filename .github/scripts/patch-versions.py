import re
import sys

def get_version():
    with open("pubspec.yaml", "r", encoding="utf-8") as f:
        content = f.read()
    match = re.search(r"^version:\s*([^\s+]+)", content, re.MULTILINE)
    if not match:
        raise ValueError("Could not find version in pubspec.yaml")
    return match.group(1)

def patch_makefile(version):
    with open("Makefile", "r", encoding="utf-8") as f:
        content = f.read()
    # Replace VERSION     := 1.0.8
    content = re.sub(r"^VERSION\s*:=\s*.*$", f"VERSION     := {version}", content, flags=re.MULTILINE)
    with open("Makefile", "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Patched Makefile with version {version}")

def patch_iss(version):
    with open("inno-script.iss", "r", encoding="utf-8") as f:
        content = f.read()
    # Replace AppVersion=1.0.9
    content = re.sub(r"^AppVersion=.*$", f"AppVersion={version}", content, flags=re.MULTILINE)
    # Replace OutputBaseFilename=StressPilot-x86_64-1.0.9-Installer
    content = re.sub(r"^OutputBaseFilename=StressPilot-x86_64-.*-Installer$", f"OutputBaseFilename=StressPilot-x86_64-{version}-Installer", content, flags=re.MULTILINE)
    with open("inno-script.iss", "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Patched inno-script.iss with version {version}")

if __name__ == "__main__":
    version = get_version()
    patch_makefile(version)
    patch_iss(version)
