using Spectre.Console;

class CLI 
{

    public static string CoolLogo = @"  
  888b    888 d8b          d8b  .d8888b.  888               888 888 
  8888b   888 Y8P          Y8P d88P  Y88b 888               888 888 
  88888b  888                  Y88b.      888               888 888 
  888Y88b 888 888 88888b.  888  'Y888b.   88888b.   .d88b.  888 888 
  888 Y88b888 888 888 '88b 888     'Y88b. 888 '88b d8P  Y8b 888 888 
  888  Y88888 888 888  888 888       '888 888  888 88888888 888 888 
  888   Y8888 888 888  888 888 Y88b  d88P 888  888 Y8b.     888 888 
  888    Y888 888 888  888 888  'Y8888P'  888  888  'Y8888  888 888

";

    public void Show()
    {
        AnsiConsole.Markup($"[purple]{CLI.CoolLogo}[/]");
    }
}