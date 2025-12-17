
Linux File Permissions — Quick Reference

Numeric → Symbolic mappings (common):

777  — -rwxrwxrwx  (u=rwx,g=rwx,o=rwx)
755  — -rwxr-xr-x  (u=rwx,g=rx,o=rx)
750  — -rwxr-x---  (u=rwx,g=rx,o=)
700  — -rwx------  (u=rwx,g=,o=)
644  — -rw-r--r--  (u=rw,g=r,o=r)
640  — -rw-r-----  (u=rw,g=r,o=)
600  — -rw-------  (u=rw,g=,o=)
444  — -r--r--r--  (u=r,g=r,o=r)
400  — -r--------  (u=r,g=,o=)
000  — ----------  (u=,g=,o=)

Special/common with set bits:
4755 — setuid + 755  (s in owner execute: setuid, e.g. executable runs as owner)
2755 — setgid + 755  (s in group execute: new files inherit group)
1777 — sticky + 777  (t on others execute: sticky bit on shared dirs)

How to read `ls -l` output:

	- First char: file type (`-` regular, `d` directory, `l` symlink)
	- Next 9 chars: three triples for user/group/other: `r` read, `w` write, `x` execute
	- Example: `-rwxr-xr-x 1 user group 1234 Jan 1 file` → owner has rwx, group rx, others rx

How to set permissions:

	- Numeric (fast): `chmod 755 filename`
	- Symbolic: `chmod u=rwx,g=rx,o=rx filename` or `chmod a+r filename`
	- Add/remove bits: `chmod g-w filename` or `chmod o+x filename`
	- Recursive: `chmod -R 750 somedir`

Setuid/setgid/sticky examples:

	- Setuid (owner's privileges on exec): `chmod 4755 /path/to/program`
	- Setgid (group inheritance on dirs): `chmod 2755 /path/to/dir` or `chmod g+s /path/to/dir`
	- Sticky (shared tmp dirs): `chmod 1777 /path/to/dir`

Ownership and groups:

	- Change owner: `chown user file`
	- Change owner and group: `chown user:group file`
	- Change group only: `chgrp group file`

Quick usage tips:

	- Always backup important files before mass changes.
	- Use `stat filename` for detailed permission bits and numeric mode.
	- For directories: execute (`x`) allows entering the directory; read (`r`) lists names.
	- Prefer least privilege: give only needed permissions (e.g., 644 for config files, 700 for private keys).

