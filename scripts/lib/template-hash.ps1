function Get-TemplateTextHash {
    param([string]$Path, [switch]$LegacyCrlf)

    # Latin-1 maps each byte to one character, preserving UTF-8 bytes, BOM and EOF.
    $encoding = [System.Text.Encoding]::GetEncoding(28591)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $text = $encoding.GetString($bytes).Replace("`r`n", "`n")
    if ($LegacyCrlf) { $text = $text.Replace("`n", "`r`n") }
    $stream = [System.IO.MemoryStream]::new($encoding.GetBytes($text), $false)
    try {
        return (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLowerInvariant()
    } finally {
        $stream.Dispose()
    }
}
