
<h2 align="center"><b>kelpkg</b><br></h2>

Kelpkg (or kpkg) is a fairly simple package manager i made in about 18 hours. still incredibly wip and you very much should not use it. the main repo can be found at  https://github.com/mildly-kelpish/kelpkg-repo-main  
currently being rewritten in d

---
## usage

while it is usable i dont reccomend using it that much since most everything you could probably just get from whatever linux repo you normally use's package manager

anyway heres the commands
`--help / -h | prints a help message and exits`<br>
`--install / -i | installs a package to ~/.kelpkg or KPDIR envvar (provided as argument)`<br>
`--list / -l | lists packagelist (see config)`<br>
`--delete / -d |  deletes package (provided as argument)`<br>
`--locinstall / -o | installs a package from a file (remember to put your file extensions in!)`<br>
`--update / -u | not currently implemented`<br>


also note that there are only things packaged for linux in the main repo!

## installation
- a prebuilt binary for Linux x86_64 can be found in the releases tab

### building
should be as easy as just `dub build` in the cloned repo
