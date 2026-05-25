import std.stdio;
import std.string;
import std.format;
import scriptlike.only;
import cmd.program;
import colorize : fg, color, cwriteln, cwritefln;
import requests;
import toml;
import std.process;

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
			writeln("test" ~ " tes 2t" ~ "test3");
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
			tryMkdir("/tmp/kpkg"); // "Just MAKE SURE this exists! If it's already there, then GREAT!" - scriptlike library README
			auto defaultpath = environment.get("KPDIR", "/usr/local/bin");
			cwriteln("cloning package...".color(fg.yellow));
			string src = PBI["package"]["source"].toString();
			string cmmd = PBI["package"]["command"].toString();
			string finalbinal = PBI["package"]["finbin"].toString();
			string pkgn = PBI["meta"]["name"].toString();
			tryRemovePath("/tmp/kpkg");
			run(format("git clone %s /tmp/kpkg", strip(src, "\u0022")));
			run(format("cd /tmp/kpkg && %s ", strip(cmmd, "\u0022")));
			int finalcmd = tryRun(format("mv /tmp/kpkg/%s /usr/local/bin/%s", strip(finalbinal, "\u0022"), strip(pkgn, "\u0022")));
			// if ANY of these fail the program dies
			tryRemovePath("/tmp/kpkg"); // less scary
			if (finalcmd == 0)
			{
				cwriteln("program installed succesfully!".color(fg.green));
				asking = userInput("would you like to generate a .desktop file?");
				switch (asking)
				{

				case "n":
					cwriteln("will not make .desktop");
					exit = 1;
					break;
				case "no":
					cwriteln("will not make .desktop");
					exit = 1;
					break;
				case "yes":
					cwriteln("making .desktop");
					break;
				case "y":
					cwriteln("making .desktop");
					break;
				default:
					cwriteln("response not y or n, will not make .desktop");
					exit = 1;
					break;
				}
				if (exit = 1)
				{
					writeln("bye!");
				}
				else
				{
					writeln("make the desktop file actually");
				}
			}
			else
			{
				cwriteln("Program installation failed! are you running as sudo?".color(fg.red));
			}

		}

	}

}
