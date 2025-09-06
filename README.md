# 🦀 Rustium CLI

[![CI](https://github.com/const-nishant/rustium_cli/workflows/CI/badge.svg)](https://github.com/const-nishant/rustium_cli/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 📝 **Markdown to Medium Converter** - Transform your Markdown files into Medium-friendly format with beautiful terminal interface

Rustium CLI is a powerful, interactive command-line tool built in Rust that converts your Markdown files into a format optimized for Medium publishing. With its beautiful terminal interface and smart formatting, it makes the process of preparing content for Medium seamless and enjoyable.

## ✨ Features

- 🎨 **Beautiful Interactive Interface** - Colorful terminal UI with progress indicators
- 📝 **Smart Markdown Conversion** - Converts headers, lists, and formatting for Medium
- 💾 **Multiple Output Options** - Display in terminal or save to file
- 🔍 **File Validation** - Validates markdown files and provides helpful feedback
- 🏷️ **Tag Support** - Easy tag management for your Medium posts
- ⚡ **Fast & Reliable** - Built with Rust for optimal performance
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux

## 🚀 Installation

### From Source (Recommended)

```bash
# Clone the repository
git clone https://github.com/const-nishant/rustium_cli.git
cd rustium_cli

# Build and install
cargo build --release
cargo install --path .
```

### Using Cargo (From Source)

```bash
# Install directly from the GitHub repository
cargo install --git https://github.com/const-nishant/rustium_cli.git
```

### Pre-built Binaries

Download the latest release for your platform from the [Releases](https://github.com/const-nishant/rustium_cli/releases) page:

- **Windows**: `rustium_cli-x86_64-pc-windows-msvc.zip`
- **macOS**: `rustium_cli-x86_64-apple-darwin.tar.gz`
- **Linux**: `rustium_cli-x86_64-unknown-linux-gnu.tar.gz`

## 📖 Usage

Simply run the application:

```bash
rustium_cli
```

The interactive interface will guide you through:

1. **📝 Select your markdown file** - Enter the path to your `.md` or `.markdown` file
2. **📤 Choose output method** - Display in terminal or save to file
3. **⚙️ Processing** - Watch the beautiful progress indicator as your file is converted
4. **🎉 Results** - View the formatted content or find your saved file

### Example Workflow

```
🦀 Rustium CLI - Markdown to Medium Converter

📝 Select your markdown file
Enter the path to your markdown file: my-blog-post.md
✅ Found markdown file: my-blog-post.md

📤 Choose output method
How would you like to view the formatted content?
> Save to file
  Display in terminal

⚙️ Processing your markdown file
⠋ Reading and formatting markdown...
✅ Formatting complete!

✅ Successfully converted markdown to Medium format!
📄 Output saved to: my-blog-post_medium.txt
```

## 🎯 What It Does

Rustium CLI transforms your Markdown content by:

- **Headers**: `# Title` → `📝 Title`, `## Subtitle` → `📌 Subtitle`
- **Lists**: `- Item` → `• Item`, `1. Item` → `1. Item` (renumbered)
- **Formatting**: Preserves bold, italic, and other text formatting
- **Clean Output**: Removes ANSI codes for file output, keeps colors for terminal display

## 📋 Next Steps After Conversion

1. **Copy the formatted content** (from terminal or saved file)
2. **Go to** [https://medium.com/new-story](https://medium.com/new-story)
3. **Paste the content** into Medium's editor
4. **Add tags manually** in Medium's tag section
5. **Publish** as draft or public

## 🛠️ Development

### Prerequisites

- [Rust](https://rustup.rs/) (latest stable version)
- Git

### Building

```bash
# Clone the repository
git clone https://github.com/const-nishant/rustium_cli.git
cd rustium_cli

# Build in debug mode
cargo build

# Build in release mode
cargo build --release

# Run tests
cargo test

# Run the application
cargo run
```

### Project Structure

```
src/
├── main.rs          # Application entry point
├── lib.rs           # Library exports
├── interactive.rs   # Interactive CLI interface
├── formatter.rs     # Markdown formatting logic
├── markdown.rs      # Markdown parsing utilities
└── error.rs         # Error handling
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using [Rust](https://www.rust-lang.org/)
- Terminal UI powered by [dialoguer](https://crates.io/crates/dialoguer)
- Beautiful colors with [colored](https://crates.io/crates/colored)
- Progress indicators with [indicatif](https://crates.io/crates/indicatif)

## 📞 Support

If you encounter any issues or have questions:

- 🐛 **Bug Reports**: [Open an issue](https://github.com/const-nishant/rustium_cli/issues)
- 💡 **Feature Requests**: [Open an issue](https://github.com/const-nishant/rustium_cli/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/const-nishant/rustium_cli/discussions)

---

**Happy writing! 🦀📝**
