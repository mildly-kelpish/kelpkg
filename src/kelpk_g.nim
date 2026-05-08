import commandant, strformat, std/os# i love commandant !
let version: string = "0.1.0"
proc helpMessage(): string =
  result = """
  kelpkg package manager
  Usage: kpkg <command> 
  Available commands: 
  help - prints a this help message and exits
  install - installs a package (provided as argument)
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


echo(fmt"KELPKG {version}")
echo("we are not responsible for any damages to your pc!")

if install:
  echo("working on it i need my priorities")




