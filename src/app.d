import std.stdio; // 500 imports
import std.string;
import std.format;
import scriptlike.only;
import cmd.program;
import colorize : fg, color, cwriteln, cwritefln;
import requests;
import toml;
import std.process;
import std.conv;
import std.range;
import std.algorithm;
import std.file;

TOMLDocument PBI;
TOMLDocument PBIB;
string conteent;
string[] repochoice;
string[] repoconch;
string uprepo;
string src;
string pkgn;
int finalcmd;
int pkgt;
float pkgv;
string cmmd;
string finalbinal;
// * 「「知らず」を知らず」を知らず 



void main(string[] argv)
{
	int exit = 0;
	string asking = "dfv";
	auto args = new Program("KelPKG")
		.description("kelps funny package manager")
		.versionString("0.2.0")
		.versionOption("--version", "show version")
		.helpOption("-h, --help", "show help message(s)")
		.option("-i, --install", "install a package")
		.option("-r, --remove", "remove / uninstall a package")
		.option("-l, --list", "list packages within packagelist")
		.option("-o, --locinstall", "install a package from a .kpkg.toml file")
		.option("-a, --ask", "ask when doing things")
		.option("-u, --update", "update packages within packagelist")
		.argument("[package]", "Package to install/remove")
		.parse(argv);
	if (args.hasFlag("install"))

	{
		if (scriptlike.file.exists("/etc/kpkg/repos"))
		{
			auto repos = File("/etc/kpkg/repos");
			auto repolist = repos.byLine(); // # todo DONE!
			string packag = args.argument("package");
			foreach (line; repolist)
			{
				conteent = getContent(format(line, "meta")).toString();
				PBIB = parseTOML(conteent);
				string packagefound = PBIB["provides"].toString();
				if (canFind(packagefound, packag)) {
					repoconch ~= PBIB["url"].toString();
					repochoice ~= PBIB["rname"].toString();
				}
				
			}
			int repopo = menu!int("which repo do you wish to use?", repochoice);

			string urlrl = repoconch[repopo - 1];
			PBI = parseTOML(getContent(format(strip(urlrl, "\u0022"), packag)).toString());
			writeln(format("installing %s", PBI["meta"]["name"].toString()));
		}
		else
		{
			cwriteln("/etc/kpkg/repos does not exist!".color(fg.red));
			exit = 1;
		}
		string suudooo = runCollect("id -u");
		if (strip(suudooo) == "0")
		{
			writeln("wow!"); // i really need a better way to do this...
		}
		else
		{
			cwriteln("Not running as root! package will not be installed!".color(fg.red));
			exit = 1;
		}

		if (args.hasFlag("ask"))
		{
			asking = userInput("proceed with program installation? (y/n)");
			switch (asking)
			{

			case "n":
				cwriteln("canceling installation".color(fg.red)); //fancy!
				exit = 1;
				break;
			case "no":
				cwriteln("canceling installation".color(fg.red));
				exit = 1;
				break;
			case "yes":
				cwriteln("continuing installation".color(fg.green));
				break;
			case "y":
				cwriteln("continuing installation".color(fg.green));
				break;
			default:
				cwriteln("response not y or n, canceling installation".color(fg.red));
				exit = 1;
				break;
			}
		}
		if (exit == 1)
		{
			writeln("bye!");
		}
		else
		{
			//writing the main of the installation command in an else! wow! 
			cwriteln("cloning package...".color(fg.yellow));
			src = PBI["package"]["source"].toString();
			pkgn = PBI["meta"]["name"].toString();
			tryRemovePath("/tmp/kpkg");
			pkgt = cast(int) PBI["meta"]["pkgt"].integer; // for some reason, it defaults to a long
			pkgv = PBI["meta"]["version"].floating;
			cmmd = PBI["package"]["command"].toString();
			finalbinal = PBI["package"]["finbin"].toString();
			switch (pkgt)
			{
			case 0:

				run(format("git clone %s /tmp/kpkg", strip(src, "\u0022")));
				run(format("cd /tmp/kpkg && %s ", strip(cmmd, "\u0022")));
				finalcmd = tryRun(format("mv /tmp/kpkg/%s /usr/local/bin/%s", strip(finalbinal, "\u0022"), strip(
						pkgn, "\u0022")));
				// if ANY of these fail the program dies
				tryRemovePath("/tmp/kpkg"); // less scary

				break;
			case 1:
				run(format("cd /tmp && wget %s", strip(src, "\u0022")));
				run(format("cd /tmp && tar -xvzf %s", strip(cmmd, "\u0022"))); // todo: add support for tar.xz as well
				finalcmd = tryRun(format("mv /tmp/%s /usr/local/bin/", strip(finalbinal, "\u0022")));
				break;
			case 2:
				run(strip(cmmd, "\u0022"));
				break;
			case 3: //i  no longer plan to handle libraries because i dont know how to
				cwriteln("the package is broken and will not be installed".color(fg.red));
				break;
			default:
				cwriteln("invalid package type".color(fg.red));
				break;

			}

			if (finalcmd == 0)
			{
				cwriteln("program installed succesfully!".color(fg.green));
				File packlist = File("/etc/kpkg/packagelist", "a+");
				packlist.writeln(format("%s-%s", strip(pkgn, "\u0022"), pkgv));
			}
			else
			{
				cwriteln("Program installation failed! are you running as sudo?".color(fg.red));
			}

		}

	}
	if (args.hasFlag("list")) {
		if (scriptlike.file.exists("/etc/kpkg/packagelist")) {
			writeln(scriptlike.file.readText("/etc/kpkg/packagelist")); //somehow, this takes slightly less lines of code than the nim version
		}
		else {
			cwriteln("packagelist does not exist which means you dont have any packages!".color(fg.red));
		}
	}
	if (args.hasFlag("locinstall"))

	{

		string packag = args.argument("package");

		PBI = parseTOML(readText(Path(packag)));
		writeln(format("installing %s", [
					PBI["meta"]["name"], PBI["meta"]["version"]
				]));
		string suudooo = runCollect("id -u");
		if (strip(suudooo) == "0")
		{
			writeln("wow!"); // i really need a better way to do this...
		}
		else
		{
			cwriteln("Not running as root! package will not be installed!".color(fg.red));
			exit = 1;
		}

		if (args.hasFlag("ask"))
		{
			asking = userInput("proceed with program installation? (y/n)");
			switch (asking)
			{

			case "n":
				cwriteln("canceling installation".color(fg.red)); //fancy!
				exit = 1;
				break;
			case "no":
				cwriteln("canceling installation".color(fg.red));
				exit = 1;
				break;
			case "yes":
				cwriteln("continuing installation".color(fg.green));
				break;
			case "y":
				cwriteln("continuing installation".color(fg.green));
				break;
			default:
				cwriteln("response not y or n, canceling installation".color(fg.red));
				exit = 1;
				break;
			}
		}
		if (exit == 1)
		{
			writeln("bye!");
		}
		else
		{
			auto defaultpath = environment.get("KPDIR", "/usr/local/bin"); 
			cwriteln("cloning package...".color(fg.yellow));
			src = PBI["package"]["source"].toString();
			pkgn = PBI["meta"]["name"].toString();
			tryRemovePath("/tmp/kpkg");
			pkgt = cast(int) PBI["meta"]["pkgt"].integer; 
			pkgv = PBI["meta"]["version"].floating;
			cmmd = PBI["package"]["command"].toString();
			finalbinal = PBI["package"]["finbin"].toString();
			switch (pkgt)
			{
			case 0:

				run(format("git clone %s /tmp/kpkg", strip(src, "\u0022")));
				run(format("cd /tmp/kpkg && %s ", strip(cmmd, "\u0022")));
				finalcmd = tryRun(format("mv /tmp/kpkg/%s /usr/local/bin/%s", strip(finalbinal, "\u0022"), strip(
						pkgn, "\u0022")));
				tryRemovePath("/tmp/kpkg"); 

				break;
			case 1:
				run(format("cd /tmp && wget %s", strip(src, "\u0022")));
				run(format("cd /tmp && tar -xvzf %s", strip(cmmd, "\u0022"))); 
				finalcmd = tryRun(format("mv /tmp/%s /usr/local/bin/", strip(finalbinal, "\u0022"))); // need to figure out a way to get this to work for packages with multiple binaries...
				break;
			case 4:
				run(strip(cmmd, "\u0022"));
				break;
			case 5:
				cwriteln("the package is broken and will not be installed".color(fg.red));
				break;
			default:
				cwriteln("invalid package type".color(fg.red));
				break;

			}

			if (finalcmd == 0)
			{
				cwriteln("program installed succesfully!".color(fg.green));
				File packlist = File("/etc/kpkg/packagelist", "a+");
				packlist.writeln(format("%s-%s", strip(pkgn, "\u0022"), pkgv));
			}
			else
			{
				cwriteln("Program installation failed!".color(fg.red));
			}

		}
	}
	if (args.hasFlag("remove")) {
		string packoge = strip(args.argument("package"), "\u0022");
		string suudooo = runCollect("id -u");
		if (strip(suudooo) == "0")
		{
			writeln("wow!"); // i really need a better way to do this...
		}
		else
		{
			cwriteln("Not running as root! package will not be installed!".color(fg.red));
			exit = 1;
		}
		if (args.hasFlag("ask"))
		{
			asking = userInput("proceed with program removal? (y/n)");
			switch (asking)
			{

			case "n":
				cwriteln("canceling removal".color(fg.red)); 
				exit = 1;
				break;
			case "no":
				cwriteln("canceling removal".color(fg.red));
				exit = 1;
				break;
			case "yes":
				cwriteln("continuing removal".color(fg.green));
				break;
			case "y":
				cwriteln("continuing removal".color(fg.green));
				break;
			default:
				cwriteln("response not y or n, canceling removal".color(fg.red));
				exit = 1;
				break;
			}
		}	
		if (exit == 1) {
			cwriteln("exiting...");
		} else {
		tryRemove(format("/usr/local/bin/%s", packoge));
		cwriteln("program removed succesfully!".color(fg.green)); // this is honestly quite rediculous just to remove ONE ITEM from an array when in the nim version it took like, two lines
		string packlist = scriptlike.file.readText("/etc/kpkg/packagelist");
		auto pakclist = packlist.splitter('\n').array;
		string[string] semfinpck = abbrev(pakclist);
		string finpck = semfinpck[packoge];  // spent an hour wondering why this gave me range violation errors only to realize i didnt have the package i was testing with installed
		auto toremove = countUntil(pakclist ,finpck);
		pakclist = pakclist.remove(toremove);
		File pcklist = File("/etc/kpkg/packagelist", "w");
		pcklist.write(join(pakclist, "\n"));

		
		}

	}

	if (args.hasFlag("update"))
	{
		if (scriptlike.file.exists("/etc/kpkg/packagelist")) {
			if (scriptlike.file.exists("/etc/kpkg/repos")) {
				auto repos = File("/etc/kpkg/repos");
				auto packagelist = File("/etc/kpkg/packagelist");
				auto packagelistByLine = packagelist.byLine();
				auto reposByLine = repos.byLine();
				if (exit == 1 ) {
					writeln("exiting...");
				} else {
					foreach (line; packagelistByLine) {
						foreach (lint; reposByLine) {
							conteent = getContent(format(lint, "meta")).toString();
							writeln(conteent);
							PBIB = parseTOML(conteent);
							string packagefound = PBIB["provides"].toString();
							if (canFind(packagefound, line.strip("0123456789.-"))) {
								uprepo = PBIB["url"].toString();
								break;
							}
						}
						PBI = parseTOML(getContent(format(strip(uprepo, "\u0022"), line.strip("01234565789.-"))).toString());
						writeln(format("installing %s", PBI["meta"]["name"]));
						cwriteln("cloning package...".color(fg.yellow));
						src = PBI["package"]["source"].toString();
						pkgn = PBI["meta"]["name"].toString();
						tryRemovePath("/tmp/kpkg");

						pkgt = cast(int) PBI["meta"]["pkgt"].integer;

						pkgv = PBI["meta"]["version"].floating;
						cmmd = PBI["package"]["command"].toString();
						finalbinal = PBI["package"]["finbin"].toString();
						switch (pkgt) {
							case 0:
								run(format("git clone %s /tmp/kpkg", strip(src, "\u0022")));
								run(format("cd /tmp/kpkg && %s ", strip(cmmd, "\u0022")));
								finalcmd = tryRun(format("mv /tmp/kpkg/%s /usr/local/bin/%s", strip(finalbinal, "\u0022"), strip(
									pkgn, "\u0022")));
								// if ANY of these fail the program dies
								tryRemovePath("/tmp/kpkg"); // less scary

								break;
							case 1:
								run(format("cd /tmp && wget %s", strip(src, "\u0022")));
								run(format("cd /tmp && tar -xvzf %s", strip(cmmd, "\u0022"))); // todo: add support for tar.xz as well
								finalcmd = tryRun(format("mv /tmp/%s /usr/local/bin/", strip(finalbinal, "\u0022")));
								break;
							case 2:
								run(strip(cmmd, "\u0022"));
								break;
							case 3:
								cwriteln("the package is broken and will not be installed".color(fg.red));
								break;
							default:
								cwriteln("invalid package type".color(fg.red));
								break;		
						}

						if (finalcmd == 0)
						{
							cwriteln("program installed succesfully!".color(fg.green));
							repoconch ~= format("%s-%s", strip(pkgn, "\u0022"), pkgv);
						}
						else
						{
							cwriteln("Program installation failed! are you running as sudo?".color(fg.red));
						}

					}
					File pcklist = File("/etc/kpkg/packagelist", "w");
					pcklist.write(join(repoconch, "\n"));
				}
			}
		}
			
	}
}


