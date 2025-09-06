/// Extract the title from markdown content (first # heading)
pub fn extract_title(content: &str) -> Option<&str> {
    for line in content.lines() {
        if line.starts_with("# ") {
            return Some(line.trim_start_matches("# "));
        }
    }
    None
}

/// Parse comma-separated tags string into a vector
pub fn parse_tags(tags_str: &str) -> Vec<&str> {
    tags_str.split(',').map(|tag| tag.trim()).collect()
}
