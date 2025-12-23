#!/usr/bin/env python3 
import os
import re
import sys

SPECIAL_MAPPINGS = {
    "C#": "c-sharp",
    "C++": "cpp",
    "C": "c"
}

def to_kebab_case(name):
    if name in ('.', '..'):
        return name
    
    if name in SPECIAL_MAPPINGS:
        return SPECIAL_MAPPINGS[name]
    
    is_hidden = name.startswith('.')
    working_name = name[1:] if is_hidden else name
    
    # Remove apostrophes
    working_name = working_name.replace("'", "")
    
    # Replace non-word characters with hyphens
    s = re.sub(r'[\W_]+', '-', working_name, flags=re.UNICODE)
    
    s = s.lower()
    s = re.sub(r'-+', '-', s)
    s = s.strip('-')
    
    if not s:
        return name
        
    if is_hidden:
        return '.' + s
    return s

def process_path(target_path):
    if not os.path.exists(target_path):
        print(f"Error: Path {target_path} does not exist.")
        return

    if not os.path.isdir(target_path):
        print(f"Error: Path {target_path} is not a directory.")
        return

    all_rename_ops = []
    
    # 1. Collect all subdirectories (bottom-up)
    for root, dirs, files in os.walk(target_path, topdown=False):
        for d in dirs:
            new_name = to_kebab_case(d)
            if new_name != d:
                old_path = os.path.join(root, d)
                new_path = os.path.join(root, new_name)
                all_rename_ops.append((old_path, new_path))

    # 2. Check the target directory itself (if it's not the root or a drive)
    parent_dir = os.path.dirname(target_path)
    base_name = os.path.basename(target_path)
    if base_name: # Avoid root paths
        new_base_name = to_kebab_case(base_name)
        if new_base_name != base_name:
            new_target_path = os.path.join(parent_dir, new_base_name)
            all_rename_ops.append((target_path, new_target_path))

    if not all_rename_ops:
        print("No directories need renaming.")
        return

    # Sort by depth (longest paths first) to ensure bottom-up logic
    all_rename_ops.sort(key=lambda x: x[0].count(os.sep), reverse=True)

    print(f"Renaming {len(all_rename_ops)} directories...")
    
    for old, new in all_rename_ops:
        try:
            os.rename(old, new)
            print(f"RENAMED: {old} -> {new}")
        except Exception as e:
            print(f"ERROR renaming {old}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 rename_script.py <directory_path>")
        sys.exit(1)
    
    target_path = os.path.abspath(sys.argv[1])
    process_path(target_path)
