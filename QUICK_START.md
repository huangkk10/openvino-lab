# 🚀 快速開始指南

## 現在您的專案已準備就緒！

### 📍 重要檔案位置參考

**起點：** 打開根目錄的 `README.md`

**然後按順序查看：**

1. **`docs/SETUP_WINDOWS.md`** ⚙️
   - Windows 環境設置步驟
   - 安裝 Visual C++ Redistributable（必須！）
   - 虛擬環境設置

2. **`docs/README.md`** 📖
   - OpenVINO GenAI 功能概述
   - 支援的 7 種 AI 場景
   - 推理設備選擇（CPU/GPU/NPU）
   - 優化和性能最佳實踐

3. **`docs/MODELS.md`** 🤖
   - 模型轉換教學（10+ 範例）
   - 不同模型的推薦配置
   - 量化選擇指南
   - 本地模型管理

4. **`docs/TROUBLESHOOTING.md`** 🔧
   - 10+ 常見問題及解決方案
   - 調試技巧
   - 環境驗證檢查清單

### 🛠️ 工具和指令

```powershell
# 1. 測試環境（驗證安裝）
python scripts/test_openvino.py

# 2. 自動設置（可選）
.\scripts\setup.ps1

# 3. 轉換模型（範例）
optimum-cli export openvino --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 --weight-format int4 --output-dir ./models/TinyLlama-1.1B-int4 --trust-remote-code

# 4. 運行推理
python examples/simple_inference.py ./models/TinyLlama-1.1B-int4
```

### 📂 檔案地圖

```
根目錄/
├─ README.md                ← 開始這裡
├─ PROJECT_STRUCTURE.md     ← 了解組織
├─ COMPLETION_REPORT.md     ← 完成報告
│
├─ docs/                    ← 📚 文檔
│  ├─ SETUP_WINDOWS.md      (Windows 設置)
│  ├─ README.md             (功能指南)
│  ├─ MODELS.md             (模型轉換)
│  └─ TROUBLESHOOTING.md    (問題解決)
│
├─ scripts/                 ← 🛠️ 工具
│  ├─ test_openvino.py      (環境測試)
│  └─ setup.ps1             (自動設置)
│
├─ examples/                ← 💡 範例
│  └─ simple_inference.py   (推理範例)
│
├─ models/                  ← 🤖 模型
│  └─ （您的模型放這裡）
│
├─ config/                  ← ⚙️ 配置
│  ├─ .env.example          (環境變量範本)
│  └─ config.yaml           (項目配置)
│
└─ venv/                    ← 虛擬環境
```

### ✨ 新功能清單

✅ **5 個組織良好的目錄**
✅ **7 份詳細文檔** (4000+ 行)
✅ **2 個實用工具腳本**
✅ **完整的配置系統**
✅ **可直接運行的範例**
✅ **專業的項目結構**
✅ **100+ 範例命令**

### 🎯 下一步

#### 立即做：
1. 閱讀 `docs/SETUP_WINDOWS.md`
2. 安裝 Visual C++ Redistributable
3. 運行 `python scripts/test_openvino.py`

#### 然後做：
4. 閱讀 `docs/MODELS.md`
5. 轉換模型
6. 運行推理

#### 深入學習：
7. 閱讀 `docs/README.md` 了解功能
8. 參考 `docs/TROUBLESHOOTING.md` 解決問題
9. 查看 `PROJECT_STRUCTURE.md` 了解組織

### 💡 提示

- 🔖 在瀏覽器中打開 README.md，使用超連結導航
- 📌 將常用命令複製到記事本備用
- 💾 定期備份 `config/.env` 和 `models/` 目錄
- 🔄 運行 `pip freeze > requirements.txt` 以更新依賴列表

### 🆘 需要幫助？

1. **環境問題** → `docs/SETUP_WINDOWS.md` 和 `docs/TROUBLESHOOTING.md`
2. **模型問題** → `docs/MODELS.md`
3. **功能問題** → `docs/README.md`
4. **通用問題** → `docs/TROUBLESHOOTING.md`

### 📞 資源連結

- [OpenVINO GenAI 官方文檔](https://openvinotoolkit.github.io/openvino.genai/)
- [Hugging Face Models](https://huggingface.co/models)
- [GitHub Issues](https://github.com/openvinotoolkit/openvino.genai/issues)

---

**準備好開始了嗎？** 🚀

👉 打開 `docs/SETUP_WINDOWS.md` 開始您的 OpenVINO GenAI 之旅！
