"""
快速測試 AI Agent 執行批處理文件
"""

import sys
sys.path.insert(0, '.')

print("=== AI Agent Quick Test ===\n")

# 模擬 Agent 執行
from examples.llama_agent import LlamaAgent

print("初始化 Agent...")
agent = LlamaAgent()

print("\n測試命令: run examples\\run_llama_chatbot.bat")
result = agent.process_input("run examples\\run_llama_chatbot.bat")

print(f"\n結果:\n{result}")

print("\n=== 測試完成 ===")
