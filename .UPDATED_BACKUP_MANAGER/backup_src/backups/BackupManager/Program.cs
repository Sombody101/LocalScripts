using CommandLine;
using CommandLine.Text;

namespace backups;

internal class Program
{
    public class Args
    {
        [Option('h', "help", Required = false, HelpText = "Displays this help message")]
        public bool help { get; set; }
    }

    static void Main(string[] args)
    {
        var helpText = HelpText.AutoBuild<Args>().ToString();

        Parser.Default.ParseArguments<Args>(args)
            .WithParsed(o =>
            {
            })
            .WithNotParsed
            (
                (e) =>
                {
                }
            );
    }
}