import commandant, strformat, std/os, parsetoml, std/envvars, std/httpclient
let version: string = "0.1.0"
proc helpMessage(): string =
  result = """
  kelpkg user package manager
  Usage: kpkg <command> 
  Available commands: 
  help - prints a this help message and exits
  install - installs a package to ~/.kelpkg or KPDIR envvar (provided as argument)
  list - lists packagelist (see config)
  """
commandline:
  exitoption("help", "h", helpMessage())
  subcommand install, "install", "i":
    argument(package, string)
  flag(lissst, "list", "l")
  subcommand delete, "delete", "d":
    argument(pckage, string) # nim extension got mad at me for declaring a variable thrice so guess il have to do with this
  subcommand installocal, "locinstall", "l":
    argument(packge, string)
  flag(update, "update", "u")

# todo: figure out how to handle dependencies   i think

echo(fmt"KELPKG {version}")
echo("we are not responsible for any damages to your pc!")

if install:
  var client = newHttpClient()
  try:
    var pbi = parsetoml.parseString(client.getContent(fmt"https://raw.githubusercontent.com/mildly-kelpish/kelpkg-repo-main/refs/heads/main/{package}.toml"))
    #errors dont kill you anymore!
    echo("got package build instructions succesfully i think")
    var pbis = pbi["package"]["source"].getStr()
    var pbib = pbi["package"]["command"].getStr()
    var pbin = pbi["package"]["finbin"].getStr()
    discard execShellCmd(fmt"git clone {pbis} /tmp/{package}")  
    discard execShellCmd(fmt"cd /tmp/{package} && {pbib}")
    if existsEnv("KPDIR"):
      var dire = getEnv("KPDIR")
      discard execShellCmd(fmt"mv /tmp/{package}/{pbin} {dire}/{package}")
    else:
      var defaultpat = expandTilde("~/.kelpkg") 
      if dirExists(defaultpat):
        echo("default install dir exists and 'KPDIR' is not defined, moving binary...")
      else:
        discard execShellCmd(fmt"mkdir {defaultpat}")
        echo("i reccommend adding /home/{user}/.kelpkg/ to PATH OR setting the environment variable 'KPDIR' to a different path\nthat is also on your PATH, that can also be written to without sudo")
      discard execShellCmd(fmt"mv /tmp/{package}/{pbin} ~/.kelpkg/{package}")
      echo(fmt"{package} installed to ~/.kelpkg/{package}")
      var defaultpah = expandTilde("~/.config/kelpkg")  
      if dirExists(defaultpah):
        echo("config dir exists, writing to package list...")
      else:
        discard execShellCmd(fmt"mkdir {defaultpah}")
      if fileExists(fmt"{defaultpah}/packagelist.txt"):
        let pkgl = open(fmt"{defaultpah}/packagelist.txt")
        pkgl.writeline(package)
        pkgl.close()
      else:
        echo("packagelist does not exist, making packagelist...")
        writeFile(fmt"{defaultpah}/packagelist.txt", package)

  except:
    echo("well, something failed somewhere, likely in the getting of the package build instructions, sorry!")
  finally:
    echo("closing http client...")
    client.close()      

if lissst: 
  var defaultpah = expandTilde("~/.config/kelpkg")  
  if dirExists(defaultpah):
    echo("config dir exists, reading package list...")
    if fileExists(fmt"{defaultpah}/packagelist.txt"):
        let pkgl = readFile(fmt"{defaultpah}/packagelist.txt")
        echo(pkgl)
    else:
      echo("packagelist does not exist!")
  else:
    echo("config dir does not exist and as such the packagelist does not")
if delete:
  var defaultpah = expandTilde("~/.config/kelpkg")  
  if dirExists(defaultpah):
    echo("config dir exists, reading package list...")
    var defaultpat = expandTilde("~/.kelpkg") 
    if fileExists(fmt"{defaultpah}/packagelist.txt"):
      echo("i dont actually know how to remove one specific string and line so just go into your packagelist and delete it please thank you")
      removeFile(fmt"{defaultpat}/{pckage}")
    else:
      echo("packagelist does not exist!")
  else:
    echo("config dir does not exist and as such the packagelist does not")
if installocal:
  # actually make this later, im taking a break now
  echo("temp")    
  
