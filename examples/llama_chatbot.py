"""
Llama 交互式聊天機器人
使用 OpenVINO GenAI API

執行方式：
    python examples/llama_chatbot.py          # CPU 模式
    python examples/llama_chatbot.py GPU      # GPU 模式
    python examples/llama_chatbot.py --help   # 顯示幫助
"""

import openvino_genai as ov_genai
import sys
import os

def print_help():
    """顯示幫助訊息"""
    help_text = """
🦙 Llama 聊天機器人 - 使用說明

用法:
    python examples/llama_chatbot.py [設備]

參數:
    設備    推理設備 (CPU, GPU, NPU)，預設為 CPU

範例:
    python examples/llama_chatbot.py           # 使用 CPU
    python examples/llama_chatbot.py GPU       # 使用 GPU
    python examples/llama_chatbot.py --help    # 顯示此幫助

聊天指令:
    - 直接輸入問題開始對話
    - 輸入 'quit', 'exit', 'bye' 退出
    - Ctrl+C 也可以退出
    """
    print(help_text)

def chat_bot(model_path: str, device: str = "CPU"):
    """交互式聊天機器人
    
    Args:
        model_path: 模型路徑
        device: 推理設備 (CPU, GPU, NPU)
    """
    print("=" * 70)
    print("🦙 Llama 聊天機器人 - OpenVINO GenAI")
    print("=" * 70)
    print(f"📁 模型: {model_path}")
    print(f"🖥️  設備: {device}")
    print("=" * 70)
    
    try:
        # 載入模型
        print("\n⏳ 載入模型中...")
        pipe = ov_genai.LLMPipeline(model_path, device)
        print("✅ 模型載入完成！\n")
        
        print("=" * 70)
        print("💬 開始對話（輸入 'quit' 退出）")
        print("=" * 70 + "\n")
        
        # 對話循環
        while True:
            # 獲取用戶輸入
            try:
                user_input = input("You: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\n\n👋 再見！")
                break
            
            # 檢查是否為空
            if not user_input:
                continue
            
            # 檢查退出指令
            if user_input.lower() in ['quit', 'exit', 'bye', 'q']:
                print("\n👋 再見！")
                break
            
            # 生成回應
            print("\n🦙 Llama: ", end="", flush=True)
            try:
                response = pipe.generate(
                    user_input,
                    max_new_tokens=150,
                    temperature=0.7,
                    top_p=0.9
                )
                print(response + "\n")
            except Exception as e:
                print(f"\n❌ 生成錯誤: {e}\n")
                
    except FileNotFoundError:
        print(f"\n❌ 錯誤：模型不存在 {model_path}")
        print("請先下載模型，參考 LLAMA_SETUP_PLAN.md")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 錯誤: {e}")
        print("\n疑難排解:")
        print("1. 確認模型路徑正確")
        print("2. 如使用 GPU，確認驅動已安裝")
        print("3. 檢查可用設備: python -c \"import openvino as ov; print(ov.Core().available_devices)\"")
        sys.exit(1)

def main():
    """主函數"""
    # 預設設定
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"
    
    # 解析命令行參數
    if len(sys.argv) > 1:
        if sys.argv[1] in ["--help", "-h", "help"]:
            print_help()
            sys.exit(0)
        else:
            device = sys.argv[1].upper()
    
    # 檢查模型是否存在
    if not os.path.exists(model_path):
        print(f"❌ 錯誤：模型不存在 {model_path}")
        print("\n請先下載模型:")
        print("  python scripts/download_hf_model.py --repo-id 'OpenVINO/open_llama_7b_v2-int4-ov'")
        print("\n或參考 LLAMA_SETUP_PLAN.md 獲取更多資訊")
        sys.exit(1)
    
    # 啟動聊天機器人
    chat_bot(model_path, device)

if __name__ == "__main__":
    main()
