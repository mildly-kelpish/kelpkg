
<h2 align="center"><b>kelpkg</b><br></h2>

Kelpkg (or kpkg) is a fairly simple package manager i made in about 7 hours. main "unique" feature about it is that it writes down every package you have to a file (~/.config/kelpkg/packagelist). the main repo can be found at  https://github.com/mildly-kelpish/kelpkg-repo-main

---
## usage

while it is usable i dont reccomend using it that much since most everything you could probably just get from whatever linux repo you normally use's package manager

anyway heres the commands
`--help / -h | prints a help message and exits`<br>
`--install / -i | installs a package to ~/.kelpkg or KPDIR envvar (provided as argument)`<br>
`--list / -l | lists packagelist (see config)`<br>
`--delete / -d |  deletes package (provided as argument)`<br>
`--locinstall / -o | installs a package from a file (remember to put your file extensions in!)`<br>
`--update / -u | updates / installs all packages within your packagelist`<br>


also note that there are only things packaged for linux in the main repo!

## installation
- a prebuilt binary for Linux x86_64 can be found in the releases tab

### building
- install [nim](https://nim-lang.org/)
- `git clone https://github.com/mildly-kelpish/kelpkg/`
- `cd kelpkg`
- `nim sync` and then `nim build -D:ssl` (do not forget the -D:ssl! its important!)
