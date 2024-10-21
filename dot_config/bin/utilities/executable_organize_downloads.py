#!/usr/bin/env python3

import os
import shutil


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
    organize_folder("/Users/timothybryant/Downloads")
