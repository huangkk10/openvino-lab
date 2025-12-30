"""
OpenVINO GenAI 簡單推理範例

這個腳本展示如何使用 OpenVINO GenAI 進行文本生成。
運行前請確保已經下載並轉換了模型。

使用方法：
    python simple_inference.py [model_path] [device]

範例：
    python simple_inference.py ./models/TinyLlama-1.1B-int4 CPU
    python simple_inference.py ./models/Llama-2-7b-int4 GPU
"""

import sys
import os

def run_simple_inference(model_path: str, device: str = "CPU"):
    """
    運行簡單的推理測試
    
    Args:
        model_path: 模型路徑（OpenVINO IR 格式）
        device: 推理設備 (CPU, GPU, NPU)
    """
    try:
        import openvino_genai as ov_genai
        
        print(f"正在載入模型: {model_path}")
        print(f"使用設備: {device}\n")
        
        # 載入模型
        pipe = ov_genai.LLMPipeline(model_path, device)
        
        # 測試問題
        prompts = [
            "What is OpenVINO?",
            "Explain artificial intelligence in simple terms.",
            "Tell me an interesting fact."
        ]
        
        for i, prompt in enumerate(prompts, 1):
            print(f"{'='*60}")
            print(f"測試 {i}/{len(prompts)}")
            print(f"問題: {prompt}")
            print(f"{'='*60}")
            
            # 生成回應
            result = pipe.generate(prompt, max_new_tokens=100)
            
            print(f"回應:\n{result}\n")
        
        print("✅ 推理測試完成！")
        
    except FileNotFoundError:
        print(f"❌ 錯誤: 模型不存在於 {model_path}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 錯誤: {e}")
        sys.exit(1)

def main():
    """主函數"""
    # 檢查模型是否存在
    default_model = "./models/TinyLlama-1.1B-int4"
    
    if len(sys.argv) > 1:
        model_path = sys.argv[1]
    else:
        model_path = default_model
    
    if not os.path.exists(model_path):
        print(f"❌ 模型不存在: {model_path}\n")
        print("請先轉換模型。參考 docs/MODELS.md\n")
        print("範例命令:")
        print("optimum-cli export openvino \\")
        print("  --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \\")
        print("  --weight-format int4 \\")
        print("  --output-dir ./models/TinyLlama-1.1B-int4 \\")
        print("  --trust-remote-code")
        sys.exit(1)
    
    # 設備選擇
    device = "CPU"
    if len(sys.argv) > 2:
        device = sys.argv[2]
    
    # 運行推理
    run_simple_inference(model_path, device)

if __name__ == "__main__":
    print("=" * 60)
    print("OpenVINO GenAI 簡單推理範例")
    print("=" * 60 + "\n")
    
    main()
