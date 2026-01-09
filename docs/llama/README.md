# 🦙 Llama 專案總覽

> **建立日期：** 2026-01-09  
> **狀態：** ✅ 完成且可用

---

## 📁 專案結構

```
openvino-lab/
│
├── 📚 Llama 計畫文檔（新建立）
│   ├── SETUP_PLAN.md                   ⭐ 主要指南（完整 7 章節）
│   ├── QUICK_REFERENCE.md              ⚡ 快速參考卡片
│   ├── SETUP_COMPLETE.md               ✅ 完成報告
│   ├── AI_AGENT_PLAN.md                🤖 AI Agent 詳細計劃
│   ├── AI_AGENT_GUIDE.md               🎯 AI Agent 使用指南
│   ├── AI_AGENT_COMPLETION_REPORT.md   ✅ AI Agent 完成報告
│   ├── AI_AGENT_TEST_GUIDE.md          🧪 AI Agent 測試指南
│   └── README.md                       📖 本文件
│
├── 🔧 Llama 範例程式（新建立）
│   ├── examples/check_llama_env.py           ✅ 環境檢查工具
│   ├── examples/llama_quick_start.py         🚀 快速開始
│   ├── examples/llama_chatbot.py             💬 交互式聊天
│   ├── examples/llama_batch_inference.py     📊 批量推理
│   └── examples/llama_agent.py               🤖 AI Agent（新！）
│
├── 🤖 AI Agent 組件（新建立）
│   └── examples/agent/                       🎯 Agent 套件
│       ├── safety_checker.py                 🔒 安全檢查器
│       ├── intent_recognizer.py              🧠 意圖識別器
│       ├── tool_router.py                    🔀 工具路由器
│       ├── logger.py                         📝 日誌系統
│       └── executors/                        ⚙️ 執行器
│           ├── command.py                    💻 命令執行器
│           └── file.py                       📁 文件操作器
│
├── 🦙 Llama 模型（已就緒）
│   └── models/open_llama_7b_v2-int4-ov/      ✅ Open Llama 7B INT4
│
└── 🛠️ 現有工具（可直接使用）
    ├── scripts/run_inference_simple.py        💬 簡單推理
    ├── scripts/download_hf_model.py          ⬇️ 模型下載
    └── scripts/download_model_interactive.ps1 🎯 互動式下載
```

---

## 📚 文檔指南

### 1. SETUP_PLAN.md ⭐（主要文檔）
**完整的設置和使用計畫**

#### 包含內容：
- ✅ **第 1 章：環境檢查** - 驗證所有依賴（6/6 通過）
- ⚙️ **第 2 章：環境設置補充** - 啟動虛擬環境、檢查設備
- 🦙 **第 3 章：Llama 模型準備** - 模型下載、轉換
- 🔧 **第 4 章：OpenVINO GenAI API** - 詳細 API 說明
- 💡 **第 5 章：實作範例** - 4 個完整範例（含程式碼）
- 🚀 **第 6 章：進階使用** - 效能優化、Web 整合
- 🐛 **第 7 章：疑難排解** - 常見問題解答

#### 適合：
- 第一次使用 Llama 模型
- 需要完整理解整個流程
- 想要深入學習 OpenVINO GenAI API

**閱讀時間：** 15-20 分鐘

---

### 2. QUICK_REFERENCE.md ⚡（快速參考）
**快速指令參考卡片**

#### 包含內容：
- 🚀 常用指令（啟動、檢查、執行）
- 🔧 Python API 速查
- 📦 模型下載指令
- 🐛 快速疑難排解
- 📊 效能測試指令

#### 適合：
- 已經設置完成，需要快速查詢指令
- 想要打印出來放在桌上
- 需要快速複製貼上指令

**閱讀時間：** 2-3 分鐘

---

### 3. SETUP_COMPLETE.md ✅（完成報告）
**設置完成狀態報告**

#### 包含內容：
- ✅ 已完成的工作清單
- 📊 環境檢查結果
- 🎯 下一步建議
- 💡 使用技巧
- 🐛 常見問題 Q&A

#### 適合：
- 想要了解專案完成了什麼
- 檢查還缺少什麼功能
- 規劃下一步學習路徑

**閱讀時間：** 5-10 分鐘

---

## 🔧 範例程式說明

### 1. check_llama_env.py ✅
**環境檢查工具**

```powershell
.\venv\Scripts\python.exe examples\check_llama_env.py
```

**功能：**
- 檢查 Python、OpenVINO、GenAI 版本
- 驗證 Llama 模型完整性
- 列出可用推理設備
- 提供下一步建議

**適合：** 每次使用前先執行一次

---

### 2. llama_quick_start.py 🚀
**快速開始範例**

```powershell
# CPU
.\venv\Scripts\python.exe examples\llama_quick_start.py

# GPU
.\venv\Scripts\python.exe examples\llama_quick_start.py GPU
```

**功能：**
- 單一問題快速測試
- 驗證模型載入
- 測試推理功能

**適合：** 第一次使用，驗證環境

---

### 3. llama_chatbot.py 💬
**交互式聊天機器人**

```powershell
.\venv\Scripts\python.exe examples\llama_chatbot.py
```

**功能：**
- 持續對話模式
- 可配置生成參數（temperature, top_p）
- 友善的使用者介面
- 支援多種退出方式（quit, exit, Ctrl+C）

**適合：** 日常使用、測試不同提示詞

---

### 4. llama_batch_inference.py 📊
**批量推理測試**

```powershell
# 預設問題集
.\venv\Scripts\python.exe examples\llama_batch_inference.py

# 自訂問題
.\venv\Scripts\python.exe examples\llama_batch_inference.py --custom

# GPU 模式
.\venv\Scripts\python.exe examples\llama_batch_inference.py GPU
```

**功能：**
- 批量處理多個問題
- 效能統計（時間、tokens、速度）
- 結果匯出功能
- 預設或自訂問題集

**適合：** 效能測試、批量處理任務

---

### 5. llama_agent.py 🤖 **（新！AI Agent）**
**智能助手，可執行系統命令**

```powershell
# 使用批處理腳本啟動（推薦）
.\run_agent.bat

# 或使用命令行
.\venv\Scripts\Activate.ps1
python examples\llama_agent.py
```

**功能：**
- 🤖 自然語言理解（使用 Llama）
- 💻 執行 shell 命令
- 📁 讀寫文件、列出目錄
- 🐍 運行 Python 代碼
- 🔒 多層安全保護
- 📝 完整操作日誌

**示例對話：**
```
You: run dir
Agent: ✓ Command executed successfully: [目錄列表]

You: read README.md
Agent: ✓ File content (7084 bytes): [內容]

You: list examples folder
Agent: ✓ Directory: examples (12 items) ...

You: calculate 2+2
Agent: ✓ Python executed successfully: 4
```

**適合：** 想要 AI 幫助執行系統任務、自動化工作

**📖 詳細文檔：**
- [AI Agent 使用指南](AI_AGENT_GUIDE.md)
- [AI Agent 詳細計劃](AI_AGENT_PLAN.md)
- [測試指南](AI_AGENT_TEST_GUIDE.md)
- [完成報告](AI_AGENT_COMPLETION_REPORT.md)

---

## 🎯 使用流程建議

### 新手流程（第一次使用）

```powershell
# 步驟 1：啟動環境
.\venv\Scripts\Activate.ps1

# 步驟 2：檢查環境
.\venv\Scripts\python.exe examples\check_llama_env.py

# 步驟 3：快速測試
.\venv\Scripts\python.exe examples\llama_quick_start.py

# 步驟 4：試試聊天
.\venv\Scripts\python.exe examples\llama_chatbot.py
```

**預計時間：** 5-10 分鐘

---

### 日常使用（已熟悉）

```powershell
# 快速啟動聊天
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe examples\llama_chatbot.py GPU
```

**預計時間：** < 1 分鐘

---

### 效能測試

```powershell
# 批量測試 CPU vs GPU
.\venv\Scripts\python.exe examples\llama_batch_inference.py CPU
.\venv\Scripts\python.exe examples\llama_batch_inference.py GPU
```

**預計時間：** 5-10 分鐘

---

## 📊 環境狀態

### ✅ 已驗證（2026-01-09）

| 檢查項目 | 狀態 | 版本/詳情 |
|---------|------|-----------|
| Python | ✅ | 3.11.4 |
| Virtual Environment | ✅ | venv |
| OpenVINO | ✅ | 2025.4.1 |
| OpenVINO GenAI | ✅ | 2025.4.1.0 |
| Transformers | ✅ | 4.57.3 |
| Llama 模型 | ✅ | open_llama_7b_v2-int4-ov |
| 可用設備 | ✅ | CPU, GPU.0, GPU.1, NPU |

**結論：** 🎉 環境完整，可直接使用！

---

## 🚀 快速啟動指令

### 最快速測試（使用現有腳本）

```powershell
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe scripts\run_inference_simple.py demo
```

### 使用新建立的範例

```powershell
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe examples\llama_quick_start.py
```

---

## 📖 學習路徑

### Level 1: 入門（今天）
- [ ] 閱讀 `QUICK_REFERENCE.md`（3 分鐘）
- [ ] 執行 `check_llama_env.py`（驗證環境）
- [ ] 執行 `llama_quick_start.py`（第一次推理）
- [ ] 試用 `llama_chatbot.py`（交互式聊天）

### Level 2: 進階（本週）
- [ ] 閱讀 `SETUP_PLAN.md` 第 4-6 章
- [ ] 測試不同 temperature 參數
- [ ] 執行批量推理測試
- [ ] 比較 CPU vs GPU 效能

### Level 3: 高級（下週）
- [ ] 下載其他 Llama 模型
- [ ] 客製化聊天機器人
- [ ] 整合 Streamlit 或 FastAPI
- [ ] 實作 RAG（檢索增強生成）

---

## 💡 使用技巧

### 快速切換設備
```python
device = "GPU"  # 改成 "CPU" 或 "NPU"
pipe = ov_genai.LLMPipeline(model_path, device)
```

### 調整回答風格
```python
# 正式、準確（適合問答）
result = pipe.generate(prompt, temperature=0.2)

# 一般對話
result = pipe.generate(prompt, temperature=0.7)

# 創意、隨機（適合寫作）
result = pipe.generate(prompt, temperature=0.9)
```

### 控制回答長度
```python
# 短回答（約 50 個詞）
result = pipe.generate(prompt, max_new_tokens=50)

# 中等（約 100 個詞）
result = pipe.generate(prompt, max_new_tokens=100)

# 長回答（約 200 個詞）
result = pipe.generate(prompt, max_new_tokens=200)
```

---

## 🔗 相關資源

### 專案文檔
- **主 README：** `README.md`
- **快速開始：** `QUICKSTART.md`
- **下載指南：** `DOWNLOAD_QUICK_REFERENCE.md`

### 官方資源
- [OpenVINO GenAI 文檔](https://openvinotoolkit.github.io/openvino.genai/)
- [OpenVINO GenAI GitHub](https://github.com/openvinotoolkit/openvino.genai)
- [Meta Llama](https://ai.meta.com/llama/)

---

## 📞 需要幫助？

### 查看文檔
1. **快速問題** → `QUICK_REFERENCE.md`
2. **詳細說明** → `SETUP_PLAN.md`
3. **疑難排解** → `SETUP_PLAN.md` 第 7 章

### 在線支援
- [OpenVINO 論壇](https://community.intel.com/t5/Intel-Distribution-of-OpenVINO/bd-p/distribution-openvino-toolkit)
- [GitHub Issues](https://github.com/openvinotoolkit/openvino.genai/issues)

---

## ✨ 總結

### 您現在擁有：
✅ 完整的環境（已驗證）  
✅ 3 個詳細的文檔指南  
✅ 4 個實用的範例程式  
✅ Open Llama 7B 模型（可用）  
✅ CPU、GPU、NPU 支援

### 可以做的事：
🚀 快速問答測試  
💬 交互式聊天對話  
📊 批量推理處理  
⚡ CPU/GPU 效能比較  
🎨 客製化應用開發

### 下一步：
```powershell
.\venv\Scripts\Activate.ps1
.\venv\Scripts\python.exe examples\llama_quick_start.py
```

---

**專案狀態：** ✅ 完成且可用  
**最後更新：** 2026-01-09  
**環境檢查：** 🎉 6/6 通過

🦙✨ 開始您的 Llama 之旅吧！
