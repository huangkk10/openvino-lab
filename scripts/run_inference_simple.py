#!/usr/bin/env python3
"""
TinyLlama 簡單推理 - 直接從 HuggingFace 加載
使用方式：python scripts/run_inference_simple.py
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
        'max_tokens': int(os.getenv('MAX_NEW_TOKENS', '100')),
        'temperature': float(os.getenv('TEMPERATURE', '0.7')),
        'top_p': float(os.getenv('TOP_P', '0.9')),
    }
    
    return config

def run_inference(prompt: str, **kwargs):
    """執行推理"""
    
    print(f"\n{'='*60}")
    print(f"{'TinyLlama 推理示例':^60}")
    print(f"{'='*60}\n")
    
    print(f"📝 輸入提示: {prompt}")
    print(f"⚙️  參數設置:")
    for key, value in kwargs.items():
        print(f"   - {key}: {value}")
    print()
    
    try:
        # 設置設備
        if kwargs.get('device', 'CPU').upper() == 'GPU' and torch.cuda.is_available():
            torch_device = 'cuda'
            print(f"💻 推理設備: GPU (CUDA)")
        else:
            torch_device = 'cpu'
            print(f"💻 推理設備: CPU")
        print()
        
        # 模型 ID
        model_id = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
        
        # 加載分詞器
        print("⏳ 正在加載分詞器...")
        tokenizer = AutoTokenizer.from_pretrained(model_id)
        print("✅ 分詞器加載成功")
        
        # 加載模型
        print("⏳ 正在加載模型（首次會下載，約 2.2GB）...")
        model = AutoModelForCausalLM.from_pretrained(
            model_id,
            device_map=torch_device,
            trust_remote_code=True,
            dtype=torch.float16 if torch_device == 'cuda' else torch.float32
        )
        print("✅ 模型加載成功\n")
        
        # 準備推理參數
        max_new_tokens = kwargs.get('max_tokens', 100)
        temperature = kwargs.get('temperature', 0.7)
        top_p = kwargs.get('top_p', 0.9)
        
        # 使用 Chat 模板格式化輸入
        print("⏳ 正在準備輸入（使用 Chat 模板）...")
        messages = [
            {"role": "system", "content": "You are a helpful AI assistant. Provide clear and informative answers."},
            {"role": "user", "content": prompt}
        ]
        
        # 應用 chat 模板
        formatted_prompt = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )
        
        inputs = tokenizer(formatted_prompt, return_tensors="pt").to(torch_device)
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
        
    except Exception as e:
        print(f"❌ 推理錯誤: {e}")
        import traceback
        traceback.print_exc()
        return None

def interactive_mode():
    """交互式推理"""
    
    config = load_env_config()
    
    print(f"\n{'='*60}")
    print(f"{'TinyLlama 交互式推理':^60}")
    print(f"{'='*60}")
    print(f"\n設備: {config['device']}")
    print(f"最大令牌數: {config['max_tokens']}")
    print(f"溫度: {config['temperature']}")
    print(f"\n輸入 'exit' 或 'quit' 退出\n")
    print("="*60 + "\n")
    
    try:
        # 設置設備
        if config['device'].upper() == 'GPU' and torch.cuda.is_available():
            torch_device = 'cuda'
        else:
            torch_device = 'cpu'
        
        model_id = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
        
        # 加載分詞器
        print("⏳ 正在加載分詞器...")
        tokenizer = AutoTokenizer.from_pretrained(model_id)
        print("✅ 分詞器已加載")
        
        # 加載模型
        print("⏳ 正在加載模型...")
        model = AutoModelForCausalLM.from_pretrained(
            model_id,
            device_map=torch_device,
            trust_remote_code=True,
            dtype=torch.float16 if torch_device == 'cuda' else torch.float32
        )
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
                # 使用 Chat 模板格式化
                messages = [
                    {"role": "system", "content": "You are a helpful AI assistant. Provide clear and informative answers."},
                    {"role": "user", "content": prompt}
                ]
                
                formatted_prompt = tokenizer.apply_chat_template(
                    messages,
                    tokenize=False,
                    add_generation_prompt=True
                )
                
                inputs = tokenizer(formatted_prompt, return_tensors="pt").to(torch_device)
                
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
                print(f"✅ 結果:\n{result}\n")
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

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="TinyLlama 推理示例")
    parser.add_argument('mode', nargs='?', default='interactive', 
                        choices=['interactive', 'demo'],
                        help='運行模式')
    parser.add_argument('--prompt', type=str, default=None, help='單次推理的提示文本')
    parser.add_argument('--device', type=str, default=None, 
                        choices=['CPU', 'GPU'], help='推理設備')
    parser.add_argument('--max-tokens', type=int, default=None, help='最大令牌數')
    
    args = parser.parse_args()
    config = load_env_config()
    
    if args.device:
        config['device'] = args.device
    if args.max_tokens:
        config['max_tokens'] = args.max_tokens
    
    if args.mode == 'demo':
        # 演示模式
        demo_prompts = [
            "What is Python?",
            "Explain machine learning in simple terms.",
            "How does artificial intelligence work?"
        ]
        
        for i, prompt in enumerate(demo_prompts, 1):
            print(f"\n[{i}/3] 演示提示:")
            run_inference(prompt, **config)
            
    elif args.prompt:
        # 單次推理
        run_inference(args.prompt, **config)
    else:
        # 交互式模式
        interactive_mode()
