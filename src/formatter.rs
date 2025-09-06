use crate::error::RustiumError;
use colored::*;
use std::fs;

pub struct MarkdownFormatter;

impl MarkdownFormatter {
    pub fn format_for_medium(markdown_content: &str, title: &str, tags: &[&str]) -> String {
        let mut formatted = String::new();

        // Add title
        formatted.push_str(&format!("{}\n\n", title.bright_cyan().bold()));

        // Add tags as a nice header
        if !tags.is_empty() {
            formatted.push_str(&format!("🏷️  Tags: {}\n\n", tags.join(", ").bright_blue()));
        }

        // Add separator
        formatted.push_str(&format!("{}\n\n", "─".repeat(50).bright_white()));

        // Convert markdown to Medium-friendly format
        let converted_content = Self::convert_markdown_to_medium_format(markdown_content);
        formatted.push_str(&converted_content);

        formatted
    }

    fn convert_markdown_to_medium_format(content: &str) -> String {
        let mut result = content.to_string();

        // Convert headers
        result = result.replace("# ", "📝 ");
        result = result.replace("## ", "📌 ");
        result = result.replace("### ", "🔸 ");

        // Convert lists (basic conversion) - be more specific to avoid affecting bold text
        result = result.replace("- ", "• ");
        // Only replace * at the beginning of lines to avoid affecting bold text
        let lines: Vec<&str> = result.lines().collect();
        let mut converted_lines = Vec::new();

        for line in lines {
            if line.trim().starts_with("* ") && !line.trim().starts_with("**") {
                converted_lines.push(line.replace("* ", "• "));
            } else {
                converted_lines.push(line.to_string());
            }
        }

        result = converted_lines.join("\n");

        // Convert numbered lists
        let lines: Vec<&str> = result.lines().collect();
        let mut converted_lines = Vec::new();
        let mut list_counter = 1;

        for line in lines {
            if line.trim().starts_with("1. ")
                || line.trim().starts_with("2. ")
                || line.trim().starts_with("3. ")
                || line.trim().starts_with("4. ")
                || line.trim().starts_with("5. ")
                || line.trim().starts_with("6. ")
                || line.trim().starts_with("7. ")
                || line.trim().starts_with("8. ")
                || line.trim().starts_with("9. ")
            {
                // Extract the content after the number and dot
                let content = &line.trim()[2..];
                converted_lines.push(format!("{}. {}", list_counter, content));
                list_counter += 1;
            } else {
                converted_lines.push(line.to_string());
                list_counter = 1; // Reset counter for new lists
            }
        }

        converted_lines.join("\n")
    }

    pub fn save_formatted_content(content: &str, output_path: &str) -> Result<(), RustiumError> {
        // Remove ANSI color codes for clean file output
        let clean_content = Self::strip_ansi_codes(content);
        fs::write(output_path, clean_content).map_err(|e| RustiumError::Io(e))?;
        Ok(())
    }

    pub fn strip_ansi_codes(text: &str) -> String {
        // Remove ANSI escape sequences (color codes)
        text.lines()
            .map(|line| {
                // Remove ANSI escape sequences like [1;96m, [0m, [94m, etc.
                let mut clean_line = line.to_string();
                while let Some(start) = clean_line.find('\x1b') {
                    if let Some(end) = clean_line[start..].find('m') {
                        clean_line.replace_range(start..start + end + 1, "");
                    } else {
                        break;
                    }
                }
                clean_line
            })
            .collect::<Vec<_>>()
            .join("\n")
    }

    pub fn display_formatted_content(content: &str) {
        println!(
            "{}",
            "📄 Formatted Content for Medium:".bright_green().bold()
        );
        println!(
            "{}",
            "════════════════════════════════════════════════════════════".dimmed()
        );
        println!("{}", content);
        println!(
            "{}",
            "════════════════════════════════════════════════════════════".dimmed()
        );
    }
}
