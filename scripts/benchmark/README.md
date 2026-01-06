# Benchmark Scripts

**Benchmark execution scripts for OpenVINO AI inference performance testing.**

---

## 📁 Contents

| File | Type | Purpose |
|------|------|---------|
| `setup_and_run_benchmark.ps1` | PowerShell | Full-featured setup and execution with parameter customization |
| `run_benchmark.bat` | Batch | Windows batch file for quick double-click execution |
| `run_benchmark.ps1` | PowerShell | Simplified PowerShell version for fast execution |

---

## 🚀 Quick Start

### Method 1: Double-click (Recommended for Windows users)
```
run_benchmark.bat
```
Fully automated, no need to open PowerShell.

### Method 2: PowerShell (Full features)
```powershell
.\setup_and_run_benchmark.ps1                    # Default parameters
.\setup_and_run_benchmark.ps1 -NumIter 3         # 3 iterations
.\setup_and_run_benchmark.ps1 -Device CPU        # Use CPU instead
```

### Method 3: PowerShell (Quick version)
```powershell
.\run_benchmark.ps1
```

---

## 📋 Features

✅ Automatic OpenVINO PATH configuration (permanent + temporary)  
✅ System environment verification (executable, models, runtime)  
✅ Parameter customization support  
✅ Detailed execution feedback  
✅ Performance metrics output  

---

## 🔧 Parameters

### setup_and_run_benchmark.ps1

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-Device` | GPU | Execution device (GPU/CPU) |
| `-NumIter` | 1 | Number of iterations |
| `-MaxTokens` | 20 | Maximum tokens to generate |
| `-Warmup` | 0 | Number of warmup iterations |
| `-Prompt` | "The Sky is blue because" | Input prompt |
| `-CacheDir` | ".ccache" | Compilation cache directory |
| `-SkipSetup` | (flag) | Skip environment variable setup |

---

## 📝 Usage Examples

```powershell
# Default execution
.\setup_and_run_benchmark.ps1

# CPU instead of GPU
.\setup_and_run_benchmark.ps1 -Device CPU

# Multiple iterations for averaging
.\setup_and_run_benchmark.ps1 -NumIter 5 -SkipSetup

# Custom prompt
.\setup_and_run_benchmark.ps1 -Prompt "Hello, how are you?"

# Full customization
.\setup_and_run_benchmark.ps1 -Device GPU -NumIter 3 -MaxTokens 50 -Warmup 1
```

---

## 🧪 Expected Output

```
════════════════════════════════════════════════════════════
                一鍵 Benchmark 設定與執行
════════════════════════════════════════════════════════════

[1] 檢查系統環境
   工作目錄: C:\Users\svd\codes\openvino-lab
✅ 找到 benchmark 執行檔
✅ 找到模型路徑
✅ 找到 OpenVINO runtime

[2] 設定 OpenVINO PATH 環境變數
✅ 永久 PATH 設定完成
✅ 會話 PATH 設定完成

[3] 驗證 OpenVINO 可用性
✅ benchmark 執行檔驗證成功

════════════════════════════════════════════════════════════
                    執行 Benchmark
════════════════════════════════════════════════════════════

OpenVINO Runtime
    Version : 2025.4.1
    Build   : 2025.4.1-20426-82bbf0292c5-releases/2025/4

Load time: 5907.00 ms
TTFT: 113.03 ± 0.00 ms
TPOT: 60.44 ± 5.24 ms/token
Throughput: 16.55 ± 1.44 tokens/s
```

---

## ⚠️ Troubleshooting

### Issue: Script cannot find model or runtime
**Solution:** Ensure you're running from the correct directory or use absolute paths.

### Issue: "OpenVINO DLL not found"
**Solution:** 
1. Run `setup_and_run_benchmark.ps1` once to set permanent PATH
2. Restart PowerShell
3. Try again

### Issue: GPU device not recognized
**Solution:**
1. Verify GPU drivers are installed
2. Try CPU mode: `.\setup_and_run_benchmark.ps1 -Device CPU`
3. Check OpenVINO installation

---

## 📚 Related Documentation

- See project root for detailed setup guides
- Check [docs/benchmark/ONE_CLICK_QUICK_START.md](../../docs/benchmark/ONE_CLICK_QUICK_START.md) for comprehensive usage guide
- Refer to [docs/benchmark/STAGE_7_CONFIGURE_DSM_HINTS.md](../../docs/benchmark/STAGE_7_CONFIGURE_DSM_HINTS.md) for advanced configuration

---

**Version:** 1.0  
**Last Updated:** 2026-01-06  
**Status:** ✅ Production Ready
