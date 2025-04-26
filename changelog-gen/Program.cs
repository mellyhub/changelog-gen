using System.Text;
using LibGit2Sharp;

namespace ChangelogGen
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Changelog Generator");
            Console.WriteLine("------------------");

            // Get repository path from argument
            string repoPath = args[0];

            // Validate if path is a git repository using LibGit2Sharp
            if (!Repository.IsValid(repoPath))
            {
                Console.WriteLine($"Error: {repoPath} is not a valid git repository.");
                return;
            }

            string changelog = GenerateChangelog(repoPath);
            Console.WriteLine(changelog);

            string outputPath = Path.Combine(repoPath, "changelog.md"); // Hardcoded output path for now
            File.WriteAllText(outputPath, changelog);
            Console.WriteLine($"Changelog generated and saved to {outputPath}");
        }

        static string GenerateChangelog(string repoPath)
        {
            StringBuilder changelog = new StringBuilder();
            changelog.AppendLine("# Changelog\n");
            
            using (var repo = new Repository(repoPath))
            {
                var commits = repo.Commits.ToList();
                Dictionary<DateTime, List<Commit>> commitsByDate = new Dictionary<DateTime, List<Commit>>();
                
                // Group commits by date
                foreach (var commit in commits)
                {
                    DateTime commitDate = commit.Author.When.Date;
                    
                    if (!commitsByDate.ContainsKey(commitDate))
                    {
                        commitsByDate[commitDate] = new List<Commit>();
                    }
                    
                    commitsByDate[commitDate].Add(commit);
                }
                
                // Sort dates (newest first)
                var sortedDates = commitsByDate.Keys.OrderByDescending(date => date).ToList();
                foreach (var date in sortedDates)
                {
                    changelog.AppendLine($"## {date.ToString("yyyy-MM-dd")}");
                    
                    foreach (var commit in commitsByDate[date])
                    {
                        // Format commit entry
                        string message = commit.MessageShort;
                        string author = commit.Author.Name;
                        string hash = commit.Id.ToString(7); // Short hash
                        
                        changelog.AppendLine($"- {message} ({author}, {hash})");
                    }
                    
                    changelog.AppendLine();
                }
            }
            
            return changelog.ToString();
        }
    }
}
