const version: string = "0.1.1"
import commandant, strformat, std/os, parsetoml, std/httpclient, std/strutils, std/sequtils, std/envvars
proc helpMessage(): string =
  result = """
  kelpkg user package manager
  Usage: kpkg <command> 
  Available commands: 
  help - prints a this help message and exits
  install - installs a package to ~/.kelpkg or KPDIR envvar (provided as argument)
  list - lists packagelist (see config)
  delete - deletes package (provided as argument)
  locinstall - installs a package from a file (remember to put your file extensions in!)
  """
commandline:
  exitoption("help", "h", helpMessage())
  subcommand install, "install", "i":
    argument(package, string)
  flag(lissst, "list", "l")
  subcommand delete, "delete", "d":
    argument(pckage, string) # nim got mad at me for declaring a variable thrice so guess il have to do with this
    flag(force, "force", "f")
  subcommand installocal, "locinstall", "o":
    argument(packge, string)
  flag(update, "update", "u")



echo(fmt"KELPKG {version}")
echo("we are not responsible for any damages to your pc!")
echo("note: dependencies are NOT handled by kelpkg")

#better gaps between segments mean better readable code

# maybe add the ability to have other repos? i dont know how though everything ive tried has failed




if install:
  var client = newHttpClient()
  try:
    var pbi = parsetoml.parseString(client.getContent(fmt"https://raw.githubusercontent.com/mildly-kelpish/kelpkg-repo-main/refs/heads/main/{package}.toml"))
    #errors dont kill you anymore!
    echo("got package build instructions succesfully i think")
    var pbis = pbi["package"]["source"].getStr()
    var pbib = pbi["package"]["command"].getStr()
    var pbin = pbi["package"]["finbin"].getStr()
    var pbiv = pbi["meta"]["version"].getFloat()
    echo(&"would you like to install {package} {pbiv} from {pbis} (y/n) >")
    var defaultpah = expandTilde("~/.config/kelpkg")  
    var defaultpat = expandTilde("~/.kelpkg")
    var confirmation = readline(stdin)
    if confirmation == "y":
      discard execShellCmd(fmt"git clone {pbis} /tmp/{package}")  
      discard execShellCmd(fmt"cd /tmp/{package} && {pbib}")
      if existsEnv("KPDIR"):
        ## ! kpdir stuff here !
        defaultpat = getEnv("KPDIR")
      else:  
        if dirExists(defaultpat):
          echo("default install dir exists and 'KPDIR' is not defined, moving binary...")
          
        else:
          discard execShellCmd(fmt"mkdir {defaultpat}")
          echo("i reccommend adding /home/{user}/.kelpkg/ to PATH OR setting the environment variable 'KPDIR' to a different path\nthat is also on your PATH, that can also be written to without sudo")
      discard execShellCmd(fmt"mv /tmp/{package}/{pbin} {defaultpat}/{package}")
      echo(fmt"{package} installed to {defaultpat}/{package}")
        
      if dirExists(defaultpah):
        echo("config dir exists, writing to package list...")
      else:
        discard execShellCmd(fmt"mkdir {defaultpah}")
      if fileExists(fmt"{defaultpah}/packagelist"):
        ## ! package list writing here !
        let unsplit = readFile(fmt"{defaultpah}/packagelist")
        var splilt = splitlines(unsplit)
        splilt.insert(fmt"{package}-{pbiv}", 0)
        var spilt = deduplicate(splilt)
        var final = join(spilt, "\n")

        writeFile(fmt"{defaultpah}/packagelist", final)
        echo("Package installed succesfullly!")
      else:
        echo("packagelist does not exist, making packagelist...")
        writeFile(fmt"{defaultpah}/packagelist.txt", fmt"{package}-{pbiv}")  
        echo("Package installed succesfullly!")
    else:
      echo("package installation canceled")      

  except:
    stderr.writeLine(getCurrentExceptionMsg())
  finally:
    echo("closing http client...")
    client.close()      








if lissst: 
  var defaultpah = expandTilde("~/.config/kelpkg")  
  if dirExists(defaultpah):
    echo("config dir exists, reading package list...")
    if fileExists(fmt"{defaultpah}/packagelist"):
        let pkgl = readFile(fmt"{defaultpah}/packagelist")
        echo(pkgl)
    else:
      echo("packagelist does not exist!")
  else:
    echo("config dir does not exist and as such the packagelist does not")







if delete:
  var defaultpah = expandTilde("~/.config/kelpkg")
  var defaultpat = expandTilde("~/.kelpkg") 
  if force:
    if existsEnv("KPDIR"):
      defaultpat = getEnv("KPDIR")    
    echo("force passed, deleting package without modifying packagelist")
    removeFile(fmt"{defaultpat}/{pckage}")
  else:  
    echo(fmt"would you like to delete {pckage} (y\n) >")
    var confirmation = readline(stdin)
    if confirmation == "y":
      if existsEnv("KPDIR"):
        defaultpat = getEnv("KPDIR")      
      if dirExists(defaultpah):
        echo("config dir exists, reading package list...")

        if fileExists(fmt"{defaultpah}/packagelist"):
          let unspliit = readFile(fmt"{defaultpah}/packagelist")
          var spliit = splitLines(unspliit)
          try:
            let removeer = abbrev(pckage, spliit)
            spliit.delete(removeer..removeer)
            var final = join(spliit, "\n")
            writeFile(fmt"{defaultpah}/packagelist", final)
      

            removeFile(fmt"{defaultpat}/{pckage}")
            echo("package deleted successfully!")
          except:
            echo("something went wrong in modifying the packagelist, pass --force to skip packagelist checking")  
        else:
          echo("packagelist does not exist!")
      else:
        echo("config dir does not exist and as such the packagelist does not")
    else:
      echo("package deletion canceled")   








# fun fact! update is originally based off of the delete command  


if update:
  var defaultpah = expandTilde("~/.config/kelpkg")
  var defaultpat = expandTilde("~/.kelpkg") 
  echo(fmt"would you like to update/install all packages within your packagelist (y\n) >")
  var confirmation = readline(stdin)
  if confirmation == "y":

    if dirExists(defaultpah):
      echo("config dir exists, reading package list...")

      if fileExists(fmt"{defaultpah}/packagelist"):
        var client = newHttpClient()
        let unspliit = readFile(fmt"{defaultpah}/packagelist")
        var spliit = splitLines(unspliit)
        for i in spliit:
          if i == "":
            echo("updating")
          else:  
            try:
              var tempv = i.split('-') # 500 mutable variables
              var tempest = tempv[0]
              var verison = parseFloat(tempv[1])
              var pbi = parsetoml.parseString(client.getContent(fmt"https://raw.githubusercontent.com/mildly-kelpish/kelpkg-repo-main/refs/heads/main/{tempest}.toml"))
              var pbis = pbi["package"]["source"].getStr()
              echo(pbis)
              var pbib = pbi["package"]["command"].getStr()
              var pbin = pbi["package"]["finbin"].getStr()
              var pbiv = pbi["meta"]["version"].getFloat()
              if pbiv > verison:
                discard execShellCmd(fmt"git clone {pbis} /tmp/{tempest}")  
                discard execShellCmd(fmt"cd /tmp/{tempest} && {pbib}")
                if existsEnv("KPDIR"):
                  echo("install to kpdir env")
                  defaultpat = getEnv("KPDIR")
                else:  
                  if dirExists(defaultpat):
                    echo("default install dir exists and 'KPDIR' is not defined, moving binary...")
                  else:
                    discard execShellCmd(fmt"mkdir {defaultpat}")
                    echo("i reccommend adding /home/{user}/.kelpkg/ to PATH OR setting the environment variable 'KPDIR' to a different path\nthat is also on your PATH, that can also be written to without sudo")
                discard execShellCmd(fmt"mv /tmp/{tempest}/{pbin} {defaultpat}/{tempest}")
                echo(fmt"{tempest} installed to {defaultpat}/{tempest}")
        
                if dirExists(defaultpah):
                  echo("config dir exists, writing to package list...")
                else:
                  discard execShellCmd(fmt"mkdir {defaultpah}")
                if fileExists(fmt"{defaultpah}/packagelist"):
                  #!package list writing here!
                  var spliot = splitLines(unspliit)
                  try:
                    let removeer = abbrev(tempest, spliot)
                    spliot.delete(removeer..removeer)
                    spliot.insert(fmt"{tempest}-{pbiv}", 0)
                    var final = join(spliot, "\n")
                    writeFile(fmt"{defaultpah}/packagelist", final)
                    echo("package updated successfully!")
                  except:
                    echo("something went wrong")  

            except:
              stderr.writeLine(getCurrentExceptionMsg())
            finally:
              client.close()    

      else:
          echo("packagelist does not exist!")
    else:
          echo("config dir does not exist and as such the packagelist does not")
  else:
    echo("package updating canceled")   


if installocal:
  var pbi = parsetoml.parseFile(packge)
  #errors dont kill you anymore!
  echo("got package build instructions succesfully i think")
  var pbis = pbi["package"]["source"].getStr()
  var pbib = pbi["package"]["command"].getStr()
  var pbin = pbi["package"]["finbin"].getStr()
  var pbiv = pbi["meta"]["version"].getFloat()
  var pbina = pbi["meta"]["name"].getStr()
  echo(&"would you like to install {pbina} {pbiv} from {pbis} (y/n) >")
  var defaultpah = expandTilde("~/.config/kelpkg")  
  var defaultpat = expandTilde("~/.kelpkg")
  var confirmation = readline(stdin)
  if confirmation == "y":
    discard execShellCmd(fmt"git clone {pbis} /tmp/{pbina}")  
    discard execShellCmd(fmt"cd /tmp/{pbina} && {pbib}")
    if existsEnv("KPDIR"):
        echo("install to kpdir env")
        defaultpat = getEnv("KPDIR")
    else:  
        if dirExists(defaultpat):
          echo("default install dir exists and 'KPDIR' is not defined, moving binary...")
        else:
          discard execShellCmd(fmt"mkdir {defaultpat}")
          echo("i reccommend adding /home/{user}/.kelpkg/ to PATH OR setting the environment variable 'KPDIR' to a different path\nthat is also on your PATH, that can also be written to without sudo")
    discard execShellCmd(fmt"mv /tmp/{pbina}/{pbin} {defaultpat}/{pbina}")
    echo(fmt"{pbina} installed to {defaultpat}/{pbina}")
      
    if dirExists(defaultpah):
      echo("config dir exists, writing to package list...")
    else:
      discard execShellCmd(fmt"mkdir {defaultpah}")
    if fileExists(fmt"{defaultpah}/packagelist"):
      #!package list writing here here!
      let unsplit = readFile(fmt"{defaultpah}/packagelist")
      var splilt = splitlines(unsplit)
      splilt.insert(fmt"{pbina}-{pbiv}", 0)
      var spilt = deduplicate(splilt)
      var final = join(spilt, "\n")

      writeFile(fmt"{defaultpah}/packagelist", final)
      echo("package installed succesfully!")
  else:
    echo("package installation canceled")      

