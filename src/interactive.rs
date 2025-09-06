use crate::{MarkdownFormatter, RustiumError, extract_title};
use colored::*;
use dialoguer::{Confirm, Input, Select};
use indicatif::{ProgressBar, ProgressStyle};
use std::path::Path;
use std::time::Duration;

pub fn show_banner() {
    let banner = r#"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║    ██████╗ ██╗   ██╗███████╗████████╗██╗██╗   ██╗███╗   ███╗ ║
    ║    ██╔══██╗██║   ██║██╔════╝╚══██╔══╝██║██║   ██║████╗ ████║ ║
    ║    ██████╔╝██║   ██║███████╗   ██║   ██║██║   ██║██╔████╔██║ ║
    ║    ██╔══██╗██║   ██║╚════██║   ██║   ██║██║   ██║██║╚██╔╝██║ ║
    ║    ██║  ██║╚██████╔╝███████╗   ██║   ██║╚██████╔╝██║ ╚═╝ ██║ ║
    ║    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝     ╚═╝ ║
    ║                                                              ║
    ║              📝 Markdown to Medium Converter 📝              ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
    "#;

    println!("{}", banner.bright_cyan());
    println!(
        "{}",
        "Welcome to Rustium CLI - Your Markdown to Medium Converter!"
            .bright_yellow()
            .bold()
    );
    println!();
}

pub async fn interactive_mode() -> Result<(), RustiumError> {
    show_banner();

    loop {
        // Step 1: Get file path
        let file_path = get_file_path().await?;

        // Step 2: Choose output method
        let output_method = choose_output_method().await?;

        // Step 3: Process the file
        process_file(&file_path, output_method).await?;

        // Ask what to do next based on the output method
        println!();
        println!(
            "{}",
            "🎉 File processed successfully!".bright_green().bold()
        );

        let next_actions = if output_method {
            // If displayed, offer to save as well
            vec![
                "Save to file as well",
                "Process another markdown file",
                "Exit the application",
            ]
        } else {
            // If saved, just offer to process another or exit
            vec!["Process another markdown file", "Exit the application"]
        };

        let continue_choice = Select::new()
            .with_prompt("What would you like to do next?")
            .items(&next_actions)
            .default(0)
            .interact()
            .map_err(|e| {
                RustiumError::Io(std::io::Error::new(std::io::ErrorKind::InvalidInput, e))
            })?;

        if output_method && continue_choice == 0 {
            // Save to file as well
            let input_path = std::path::Path::new(&file_path);
            let stem = input_path.file_stem().unwrap().to_str().unwrap();
            let output_path = format!("{}_medium.txt", stem);

            // Read content and format again for saving
            let content = std::fs::read_to_string(&file_path)?;
            let title = extract_title(&content).unwrap_or("Untitled Post");
            let formatted_content = MarkdownFormatter::format_for_medium(&content, &title, &[]);

            MarkdownFormatter::save_formatted_content(&formatted_content, &output_path)?;

            println!();
            println!("{}", "✅ Also saved to file!".bright_green().bold());
            println!(
                "{}",
                format!("📄 Output saved to: {}", output_path).bright_cyan()
            );
            println!();
            println!(
                "{}",
                "📋 Preview of saved content (clean version without colors):"
                    .bright_yellow()
                    .bold()
            );
            println!("{}", "─".repeat(60).bright_white());

            // Show a preview of the clean content (first 10 lines)
            let clean_content = MarkdownFormatter::strip_ansi_codes(&formatted_content);
            let preview_lines: Vec<&str> = clean_content.lines().take(10).collect();
            for line in preview_lines {
                println!("{}", line.bright_white());
            }
            if clean_content.lines().count() > 10 {
                println!(
                    "{}",
                    "... (content continues in file)".bright_white().italic()
                );
            }
            println!("{}", "─".repeat(60).bright_white());

            // Ask again what to do next
            let final_choice = Select::new()
                .with_prompt("What would you like to do next?")
                .items(&["Process another markdown file", "Exit the application"])
                .default(0)
                .interact()
                .map_err(|e| {
                    RustiumError::Io(std::io::Error::new(std::io::ErrorKind::InvalidInput, e))
                })?;

            if final_choice == 1 {
                println!();
                println!(
                    "{}",
                    "👋 Thank you for using Rustium CLI!".bright_cyan().bold()
                );
                println!("{}", "Happy writing! 🦀".bright_yellow());
                break;
            }
        } else if (!output_method && continue_choice == 1)
            || (output_method && continue_choice == 2)
        {
            // Exit the application
            println!();
            println!(
                "{}",
                "👋 Thank you for using Rustium CLI!".bright_cyan().bold()
            );
            println!("{}", "Happy writing! 🦀".bright_yellow());
            break;
        }

        // Clear screen for next iteration (optional)
        println!();
        println!("{}", "─".repeat(60).bright_white());
        println!();
    }

    Ok(())
}

async fn get_file_path() -> Result<String, RustiumError> {
    println!("{}", "📝 Select your markdown file".bright_blue().bold());

    loop {
        let file_path: String = Input::new()
            .with_prompt("Enter the path to your markdown file")
            .interact_text()
            .map_err(|e| {
                RustiumError::Io(std::io::Error::new(std::io::ErrorKind::InvalidInput, e))
            })?;

        if Path::new(&file_path).exists() {
            if file_path.ends_with(".md") || file_path.ends_with(".markdown") {
                println!(
                    "{}",
                    format!("✅ Found markdown file: {}", file_path).green()
                );
                return Ok(file_path);
            } else {
                println!(
                    "{}",
                    "⚠️  Warning: File doesn't have .md or .markdown extension".yellow()
                );
                if Confirm::new()
                    .with_prompt("Continue anyway?")
                    .default(false)
                    .interact()
                    .map_err(|e| {
                        RustiumError::Io(std::io::Error::new(std::io::ErrorKind::InvalidInput, e))
                    })?
                {
                    return Ok(file_path);
                }
            }
        } else {
            println!("{}", "❌ File not found. Please try again.".red());
        }
    }
}

async fn choose_output_method() -> Result<bool, RustiumError> {
    println!();
    println!("{}", "📤 Choose output method".bright_blue().bold());

    let options = vec!["Save to file", "Display in terminal"];
    let selection = Select::new()
        .with_prompt("How would you like to view the formatted content?")
        .items(&options)
        .default(0)
        .interact()
        .map_err(|e| RustiumError::Io(std::io::Error::new(std::io::ErrorKind::InvalidInput, e)))?;

    Ok(selection == 1) // true for display, false for save to file
}

async fn process_file(file_path: &str, display_only: bool) -> Result<(), RustiumError> {
    println!();
    println!(
        "{}",
        "⚙️  Processing your markdown file".bright_blue().bold()
    );

    // Create progress bar
    let pb = ProgressBar::new_spinner();
    pb.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.green} {msg}")
            .unwrap()
            .tick_strings(&["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]),
    );
    pb.set_message("Reading and formatting markdown...");
    pb.enable_steady_tick(Duration::from_millis(100));

    // Read file
    let content = std::fs::read_to_string(file_path)?;
    let title = extract_title(&content).unwrap_or("Untitled Post");

    // Simulate processing time
    tokio::time::sleep(Duration::from_millis(1500)).await;

    // Format content
    let formatted_content = MarkdownFormatter::format_for_medium(&content, &title, &[]);

    pb.finish_with_message("✅ Formatting complete!");

    if display_only {
        println!();
        MarkdownFormatter::display_formatted_content(&formatted_content);
    } else {
        // Generate output filename
        let input_path = Path::new(file_path);
        let stem = input_path.file_stem().unwrap().to_str().unwrap();
        let output_path = format!("{}_medium.txt", stem);

        // Save to file (this will automatically strip ANSI codes)
        MarkdownFormatter::save_formatted_content(&formatted_content, &output_path)?;

        println!();
        println!(
            "{}",
            "✅ Successfully converted markdown to Medium format!"
                .bright_green()
                .bold()
        );
        println!(
            "{}",
            format!("📄 Output saved to: {}", output_path).bright_cyan()
        );
        println!();
        println!(
            "{}",
            "📋 Preview of saved content (clean version without colors):"
                .bright_yellow()
                .bold()
        );
        println!("{}", "─".repeat(60).bright_white());

        // Show a preview of the clean content (first 10 lines)
        let clean_content = MarkdownFormatter::strip_ansi_codes(&formatted_content);
        let preview_lines: Vec<&str> = clean_content.lines().take(10).collect();
        for line in preview_lines {
            println!("{}", line.bright_white());
        }
        if clean_content.lines().count() > 10 {
            println!(
                "{}",
                "... (content continues in file)".bright_white().italic()
            );
        }
        println!("{}", "─".repeat(60).bright_white());
    }

    println!();
    println!("{}", "📋 Next steps:".bright_yellow().bold());
    if display_only {
        println!(
            "{}",
            "1. Copy the formatted content above (with colors)".bright_white()
        );
    } else {
        println!(
            "{}",
            "1. Open the saved file and copy its clean content".bright_white()
        );
    }
    println!("{}", "2. Go to https://medium.com/new-story".bright_white());
    println!(
        "{}",
        "3. Paste the content into Medium's editor".bright_white()
    );
    println!(
        "{}",
        "4. Add tags manually in Medium's tag section".bright_white()
    );
    println!("{}", "5. Publish as draft or public".bright_white());

    Ok(())
}
