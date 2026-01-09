"""
Llama 模型快速開始
使用 OpenVINO GenAI API 進行簡單問答

執行方式：
    python examples/llama_quick_start.py
    python examples/llama_quick_start.py --device GPU
"""

import openvino_genai as ov_genai
import sys
import os

def main():
    """快速開始範例"""
    # 設定
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"
    
    # 檢查命令行參數
    if len(sys.argv) > 1:
        if sys.argv[1] in ["--device", "-d"]:
            device = sys.argv[2] if len(sys.argv) > 2 else "CPU"
        else:
            device = sys.argv[1]
    
    # 檢查模型是否存在
    if not os.path.exists(model_path):
        print(f"❌ 錯誤：模型不存在 {model_path}")
        print("請先下載模型，參考 LLAMA_SETUP_PLAN.md")
        sys.exit(1)
    
    print("=" * 70)
    print("🦙 Llama 快速開始 - OpenVINO GenAI")
    print("=" * 70)
    print(f"📁 模型路徑: {model_path}")
    print(f"🖥️  使用設備: {device}")
    print("=" * 70 + "\n")
    
    try:
        # 載入模型
        print("⏳ 載入模型中...")
        pipe = ov_genai.LLMPipeline(model_path, device)
        print("✅ 模型載入完成！\n")
        
        # 測試問題
        prompt = "What is artificial intelligence?"
        
        print(f"💬 問題: {prompt}\n")
        print("🤖 Llama 回答:")
        print("-" * 70)
        
        # 生成回答
        result = pipe.generate(prompt, max_new_tokens=100)
        print(result)
        
        print("-" * 70)
        print("\n✅ 推理完成！")
        
    except Exception as e:
        print(f"\n❌ 錯誤: {e}")
        print("\n疑難排解:")
        print("1. 確認模型路徑正確")
        print("2. 確認 OpenVINO GenAI 已安裝")
        print("3. 如使用 GPU，確認驅動已安裝")
        sys.exit(1)

if __name__ == "__main__":
    main()
