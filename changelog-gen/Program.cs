using System;
using System.Text;
using LibGit2Sharp;
using System.IO;
using System.Linq;
using System.Collections.Generic;

namespace ChangelogGen
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Changelog Generator");
            Console.WriteLine("-------------------");

            // Get repository path from argument
            string repoPath = args[0];

            // Check if HTML generation is requested
            bool generateHtml = args.Length > 1 && args[1].ToLower() == "html";

            // Validate if path is a git repository using LibGit2Sharp
            if (!Repository.IsValid(repoPath))
            {
                Console.WriteLine($"Error: {repoPath} is not a valid git repository.");
                return;
            }

            string changelog = GenerateChangelog(repoPath);

            // Save Markdown changelog
            string mdOutputPath = Path.Combine(repoPath, "changelog.md");
            File.WriteAllText(mdOutputPath, changelog);
            Console.WriteLine($"Changelog generated and saved to {mdOutputPath}");

            // Generate HTML file if requested
            if (generateHtml)
            {
                string htmlChangelog = ConvertToHtml(changelog);
                string htmlOutputPath = Path.Combine(repoPath, "changelog.html");
                File.WriteAllText(htmlOutputPath, htmlChangelog);
                Console.WriteLine($"HTML version saved to {htmlOutputPath}");
            }
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

        static string ConvertToHtml(string markdownChangelog)
        {
            StringBuilder html = new StringBuilder();
        
            html.AppendLine("<!DOCTYPE html>");
            html.AppendLine("<html lang=\"en\">");
            html.AppendLine("<head>");
            html.AppendLine("    <meta charset=\"UTF-8\">");
            html.AppendLine("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
            html.AppendLine("    <title>Changelog</title>");
            html.AppendLine("    <style>");
            html.AppendLine("        body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }");
            html.AppendLine("        h1 { color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px; }");
            html.AppendLine("        h2 { color: #444; margin-top: 20px; }");
            html.AppendLine("        ul { padding-left: 20px; }");
            html.AppendLine("        li { margin-bottom: 8px; }");
            html.AppendLine("    </style>");
            html.AppendLine("</head>");
            html.AppendLine("<body>");
            
            // Convert markdown to simple HTML
            string[] lines = markdownChangelog.Split('\n');
            bool inList = false;
            
            foreach (string line in lines)
            {
                string trimmedLine = line.Trim();
                
                if (trimmedLine.StartsWith("# "))
                {
                    // Main heading
                    if (inList)
                    {
                        html.AppendLine("</ul>");
                        inList = false;
                    }
                    html.AppendLine($"<h1>{trimmedLine.Substring(2)}</h1>");
                }
                else if (trimmedLine.StartsWith("## "))
                {
                    // Subhead
                    if (inList)
                    {
                        html.AppendLine("</ul>");
                        inList = false;
                    }
                    html.AppendLine($"<h2>{trimmedLine.Substring(3)}</h2>");
                }
                else if (trimmedLine.StartsWith("- "))
                {
                    // List item
                    if (!inList)
                    {
                        html.AppendLine("<ul>");
                        inList = true;
                    }
                    html.AppendLine($"<li>{trimmedLine.Substring(2)}</li>");
                }
                else if (string.IsNullOrWhiteSpace(trimmedLine))
                {
                    // Empty line
                    if (inList)
                    {
                        html.AppendLine("</ul>");
                        inList = false;
                    }
                }
            }
            
            // Ensure we close any open list
            if (inList)
            {
                html.AppendLine("</ul>");
            }
            
            html.AppendLine("</body>");
            html.AppendLine("</html>");
            
            return html.ToString();
        }
    }
}
