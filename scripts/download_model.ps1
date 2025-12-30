# Simple model download test script
# For testing HuggingFace connectivity

Write-Host ""
Write-Host "Testing HuggingFace Model Download" -ForegroundColor Cyan
Write-Host ""

# Check if huggingface_hub is installed
Write-Host "Checking dependencies..." -ForegroundColor Yellow

python -c @"
try:
    from huggingface_hub import list_repo_files
    print('OK - huggingface_hub is working')
except ImportError:
    print('ERROR - huggingface_hub not found')
    exit(1)
except Exception as e:
    print(f'ERROR - {e}')
    exit(1)
"@

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing huggingface_hub..." -ForegroundColor Yellow
    pip install huggingface_hub
}

Write-Host ""
Write-Host "Attempting to download TinyLlama-1.1B-int4..." -ForegroundColor Yellow
Write-Host ""

# Create models directory if it doesn't exist
$modelsDir = "models"
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir | Out-Null
}

# Try to download the model
python -c @"
from huggingface_hub import snapshot_download
import os

try:
    print('Initializing download...')
    print('Repository: openvino-community/TinyLlama-1.1B-int4')
    print('Save location: ./models/TinyLlama-1.1B-int4')
    print('')
    print('This may take a few minutes depending on your internet connection...')
    print('')
    
    model_path = snapshot_download(
        repo_id='openvino-community/TinyLlama-1.1B-int4',
        local_dir='./models/TinyLlama-1.1B-int4',
        repo_type='model',
        resume_download=True
    )
    
    print('')
    print('SUCCESS - Model downloaded to:', model_path)
    
except Exception as e:
    print(f'ERROR: {e}')
    print('')
    print('Possible solutions:')
    print('1. Check your internet connection')
    print('2. Try: pip install --upgrade huggingface_hub')
    print('3. Check HuggingFace API status')
    exit(1)
"@

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS - Model downloaded!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now use the model with:" -ForegroundColor Cyan
    Write-Host "  python scripts/run_inference.py" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR - Download failed. Check the error messages above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check internet connection"
    Write-Host "2. Try upgrading huggingface_hub: pip install --upgrade huggingface_hub"
    Write-Host "3. Check HuggingFace website for any service issues"
}

Write-Host ""
