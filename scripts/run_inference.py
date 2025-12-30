#!/usr/bin/env python3
"""
TinyLlama 推理示例 - 使用 Transformers 庫
使用方式：python scripts/run_inference.py
"""

import os
import sys
from pathlib import Path

# 添加項目根目錄到路徑
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM


def load_env_config():
    """從 .env 文件加載配置"""
    from dotenv import load_dotenv
    
    env_file = PROJECT_ROOT / "config" / ".env"
    load_dotenv(env_file)
    
    config = {
        'device': os.getenv('DEFAULT_DEVICE', 'CPU'),
        'model_path': os.getenv('DEFAULT_MODEL_PATH', './models/TinyLlama-1.1B-int4'),
        'max_tokens': int(os.getenv('MAX_NEW_TOKENS', '100')),
        'temperature': float(os.getenv('TEMPERATURE', '0.7')),
        'top_p': float(os.getenv('TOP_P', '0.9')),
    }
    
    return config


def run_inference(prompt: str, model_path: str, device: str = 'CPU', **kwargs):
    """
    執行推理
    
    Args:
        prompt: 輸入提示文本
        model_path: 模型路徑
        device: 推理設備 (CPU, GPU, NPU)
        **kwargs: 其他推理參數 (max_tokens, temperature, top_p)
    
    Returns:
        生成的文本
    """
    
    print(f"\n{'='*60}")
    print(f"{'TinyLlama 推理示例':^60}")
    print(f"{'='*60}\n")
    
    # 驗證模型路徑
    model_dir = Path(model_path)
    if not model_dir.exists():
        print(f"❌ 錯誤：模型路徑不存在 - {model_path}")
        print(f"   請先運行 Stage 7️⃣ 下載模型")
        print(f"   命令：.\scripts\prepare_models.ps1")
        return None
    
    print(f"📁 模型路徑: {model_path}")
    print(f"💻 推理設備: {device}")
    print(f"📝 輸入提示: {prompt}")
    print(f"⚙️  參數設置:")
    for key, value in kwargs.items():
        print(f"   - {key}: {value}")
    print()
    
    try:
        # 設置設備
        if device.upper() == 'GPU' and torch.cuda.is_available():
            torch_device = 'cuda'
        else:
            torch_device = 'cpu'
        
        # 加載分詞器
        print("⏳ 正在加載分詞器...")
        tokenizer = AutoTokenizer.from_pretrained(model_dir, trust_remote_code=True)
        print("✅ 分詞器加載成功")
        
        # 加載模型
        print("⏳ 正在加載模型...")
        model = AutoModelForCausalLM.from_pretrained(
            model_dir,
            torch_dtype=torch.float32,
            device_map=torch_device,
            trust_remote_code=True
        )
        model.eval()
        print("✅ 模型加載成功\n")
        
        # 準備推理參數
        max_new_tokens = kwargs.get('max_tokens', 100)
        temperature = kwargs.get('temperature', 0.7)
        top_p = kwargs.get('top_p', 0.9)
        
        # 編碼輸入
        print("⏳ 正在準備輸入...")
        inputs = tokenizer(prompt, return_tensors="pt").to(torch_device)
        print("✅ 輸入已準備\n")
        
        # 執行推理
        print("⏳ 正在生成文本...")
        with torch.no_grad():
            output_ids = model.generate(
                **inputs,
                max_new_tokens=max_new_tokens,
                temperature=temperature,
                top_p=top_p,
                do_sample=True,
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id
            )
        
        # 解碼輸出
        result = tokenizer.decode(output_ids[0], skip_special_tokens=True)
        
        print("\n" + "="*60)
        print("📤 生成結果:")
        print("="*60)
        print(f"{result}")
        print("="*60 + "\n")
        
        return result
        
    except FileNotFoundError as e:
        print(f"❌ 找不到模型文件: {e}")
        print(f"   確保模型已在 {model_path} 目錄中")
        return None
    except Exception as e:
        print(f"❌ 推理錯誤: {e}")
        import traceback
        traceback.print_exc()
        return None


def interactive_mode():
    """交互式推理模式"""
    
    # 加載配置
    config = load_env_config()
    model_path = PROJECT_ROOT / config['model_path']
    
    # 驗證模型
    if not model_path.exists():
        print(f"\n❌ 模型未找到: {model_path}")
        print(f"請運行以下命令下載模型:")
        print(f"  .\scripts\prepare_models.ps1")
        return
    
    print(f"\n{'='*60}")
    print(f"{'TinyLlama 交互式推理':^60}")
    print(f"{'='*60}")
    print(f"\n設備: {config['device']}")
    print(f"模型: {model_path.name}")
    print(f"最大令牌數: {config['max_tokens']}")
    print(f"\n輸入 'exit' 或 'quit' 退出\n")
    print("="*60 + "\n")
    
    try:
        # 設置設備
        if config['device'].upper() == 'GPU' and torch.cuda.is_available():
            torch_device = 'cuda'
        else:
            torch_device = 'cpu'
        
        # 加載分詞器
        print("⏳ 正在加載分詞器...")
        tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
        print("✅ 分詞器已加載")
        
        # 加載模型
        print("⏳ 正在加載模型...")
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            torch_dtype=torch.float32,
            device_map=torch_device,
            trust_remote_code=True
        )
        model.eval()
        print("✅ 模型已加載\n")
        
        while True:
            prompt = input(">>> 請輸入提示文本: ").strip()
            
            if prompt.lower() in ['exit', 'quit']:
                print("\n👋 再見！")
                break
            
            if not prompt:
                print("⚠️  提示文本不能為空\n")
                continue
            
            # 執行推理
            print("\n⏳ 正在生成...\n")
            
            try:
                inputs = tokenizer(prompt, return_tensors="pt").to(torch_device)
                
                with torch.no_grad():
                    output_ids = model.generate(
                        **inputs,
                        max_new_tokens=config['max_tokens'],
                        temperature=config['temperature'],
                        top_p=config['top_p'],
                        do_sample=True,
                        pad_token_id=tokenizer.pad_token_id,
                        eos_token_id=tokenizer.eos_token_id
                    )
                
                result = tokenizer.decode(output_ids[0], skip_special_tokens=True)
                print(f"✅ 結果: {result}\n")
                print("-" * 60 + "\n")
            except Exception as e:
                print(f"❌ 生成失敗: {e}\n")
                print("-" * 60 + "\n")
                
    except KeyboardInterrupt:
        print("\n\n⛔ 用戶中斷")
    except Exception as e:
        print(f"❌ 錯誤: {e}")
        import traceback
        traceback.print_exc()


def batch_inference(prompts: list):
    """批量推理"""
    
    config = load_env_config()
    model_path = PROJECT_ROOT / config['model_path']
    
    if not model_path.exists():
        print(f"❌ 模型未找到: {model_path}")
        return
    
    print(f"\n{'='*60}")
    print(f"{'TinyLlama 批量推理':^60}")
    print(f"{'='*60}\n")
    print(f"正在處理 {len(prompts)} 個提示...\n")
    
    try:
        # 設置設備
        if config['device'].upper() == 'GPU' and torch.cuda.is_available():
            torch_device = 'cuda'
        else:
            torch_device = 'cpu'
        
        # 加載分詞器
        print("⏳ 正在加載分詞器...")
        tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
        print("✅ 分詞器已加載")
        
        # 加載模型
        print("⏳ 正在加載模型...")
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            torch_dtype=torch.float32,
            device_map=torch_device,
            trust_remote_code=True
        )
        model.eval()
        print("✅ 模型已加載\n")
        
        results = []
        
        for i, prompt in enumerate(prompts, 1):
            print(f"[{i}/{len(prompts)}] 處理: {prompt[:50]}...")
            
            try:
                inputs = tokenizer(prompt, return_tensors="pt").to(torch_device)
                
                with torch.no_grad():
                    output_ids = model.generate(
                        **inputs,
                        max_new_tokens=config['max_tokens'],
                        temperature=config['temperature'],
                        top_p=config['top_p'],
                        do_sample=True,
                        pad_token_id=tokenizer.pad_token_id,
                        eos_token_id=tokenizer.eos_token_id
                    )
                
                result = tokenizer.decode(output_ids[0], skip_special_tokens=True)
                results.append({
                    'prompt': prompt,
                    'result': result
                })
                print(f"     ✓ 完成\n")
            except Exception as e:
                print(f"     ✗ 失敗: {e}\n")
                results.append({
                    'prompt': prompt,
                    'result': None,
                    'error': str(e)
                })
        
        print("="*60)
        print("批量推理完成")
        print("="*60)
        
        return results
        
    except Exception as e:
        print(f"❌ 錯誤: {e}")
        import traceback
        traceback.print_exc()
        return None


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(
        description="OpenVINO GenAI 推理示例"
    )
    
    parser.add_argument(
        'mode',
        nargs='?',
        default='interactive',
        choices=['interactive', 'demo', 'example'],
        help='運行模式 (default: interactive)'
    )
    
    parser.add_argument(
        '--prompt',
        type=str,
        default=None,
        help='單次推理的提示文本'
    )
    
    parser.add_argument(
        '--device',
        type=str,
        default=None,
        choices=['CPU', 'GPU', 'NPU'],
        help='推理設備'
    )
    
    parser.add_argument(
        '--max-tokens',
        type=int,
        default=None,
        help='最大生成令牌數'
    )
    
    args = parser.parse_args()
    
    # 加載配置
    config = load_env_config()
    
    # 覆蓋命令行參數
    if args.device:
        config['device'] = args.device
    if args.max_tokens:
        config['max_tokens'] = args.max_tokens
    
    model_path = PROJECT_ROOT / config['model_path']
    
    # 選擇運行模式
    if args.mode == 'demo':
        # 演示模式：運行預設提示
        demo_prompts = [
            "What is Python?",
            "Explain machine learning in simple terms.",
            "How does artificial intelligence work?"
        ]
        batch_inference(demo_prompts)
        
    elif args.prompt:
        # 單次推理模式
        run_inference(
            args.prompt,
            str(model_path),
            device=config['device'],
            max_tokens=config['max_tokens'],
            temperature=config['temperature'],
            top_p=config['top_p']
        )
        
    else:
        # 交互式模式（默認）
        interactive_mode()
