# Script PowerShell para redimensionar logo_app.png para Linux
# Este script utiliza System.Drawing para procesar imágenes

Add-Type -AssemblyName System.Drawing

$sourceImage = "assets/logo_app.png"
$linuxIconsDir = "linux/icons"
$sizes = @(16, 32, 48, 64, 128, 256)

try {
    # Cargar imagen
    $image = [System.Drawing.Image]::FromFile((Resolve-Path $sourceImage).Path)
    Write-Host "Imagen fuente cargada: $sourceImage"
    Write-Host "Tamaño original: $($image.Width)x$($image.Height)px"
    
    # Generar íconos para Linux
    Write-Host "`nGenerando íconos para Linux..."
    foreach ($size in $sizes) {
        $dir = Join-Path $linuxIconsDir "${size}x${size}"
        $iconPath = Join-Path $dir "io.xeland314.chat_analyzer_ui.png"
        
        # Crear bitmap redimensionado
        $resized = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($resized)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $size, $size)
        $graphics.Dispose()
        
        # Guardar imagen
        $resized.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $resized.Dispose()
        Write-Host "  ✓ Creado: ${size}x${size}px"
    }
    
    $image.Dispose()
    Write-Host "`n✓ Íconos generados exitosamente para Linux"
}
catch {
    Write-Host "✗ Error: $_"
    exit 1
}
