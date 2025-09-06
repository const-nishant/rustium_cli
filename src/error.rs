use std::fmt;

#[derive(Debug)]
pub enum RustiumError {
    Io(std::io::Error),
    MediumApi(String),
}

impl fmt::Display for RustiumError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            RustiumError::Io(e) => write!(f, "IO error: {}", e),
            RustiumError::MediumApi(e) => write!(f, "Medium API error: {}", e),
        }
    }
}

impl std::error::Error for RustiumError {}

impl From<std::io::Error> for RustiumError {
    fn from(err: std::io::Error) -> Self {
        RustiumError::Io(err)
    }
}
