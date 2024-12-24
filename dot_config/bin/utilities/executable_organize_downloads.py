#!/usr/bin/env python3

import os
import shutil


def identify_downloads_folder():
    user = os.getlogin()
    if user == "timothybryant":
        return "/Users/timothybryant/Downloads"
    elif user == "timothy.bryant":
        return "/Users/timothy.bryant/Downloads"
    else:
        return None


def organize_folder(folder):
    file_types = {
        "Images": [".jpeg", ".jpg", ".png", ".gif"],
        "Videos": [".mp4", ".avi", ".mov"],
        "Documents": [".pdf", ".docx", ".txt", ".pptx", ".xlsx", ".csv", ".xls"],
        "Archives": [".zip", ".rar", ".tar", ".gz", ".deb", ".bz2", ".tgz", ".rpm"],
        "Executables": [".exe", ".msi"],
        "Scripts": [".py", ".sh", ".bat", ".tf", ".tfvars", ".hcl", ".sql", ".tfstate"],
        "Music": [".mp3", ".wav"],
        "Apps": [".dmg", ".pkg", ".app"],
        "Webpages": [".html", ".htm", ".php", ".css", ".js"],
        "Configuration": [".json", ".xml", ".yaml", ".yml", ".toml", ".ini"],
        "3D-Printing": [".stl", ".3mf"],
    }

    # use set to avoid redundant directory checks
    created_dirs = set()

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        if os.path.isfile(file_path):
            ext = os.path.splitext(filename)[1].lower()
            for folder_name, extensions in file_types.items():
                if ext in extensions:
                    target_folder = os.path.join(folder, folder_name)
                    if target_folder not in created_dirs:
                        os.makedirs(target_folder, exist_ok=True)
                        created_dirs.add(target_folder)
                    shutil.move(file_path, os.path.join(target_folder, filename))
                    print(f"Moved {filename} to {folder_name}")
                    break


if __name__ == "__main__":
    folder = identify_downloads_folder()
    if folder is not None:
        organize_folder(folder)
    else:
        print("Downloads folder not found")
