#!/usr/bin/env python3 
import os
import re
import sys

SPECIAL_MAPPINGS = {
    "C#": "c-sharp",
    "C++": "cpp",
    "C": "c"
}

def _kebab_logic(name):
    if not name:
        return ""
    
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

def to_kebab_case(name, is_file=False):
    if name in ('.', '..'):
        return name
    
    if name in SPECIAL_MAPPINGS:
        return SPECIAL_MAPPINGS[name]
    
    if is_file:
        base, ext = os.path.splitext(name)
        # Handle hidden files with no extension (e.g., .bashrc)
        if name.startswith('.') and not ext:
            return _kebab_logic(name)
        # Handle normal files or hidden files with extension
        return _kebab_logic(base) + ext.lower()
    
    return _kebab_logic(name)

def process_path(target_path):
    if not os.path.exists(target_path):
        print(f"Error: Path {target_path} does not exist.")
        return

    if not os.path.isdir(target_path):
        print(f"Error: Path {target_path} is not a directory.")
        return

    print(f"Target directory: {target_path}")
    print("What would you like to rename recursively?")
    print("[d] Directories only")
    print("[f] Files only")
    print("[b] Both")
    choice = input("Choice (d/f/b): ").lower().strip()
    
    rename_dirs = choice in ('d', 'b')
    rename_files = choice in ('f', 'b')
    
    if not rename_dirs and not rename_files:
        print("Invalid choice. Exiting.")
        return

    all_rename_ops = []
    
    # 1. Collect all items (bottom-up)
    for root, dirs, files in os.walk(target_path, topdown=False):
        if rename_files:
            for f in files:
                new_name = to_kebab_case(f, is_file=True)
                if new_name != f:
                    old_path = os.path.join(root, f)
                    new_path = os.path.join(root, new_name)
                    all_rename_ops.append((old_path, new_path))
        
        if rename_dirs:
            for d in dirs:
                new_name = to_kebab_case(d, is_file=False)
                if new_name != d:
                    old_path = os.path.join(root, d)
                    new_path = os.path.join(root, new_name)
                    all_rename_ops.append((old_path, new_path))

    # 2. Check the target directory itself if requested
    if rename_dirs:
        parent_dir = os.path.dirname(target_path)
        base_name = os.path.basename(target_path)
        if base_name: # Avoid root paths
            new_base_name = to_kebab_case(base_name, is_file=False)
            if new_base_name != base_name:
                new_target_path = os.path.join(parent_dir, new_base_name)
                all_rename_ops.append((target_path, new_target_path))

    if not all_rename_ops:
        print("No items need renaming.")
        return

    # Sort by depth (longest paths first) to ensure bottom-up logic
    all_rename_ops.sort(key=lambda x: x[0].count(os.sep), reverse=True)

    print(f"\nProposed changes ({len(all_rename_ops)} items):")
    for old, new in all_rename_ops:
        print(f"  {os.path.relpath(old, target_path)} -> {os.path.basename(new)}")

    confirm = input("\nProceed with renaming? (y/N): ").lower().strip()
    if confirm != 'y':
        print("Aborted.")
        return

    print(f"Renaming {len(all_rename_ops)} items...")
    
    for old, new in all_rename_ops:
        if os.path.exists(new):
            print(f"SKIP (Collision): {new} already exists.")
            continue
            
        try:
            os.rename(old, new)
            print(f"RENAMED: {old} -> {new}")
        except Exception as e:
            print(f"ERROR renaming {old}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_path = os.path.abspath(sys.argv[1])
    else:
        target_path = os.getcwd()
    
    process_path(target_path)
