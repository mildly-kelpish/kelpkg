import std.stdio;
import std.string;
import std.format;
import scriptlike.only;
import cmd.program;
import colorize : fg, color, cwriteln, cwritefln;
import requests;
import toml;
import std.process;
import std.conv;

TOMLDocument PBI;

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
		.option("-u, --remove", "remove / uninstall a package")
		.option("-l, --list", "list packages within packagelist")
		.option("-o, --locinstall", "install a package from a .kpkg.toml file")
		.option("-a, --ask", "ask when installing/removing packages")
		.argument("[package]", "Package to install/remove")
		.parse(argv);
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
	if (args.hasFlag("install"))
	{
		string packag = args.argument("package");
		string conteent = getContent(
			format(
				"https://raw.githubusercontent.com/mildly-kelpish/kelpkg-repo-main/refs/heads/main/%s.toml", packag))
			.toString();
		PBI = parseTOML(conteent);
		cwriteln(format("installing %(%sv%)...", [
					PBI["meta"]["name"], PBI["meta"]["version"]
				]));

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
			//local bin for distroless, normal bin otherwise
			tryMkdir("/etc/kpkg"); // "Just MAKE SURE this exists! If it's already there, then GREAT!" - scriptlike library README
			auto defaultpath = environment.get("KPDIR", "/usr/local/bin");
			cwriteln("cloning package...".color(fg.yellow));
			string src = PBI["package"]["source"].toString();
			string pkgn = PBI["meta"]["name"].toString();
			tryRemovePath("/tmp/kpkg");
			int pkgt = cast(int) PBI["meta"]["pkgt"].integer; // for some reason, it defaults to a long
			int finalcmd;
			string cmmd = PBI["package"]["command"].toString();
			string finalbinal = PBI["package"]["finbin"].toString();
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
				finalcmd = tryRun(format("mv /tmp/%s /usr/local/bin/", strip(finalbinal, "\u0022"))); // age is currently the only binary package and has multiple binaries, this should work fine
				break;
			case 2:
				writeln(format("temp"));
				break;
			case 3:
				writeln(format("temp"));
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
			}
			else
			{
				cwriteln("Program installation failed! are you running as sudo?".color(fg.red));
			}

		}

	}

}
