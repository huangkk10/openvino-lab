# 🚀 三步快速開始執行 Benchmark

**選擇你的方式：**

## ⭐ 最簡單（推薦）
```
雙擊：run_benchmark.bat
```
完全自動化，無需打開 PowerShell。

---

## 💻 PowerShell 版本

```powershell
cd C:\Users\svd\codes\openvino-lab
.\setup_and_run_benchmark.ps1
```

自訂參數（可選）：
```powershell
.\setup_and_run_benchmark.ps1 -NumIter 3 -Device GPU
```

---

## 📖 詳細說明

查看 **ONE_CLICK_QUICK_START.md** 了解：
- 各種執行方式的詳細對比
- 參數自訂方法
- 故障排除

---

## ✅ 一鍵設定環境變數（可選）

如果要永久設定環境變數（一次性，之後直接執行）：

在管理員 PowerShell 中執行：
```powershell
[Environment]::SetEnvironmentVariable('PATH', 'C:\Users\svd\codes\openvino-lab\nvme_dsm_test\openvino_cpp_runtime\bin;' + [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')
```

完成後，新開 PowerShell 可直接執行 benchmark。

---

**狀態：** ✅ 所有腳本已準備好，可直接使用！
