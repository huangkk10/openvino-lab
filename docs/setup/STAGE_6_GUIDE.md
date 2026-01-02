# 第 6️⃣ 階段：配置設置指南

本指南涵蓋 OpenVINO GenAI 環境設置的第 6 階段：配置項目參數和環境變數。

---

## 📋 目錄

- [概述](#概述)
- [配置文件說明](#配置文件說明)
- [快速設置](#快速設置)
- [配置詳解](#配置詳解)
  - [環境變數配置 (.env)](#環境變數配置-env)
  - [YAML 配置 (config.yaml)](#yaml-配置-configyaml)
- [常用配置場景](#常用配置場景)
- [驗證配置](#驗證配置)
- [常見問題](#常見問題)
- [故障排除](#故障排除)

---

## 概述

**目標：** 配置 OpenVINO GenAI 專案的環境變數和運行參數，為推理任務做準備。

**所需時間：** 3-5 分鐘

**前置條件：**
- ✅ 已完成 [第 5 階段：環境驗證](README.md#第-5️⃣-階段環境驗證)
- ✅ OpenVINO GenAI 已成功安裝
- ✅ 測試腳本運行通過

**本階段將創建：**
- `config/.env` - 本地環境變數配置（不上傳到 Git）
- `logs/` - 日誌輸出目錄
- `temp/` - 臨時文件目錄
- `metrics/` - 性能指標輸出目錄

---

## 配置文件說明

本專案使用兩種配置方式：

### 📄 配置文件對比

| 文件 | 用途 | 是否提交到 Git | 優先級 |
|------|------|----------------|--------|
| **config/.env** | 本地環境變數配置 | ❌ 不提交 | 高 |
| **config/.env.example** | 環境變數模板 | ✅ 提交 | - |
| **config/config.yaml** | YAML 項目配置 | ✅ 提交 | 中 |

### 🔍 配置加載順序

```
環境變數 (.env) → YAML 配置 (config.yaml) → 程式碼預設值
    高優先級              中優先級              低優先級
```

**建議：**
- 敏感資訊（API Token）→ `.env`
- 項目固定配置 → `config.yaml`
- 臨時測試參數 → 命令行參數

---

## 快速設置

### 方法 1：自動設置（推薦）

```powershell
# 導航到專案目錄
cd c:\Users\svd\codes\openvino-lab

# 複製環境變數模板
Copy-Item config\.env.example config\.env

# 創建必要的目錄
@("logs", "temp", "metrics") | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
        Write-Host "✓ 已創建目錄: $_"
    }
}

Write-Host "✅ 配置設置完成！" -ForegroundColor Green
```

### 方法 2：手動設置

#### 步驟 1：創建 .env 文件

```powershell
# 複製模板
Copy-Item config\.env.example config\.env

# 使用編輯器打開
notepad config\.env
```

#### 步驟 2：編輯配置

根據您的需求修改以下重要參數：

```bash
# 推理設備（CPU, GPU, NPU, AUTO）
DEFAULT_DEVICE=AUTO

# CPU 線程數（建議設置為實體核心數）
OV_NUM_THREADS=4

# 日誌級別
OV_LOG_LEVEL=INFO

# 最大生成 token 數
MAX_NEW_TOKENS=100
```

#### 步驟 3：創建目錄

```powershell
# 創建輸出目錄
New-Item -ItemType Directory -Path logs -Force
New-Item -ItemType Directory -Path temp -Force
New-Item -ItemType Directory -Path metrics -Force
```

---

## 配置詳解

### 環境變數配置 (.env)

`.env` 文件用於存儲本地環境特定的配置。以下是詳細說明：

#### 1️⃣ 日誌配置

```bash
# ==================== Logging Configuration ====================
# Log level: DEBUG, INFO, WARNING, ERROR
OV_LOG_LEVEL=INFO
```

**可選值：**
- `DEBUG` - 詳細調試信息（開發時使用）
- `INFO` - 一般信息（推薦）
- `WARNING` - 僅警告和錯誤
- `ERROR` - 僅錯誤信息

---

#### 2️⃣ 運行配置

```bash
# ==================== Runtime Configuration ====================
# OpenVINO CPU thread count (leave empty to use auto)
OV_NUM_THREADS=4

# Whether to use CPU binding
OV_AFFINITY=
```

**OV_NUM_THREADS 設置建議：**

| CPU 核心數 | 建議設置 | 說明 |
|-----------|---------|------|
| 4 核 | 2-4 | 留出資源給系統 |
| 8 核 | 4-6 | 平衡性能和穩定性 |
| 16 核 | 8-12 | 高性能設置 |
| 留空 | 自動 | OpenVINO 自動檢測 |

**檢查您的 CPU 核心數：**

```powershell
# PowerShell
$env:NUMBER_OF_PROCESSORS

# 或查看詳細信息
Get-WmiObject -Class Win32_Processor | Select-Object NumberOfCores, NumberOfLogicalProcessors
```

---

#### 3️⃣ GPU 配置

```bash
# ==================== GPU Configuration ====================
# GPU device selection (0, 1, 2...)
# OV_GPU_DEVICE=0
```

**使用場景：**
- 單 GPU：保持註釋（自動檢測）
- 多 GPU：指定設備編號（0, 1, 2...）

**查看可用 GPU：**

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 運行測試腳本
python scripts/test_openvino.py
```

輸出示例：
```
可用設備:
  - CPU
  - GPU.0  ← 第一個 GPU
  - GPU.1  ← 第二個 GPU
  - NPU
```

**選擇特定 GPU：**

```bash
# 使用第一個 GPU
OV_GPU_DEVICE=0

# 使用第二個 GPU
OV_GPU_DEVICE=1
```

---

#### 4️⃣ NPU 配置

```bash
# ==================== NPU Configuration ====================
# NPU device selection
# OV_NPU_DEVICE=0
```

**NPU (Neural Processing Unit)：**
- Intel 最新處理器（Meteor Lake 及以後）內建的 AI 加速器
- 低功耗、高效能的 AI 推理
- 如果您的系統有 NPU，測試腳本會自動檢測

---

#### 5️⃣ 模型配置

```bash
# ==================== Model Configuration ====================
# Default model path
DEFAULT_MODEL_PATH=./models

# Default inference device (CPU, GPU, NPU, AUTO)
DEFAULT_DEVICE=AUTO
```

**DEFAULT_DEVICE 選項：**

| 選項 | 說明 | 適用場景 |
|------|------|----------|
| `CPU` | 使用 CPU 推理 | 兼容性最好，穩定 |
| `GPU` | 使用 GPU 加速 | 有獨立顯卡時推薦 |
| `NPU` | 使用 NPU 加速 | 最新 Intel 處理器 |
| `AUTO` | 自動選擇最佳設備 | **推薦**，智能選擇 |

**性能對比（參考）：**

| 模型 | CPU | GPU | NPU |
|------|-----|-----|-----|
| TinyLlama-1.1B | 10-20 tok/s | 50-100 tok/s | 30-60 tok/s |
| OpenLLaMA-7B | 2-5 tok/s | 20-40 tok/s | 10-20 tok/s |

---

#### 6️⃣ Hugging Face 配置

```bash
# ==================== Hugging Face Configuration ====================
# Hugging Face API Token (for private models)
# HF_TOKEN=your_token_here

# Hugging Face download directory
HF_HOME=./models

# Use mirror source (for China users)
# HF_ENDPOINT=https://hf-mirror.com
```

**HF_TOKEN（可選）：**
- 用於訪問 Hugging Face 的私有模型
- 獲取方式：https://huggingface.co/settings/tokens

**HF_ENDPOINT（中國用戶）：**
- 如果無法訪問 Hugging Face，可使用鏡像站
- 取消註釋 `HF_ENDPOINT=https://hf-mirror.com`

---

#### 7️⃣ 推理參數

```bash
# ==================== Inference Parameters ====================
# Default maximum tokens to generate
MAX_NEW_TOKENS=100

# Default temperature (controls randomness, 0.0-1.0)
TEMPERATURE=0.7

# Default Top-K sampling
TOP_K=50

# Default Top-P (Nucleus) sampling
TOP_P=0.9
```

**參數說明：**

| 參數 | 範圍 | 說明 | 建議值 |
|------|------|------|--------|
| **MAX_NEW_TOKENS** | 1-2048 | 最大生成 token 數 | 100-200（一般）<br>500+（長文本） |
| **TEMPERATURE** | 0.0-1.0 | 控制隨機性<br>0=確定性，1=高隨機 | 0.7（平衡）<br>0.3（精確）<br>0.9（創意） |
| **TOP_K** | 1-100 | Top-K 採樣，限制候選詞 | 40-50 |
| **TOP_P** | 0.0-1.0 | Nucleus 採樣 | 0.9-0.95 |

**使用場景範例：**

```bash
# 場景 1：程式碼生成（需要精確）
TEMPERATURE=0.2
TOP_K=40
TOP_P=0.9

# 場景 2：創意寫作（需要多樣性）
TEMPERATURE=0.9
TOP_K=50
TOP_P=0.95

# 場景 3：對話聊天（平衡）
TEMPERATURE=0.7
TOP_K=50
TOP_P=0.9
```

---

#### 8️⃣ 開發配置

```bash
# ==================== Development Configuration ====================
# Whether to enable debug mode
DEBUG=false

# Whether to save generated metrics
SAVE_METRICS=false

# Metrics output directory
METRICS_OUTPUT=./metrics
```

**SAVE_METRICS：**
- `true` - 保存推理性能指標（吞吐量、延遲等）
- `false` - 不保存（默認）

---

### YAML 配置 (config.yaml)

`config.yaml` 用於項目級別的固定配置。

#### 完整配置文件

```yaml
# OpenVINO GenAI Project Configuration

project:
  name: OpenVINO GenAI Lab
  version: 1.0.0
  description: Learning and experimentation environment for OpenVINO GenAI

environment:
  python_version: "3.10+"
  venv_path: ./venv
  requirements_file: requirements.txt

models:
  default_device: CPU  # CPU, GPU, NPU
  default_format: int4  # fp32, fp16, int8, int4
  storage_path: ./models
  max_model_size_gb: 50

paths:
  docs: ./docs
  scripts: ./scripts
  examples: ./examples
  config: ./config
  models: ./models

supported_scenarios:
  - text_generation      # 文本生成
  - image_analysis       # 圖像分析（未來）
  - image_generation     # 圖像生成（未來）
  - speech_recognition   # 語音識別（未來）
  - speech_generation    # 語音合成（未來）
  - text_embedding       # 文本嵌入（未來）
  - text_reranking       # 文本重排（未來）

logging:
  level: INFO  # DEBUG, INFO, WARNING, ERROR
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: ./logs/openvino_genai.log

inference:
  batch_size: 1
  max_new_tokens: 100
  temperature: 0.7
  top_k: 50
  top_p: 0.9
```

---

## 常用配置場景

### 場景 1：開發測試（快速迭代）

```bash
# .env 配置
OV_LOG_LEVEL=DEBUG
DEFAULT_DEVICE=CPU
OV_NUM_THREADS=4
MAX_NEW_TOKENS=50
TEMPERATURE=0.7
DEBUG=true
SAVE_METRICS=true
```

**特點：**
- 詳細日誌便於調試
- 使用 CPU（穩定）
- 較短的生成長度（快速測試）
- 保存指標數據

---

### 場景 2：生產環境（高性能）

```bash
# .env 配置
OV_LOG_LEVEL=WARNING
DEFAULT_DEVICE=AUTO
OV_NUM_THREADS=8
MAX_NEW_TOKENS=200
TEMPERATURE=0.7
DEBUG=false
SAVE_METRICS=false
```

**特點：**
- 最少日誌（僅警告和錯誤）
- 自動選擇最佳設備
- 更多 CPU 線程
- 較長的生成長度
- 不保存額外數據

---

### 場景 3：GPU 加速

```bash
# .env 配置
OV_LOG_LEVEL=INFO
DEFAULT_DEVICE=GPU
OV_GPU_DEVICE=0
MAX_NEW_TOKENS=200
TEMPERATURE=0.7
```

**特點：**
- 明確使用 GPU
- 指定 GPU 設備
- 適合大模型推理

---

### 場景 4：中國用戶（網絡優化）

```bash
# .env 配置
OV_LOG_LEVEL=INFO
DEFAULT_DEVICE=AUTO
HF_HOME=./models
HF_ENDPOINT=https://hf-mirror.com
MAX_NEW_TOKENS=100
```

**特點：**
- 使用 Hugging Face 鏡像
- 加速模型下載

---

## 驗證配置

### 方法 1：查看配置文件

```powershell
# 查看 .env 文件
Get-Content config\.env -Encoding UTF8 | Select-Object -First 30

# 查看 config.yaml
Get-Content config\config.yaml
```

### 方法 2：運行測試腳本

創建驗證腳本 `test_config.py`：

```python
"""配置驗證腳本"""
import os
from pathlib import Path
from dotenv import load_dotenv
import yaml

def test_env_config():
    """測試 .env 配置"""
    print("=" * 60)
    print("測試環境變數配置 (.env)")
    print("=" * 60)
    
    # 加載 .env
    env_path = Path("config/.env")
    if not env_path.exists():
        print("❌ config/.env 文件不存在")
        return False
    
    load_dotenv(env_path)
    
    # 檢查重要變數
    configs = {
        "OV_LOG_LEVEL": "INFO",
        "DEFAULT_DEVICE": "AUTO",
        "MAX_NEW_TOKENS": "100",
        "TEMPERATURE": "0.7",
    }
    
    all_ok = True
    for key, default in configs.items():
        value = os.getenv(key, "未設置")
        status = "✓" if value != "未設置" else "✗"
        print(f"{status} {key}: {value}")
        if value == "未設置":
            all_ok = False
    
    return all_ok

def test_yaml_config():
    """測試 YAML 配置"""
    print("\n" + "=" * 60)
    print("測試 YAML 配置 (config.yaml)")
    print("=" * 60)
    
    config_path = Path("config/config.yaml")
    if not config_path.exists():
        print("❌ config/config.yaml 文件不存在")
        return False
    
    with open(config_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    print(f"✓ 項目名稱: {config['project']['name']}")
    print(f"✓ 版本: {config['project']['version']}")
    print(f"✓ 預設設備: {config['models']['default_device']}")
    print(f"✓ 模型路徑: {config['models']['storage_path']}")
    
    return True

def test_directories():
    """測試必要目錄"""
    print("\n" + "=" * 60)
    print("測試項目目錄結構")
    print("=" * 60)
    
    required_dirs = ["logs", "temp", "metrics", "models"]
    all_ok = True
    
    for dir_name in required_dirs:
        dir_path = Path(dir_name)
        exists = dir_path.exists()
        status = "✓" if exists else "✗"
        print(f"{status} {dir_name}/")
        if not exists:
            all_ok = False
    
    return all_ok

if __name__ == "__main__":
    print("\n🔍 OpenVINO GenAI 配置驗證\n")
    
    result1 = test_env_config()
    result2 = test_yaml_config()
    result3 = test_directories()
    
    print("\n" + "=" * 60)
    if result1 and result2 and result3:
        print("✅ 所有配置驗證通過！")
        print("=" * 60)
        exit(0)
    else:
        print("❌ 配置驗證失敗，請檢查上述錯誤")
        print("=" * 60)
        exit(1)
```

**執行驗證：**

```powershell
# 啟動虛擬環境
.\venv\Scripts\Activate.ps1

# 運行驗證腳本
python test_config.py
```

**預期輸出：**

```
🔍 OpenVINO GenAI 配置驗證

============================================================
測試環境變數配置 (.env)
============================================================
✓ OV_LOG_LEVEL: INFO
✓ DEFAULT_DEVICE: AUTO
✓ MAX_NEW_TOKENS: 100
✓ TEMPERATURE: 0.7

============================================================
測試 YAML 配置 (config.yaml)
============================================================
✓ 項目名稱: OpenVINO GenAI Lab
✓ 版本: 1.0.0
✓ 預設設備: CPU
✓ 模型路徑: ./models

============================================================
測試項目目錄結構
============================================================
✓ logs/
✓ temp/
✓ metrics/
✓ models/

============================================================
✅ 所有配置驗證通過！
============================================================
```

---

## 常見問題

### ❓ .env 文件顯示為亂碼

**原因：** 文件編碼不正確（UTF-8 BOM 或其他編碼）

**解決方案：**

```powershell
# 刪除舊文件
Remove-Item config\.env -Force

# 重新複製模板
Copy-Item config\.env.example config\.env

# 使用支持 UTF-8 的編輯器（如 VS Code）編輯
code config\.env
```

---

### ❓ 如何知道我的 CPU 核心數？

**PowerShell 命令：**

```powershell
# 簡單查看
$env:NUMBER_OF_PROCESSORS

# 詳細信息
Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors
```

**建議設置：**
- 實體核心 ≤ 4：設置 2-4
- 實體核心 ≥ 8：設置 4-8
- 或留空讓 OpenVINO 自動檢測

---

### ❓ DEFAULT_DEVICE 應該設置為什麼？

**建議：**

| 情況 | 設置 | 原因 |
|------|------|------|
| 不確定 | `AUTO` | 自動選擇最佳設備 |
| 只有 CPU | `CPU` | 確定性高 |
| 有獨立顯卡 | `GPU` | 性能最好 |
| 最新 Intel CPU | `AUTO` 或 `NPU` | 可能有 NPU |

---

### ❓ TEMPERATURE 應該設置多少？

**參考指南：**

| 場景 | TEMPERATURE | 說明 |
|------|-------------|------|
| 程式碼生成 | 0.1 - 0.3 | 需要精確、確定性 |
| 摘要總結 | 0.3 - 0.5 | 中等精確度 |
| 對話聊天 | 0.6 - 0.8 | 平衡（推薦） |
| 創意寫作 | 0.8 - 1.0 | 高隨機性、多樣性 |

---

### ❓ 如何為不同任務使用不同配置？

**方案 1：使用多個 .env 文件**

```powershell
# 創建不同配置
Copy-Item config\.env config\.env.dev
Copy-Item config\.env config\.env.prod

# 使用時指定
$env:ENV_FILE="config/.env.dev"
python scripts/run_inference.py
```

**方案 2：使用命令行參數覆蓋**

```powershell
python scripts/run_inference.py --temperature 0.9 --max-tokens 200
```

---

## 故障排除

### ❌ 無法加載 .env 文件

**症狀：**
```python
KeyError: 'DEFAULT_DEVICE'
```

**原因：** `.env` 文件不存在或路徑錯誤

**解決方案：**

```powershell
# 確認文件存在
Test-Path config\.env

# 如果不存在，複製模板
Copy-Item config\.env.example config\.env

# 確認內容
Get-Content config\.env -Encoding UTF8 | Select-Object -First 10
```

---

### ❌ YAML 語法錯誤

**症狀：**
```
yaml.scanner.ScannerError: while scanning for the next token
```

**原因：** YAML 縮排或語法錯誤

**解決方案：**

1. **檢查縮排（必須使用空格，不能用 Tab）**
   
2. **使用 YAML 驗證工具：**
   ```powershell
   pip install pyyaml
   python -c "import yaml; yaml.safe_load(open('config/config.yaml'))"
   ```

3. **常見錯誤：**
   ```yaml
   # ❌ 錯誤：使用 Tab
   models:
   	default_device: CPU
   
   # ✓ 正確：使用 2 或 4 個空格
   models:
     default_device: CPU
   ```

---

### ❌ 環境變數未生效

**症狀：** 修改 `.env` 後程序仍使用舊值

**原因：** 環境變數已被系統環境變數覆蓋

**解決方案：**

```powershell
# 檢查系統環境變數
[System.Environment]::GetEnvironmentVariable("DEFAULT_DEVICE", "User")

# 如果有衝突，刪除系統變數
[System.Environment]::SetEnvironmentVariable("DEFAULT_DEVICE", $null, "User")

# 重啟終端和虛擬環境
```

---

## 下一步

✅ 完成此階段後，您應該已經：
- ✅ 創建了 `config/.env` 本地配置文件
- ✅ 理解各配置參數的含義和用途
- ✅ 創建了必要的項目目錄（logs, temp, metrics）
- ✅ 驗證配置正確無誤

**繼續下一階段：**
- 📖 [第 7 階段：推理設置](STAGE_7_GUIDE_NEW.md) - 運行 AI 模型推理
- 📖 [返回設置指南](README.md) - 查看完整設置流程

---

## 相關資源

- 📖 [完整設置流程](SETUP_PROGRESS.md) - 所有 9 個階段的詳細說明
- ⚙️ [Windows 設置步驟](SETUP_WINDOWS.md) - 具體的操作說明
- 🆘 [故障排除](../TROUBLESHOOTING.md) - 常見問題解決
- 🔗 [python-dotenv 文檔](https://pypi.org/project/python-dotenv/) - .env 文件處理庫
- 🔗 [YAML 語法指南](https://yaml.org/spec/1.2.2/) - YAML 官方規範

---

**版本資訊：**
- 文檔版本：1.0.0
- 最後更新：2026-01-02
- 適用於：Windows 10/11, OpenVINO 2025.4+
