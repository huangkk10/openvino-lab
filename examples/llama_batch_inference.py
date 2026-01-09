"""
Llama 批量推理測試
使用 OpenVINO GenAI API 測試多個問題

執行方式：
    python examples/llama_batch_inference.py          # CPU 模式
    python examples/llama_batch_inference.py GPU      # GPU 模式
    python examples/llama_batch_inference.py --custom # 自訂問題
"""

import openvino_genai as ov_genai
import sys
import os
import time
from typing import List, Dict

def get_default_prompts() -> List[str]:
    """獲取預設測試問題集"""
    return [
        "What is machine learning?",
        "Explain the concept of neural networks in simple terms.",
        "What are the benefits of artificial intelligence?",
        "How does deep learning differ from traditional machine learning?",
        "What is the difference between AI and ML?"
    ]

def get_custom_prompts() -> List[str]:
    """獲取自訂問題集"""
    print("\n" + "=" * 70)
    print("📝 輸入自訂問題（每行一個問題，輸入空行結束）")
    print("=" * 70 + "\n")
    
    prompts = []
    while True:
        try:
            line = input(f"問題 {len(prompts) + 1}: ").strip()
            if not line:
                break
            prompts.append(line)
        except (EOFError, KeyboardInterrupt):
            print("\n")
            break
    
    return prompts if prompts else get_default_prompts()

def batch_inference(
    model_path: str,
    prompts: List[str],
    device: str = "CPU",
    max_tokens: int = 100
) -> List[Dict]:
    """執行批量推理
    
    Args:
        model_path: 模型路徑
        prompts: 問題列表
        device: 推理設備
        max_tokens: 最大生成 token 數
        
    Returns:
        結果列表，包含問題、答案和執行時間
    """
    print("=" * 70)
    print("🦙 Llama 批量推理測試")
    print("=" * 70)
    print(f"📁 模型: {model_path}")
    print(f"🖥️  設備: {device}")
    print(f"📊 問題數量: {len(prompts)}")
    print(f"🔢 最大 tokens: {max_tokens}")
    print("=" * 70 + "\n")
    
    try:
        # 載入模型
        print("⏳ 載入模型中...")
        start_load = time.time()
        pipe = ov_genai.LLMPipeline(model_path, device)
        load_time = time.time() - start_load
        print(f"✅ 模型載入完成！(耗時: {load_time:.2f} 秒)\n")
        
        print("=" * 70)
        print("🚀 開始批量推理")
        print("=" * 70 + "\n")
        
        results = []
        total_time = 0
        total_tokens = 0
        
        # 逐個處理問題
        for i, prompt in enumerate(prompts, 1):
            print(f"[{i}/{len(prompts)}] {prompt}")
            print("-" * 70)
            
            # 執行推理
            start_time = time.time()
            try:
                result = pipe.generate(
                    prompt,
                    max_new_tokens=max_tokens,
                    temperature=0.7,
                    top_p=0.9
                )
                elapsed = time.time() - start_time
                
                # 估算 token 數（簡單估計：字數 / 0.75）
                estimated_tokens = len(result.split()) / 0.75
                
                print(f"回答: {result}")
                print(f"⏱️  耗時: {elapsed:.2f} 秒")
                print(f"🔢 約 {int(estimated_tokens)} tokens")
                print(f"⚡ 速度: {estimated_tokens/elapsed:.1f} tokens/秒\n")
                
                results.append({
                    "index": i,
                    "prompt": prompt,
                    "result": result,
                    "time": elapsed,
                    "tokens": int(estimated_tokens),
                    "tokens_per_sec": estimated_tokens / elapsed
                })
                
                total_time += elapsed
                total_tokens += estimated_tokens
                
            except Exception as e:
                print(f"❌ 錯誤: {e}\n")
                results.append({
                    "index": i,
                    "prompt": prompt,
                    "result": None,
                    "error": str(e)
                })
        
        # 顯示統計
        print("=" * 70)
        print("📊 統計結果")
        print("=" * 70)
        
        successful = [r for r in results if "error" not in r]
        failed = [r for r in results if "error" in r]
        
        print(f"\n✅ 成功: {len(successful)}/{len(prompts)}")
        if failed:
            print(f"❌ 失敗: {len(failed)}/{len(prompts)}")
        
        if successful:
            print(f"\n⏱️  總耗時: {total_time:.2f} 秒")
            print(f"📈 平均每題: {total_time/len(successful):.2f} 秒")
            print(f"🔢 總 tokens: {int(total_tokens)}")
            print(f"⚡ 平均速度: {total_tokens/total_time:.1f} tokens/秒")
            
            # 最快和最慢
            fastest = min(successful, key=lambda x: x["time"])
            slowest = max(successful, key=lambda x: x["time"])
            
            print(f"\n🚀 最快: {fastest['time']:.2f}秒 (問題 {fastest['index']})")
            print(f"🐌 最慢: {slowest['time']:.2f}秒 (問題 {slowest['index']})")
        
        print("=" * 70 + "\n")
        
        return results
        
    except FileNotFoundError:
        print(f"\n❌ 錯誤：模型不存在 {model_path}")
        print("請先下載模型，參考 LLAMA_SETUP_PLAN.md")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 錯誤: {e}")
        sys.exit(1)

def main():
    """主函數"""
    # 預設設定
    model_path = "./models/open_llama_7b_v2-int4-ov"
    device = "CPU"
    use_custom = False
    
    # 解析命令行參數
    if len(sys.argv) > 1:
        arg = sys.argv[1].upper()
        if arg in ["--CUSTOM", "-C", "CUSTOM"]:
            use_custom = True
        elif arg in ["--HELP", "-H", "HELP"]:
            print("""
🦙 Llama 批量推理測試 - 使用說明

用法:
    python examples/llama_batch_inference.py [設備|選項]

參數:
    設備        推理設備 (CPU, GPU, NPU)，預設為 CPU
    --custom    使用自訂問題集

範例:
    python examples/llama_batch_inference.py           # 使用預設問題集 (CPU)
    python examples/llama_batch_inference.py GPU       # 使用 GPU
    python examples/llama_batch_inference.py --custom  # 自訂問題
            """)
            sys.exit(0)
        else:
            device = arg
    
    # 檢查模型
    if not os.path.exists(model_path):
        print(f"❌ 錯誤：模型不存在 {model_path}")
        print("請先下載模型，參考 LLAMA_SETUP_PLAN.md")
        sys.exit(1)
    
    # 獲取問題集
    prompts = get_custom_prompts() if use_custom else get_default_prompts()
    
    if not prompts:
        print("❌ 沒有問題可處理")
        sys.exit(1)
    
    # 執行批量推理
    results = batch_inference(model_path, prompts, device)
    
    # 可選：保存結果
    save_results = input("是否保存結果到檔案？ (y/N): ").strip().lower()
    if save_results == 'y':
        import json
        output_file = f"batch_results_{int(time.time())}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"\n💾 結果已保存到: {output_file}")

if __name__ == "__main__":
    main()
