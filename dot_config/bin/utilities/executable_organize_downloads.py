#!/usr/bin/env python3

import os
import shutil


def identify_downloads_folder():
    """Identify the user's downloads folder."""
    return os.path.expanduser("~/Downloads")


def organize_folder(folder):
    """Organize files in the given folder."""
    file_types = {
        "Images": [".jpeg", ".jpg", ".png", ".gif", ".HEIC"],
        "Videos": [".mp4", ".avi", ".mov"],
        "Documents": [
            ".pdf",
            ".docx",
            ".txt",
            ".pptx",
            ".xlsx",
            ".csv",
            ".xls",
            ".list",
        ],
        "Archives": [".zip", ".rar", ".tar", ".gz", ".deb", ".bz2", ".tgz", ".rpm"],
        "Executables": [".exe", ".msi"],
        "Scripts": [".py", ".sh", ".bat", ".tf", ".tfvars", ".hcl", ".sql", ".tfstate"],
        "Music": [".mp3", ".wav"],
        "Apps": [".dmg", ".pkg", ".app", ".ismp7", ".vsix"],
        "Webpages": [".html", ".htm", ".php", ".css", ".js"],
        "Configuration": [
            ".json",
            ".xml",
            ".yaml",
            ".yml",
            ".toml",
            ".ini",
            ".zone",
            ".config",
            ".conf",
            ".properties",
        ],
        "3D-Printing": [".stl", ".3mf"],
    }

    created_dirs = set()

    # First, ensure all necessary directories exist
    for folder_name in list(file_types.keys()) + ["OTHER"]:
        target_folder = os.path.join(folder, folder_name)
        if target_folder not in created_dirs:
            os.makedirs(target_folder, exist_ok=True)
            created_dirs.add(target_folder)

    # Step 1: Process files in OTHER folder that match known types
    other_folder = os.path.join(folder, "OTHER")
    if os.path.exists(other_folder):
        for filename in os.listdir(other_folder):
            file_path = os.path.join(other_folder, filename)
            if not os.path.isfile(file_path):
                continue

            ext = os.path.splitext(filename)[1].lower()
            # Check if file belongs in a specific category
            for folder_name, extensions in file_types.items():
                if ext in extensions:
                    target_folder = os.path.join(folder, folder_name)
                    shutil.move(file_path, os.path.join(target_folder, filename))
                    print(f"Moved {filename} from OTHER to {folder_name}")
                    break

    # Step 2 & 3: Process files in root directory
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        # Skip if it's a directory or not in the root folder
        if not os.path.isfile(file_path) or os.path.dirname(file_path) != folder:
            continue

        ext = os.path.splitext(filename)[1].lower()
        found_match = False

        # Try to match to a specific category
        for folder_name, extensions in file_types.items():
            if ext in extensions:
                target_folder = os.path.join(folder, folder_name)
                shutil.move(file_path, os.path.join(target_folder, filename))
                print(f"Moved {filename} to {folder_name}")
                found_match = True
                break

        # If no match found, move to OTHER
        if not found_match:
            other_folder = os.path.join(folder, "OTHER")
            shutil.move(file_path, os.path.join(other_folder, filename))
            print(f"Moved {filename} to OTHER")


if __name__ == "__main__":
    folder = identify_downloads_folder()
    if folder is not None:
        organize_folder(folder)
    else:
        print("Downloads folder not found")
