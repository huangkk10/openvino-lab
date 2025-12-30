#!/usr/bin/env python3
"""
OpenVINO GenAI Benchmark 包裝腳本

簡化 benchmark_genai.exe 的執行，提供友好的命令行介面。

使用範例：
    python scripts/run_benchmark.py \\
        --model "./models/open_llama_7b_v2-int4-ov" \\
        --device GPU \\
        --prompt "The Sky is blue because" \\
        --max-tokens 20
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path
import time
import json

# 顏色常數
COLORS = {
    "CYAN": "\033[96m",
    "GREEN": "\033[92m",
    "YELLOW": "\033[93m",
    "RED": "\033[91m",
    "BLUE": "\033[94m",
    "RESET": "\033[0m",
    "BOLD": "\033[1m",
}


def colorize(text: str, color: str) -> str:
    """為文字添加顏色"""
    return f"{COLORS.get(color, '')}{text}{COLORS['RESET']}"


def print_header(title: str):
    """列印美化的標題"""
    width = 70
    print()
    print("╔" + "═" * (width - 2) + "╗")
    print(f"║ {colorize(title.center(width - 4), 'CYAN')} ║")
    print("╚" + "═" * (width - 2) + "╝")
    print()


def print_status(message: str, status: str = "INFO"):
    """列印狀態信息"""
    status_map = {
        "INFO": ("ℹ️  ", "BLUE"),
        "SUCCESS": ("✅ ", "GREEN"),
        "WARNING": ("⚠️  ", "YELLOW"),
        "ERROR": ("❌ ", "RED"),
        "PROGRESS": ("📊 ", "CYAN"),
    }

    icon, color = status_map.get(status, ("ℹ️  ", "BLUE"))
    print(f"{icon} {colorize(message, color)}")


def find_benchmark_exe():
    """查找 benchmark_genai.exe"""
    possible_paths = [
        "./src/openvino.genai/samples/cpp/text_generation/build/Release/benchmark_genai.exe",
        "./benchmark_genai.exe",
        "./build/Release/benchmark_genai.exe",
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return os.path.abspath(path)
    
    return None


def check_model_path(model_path: str) -> bool:
    """檢查模型路徑是否存在"""
    if not os.path.exists(model_path):
        print_status(f"模型路徑不存在：{model_path}", "ERROR")
        return False
    
    # 檢查必要文件
    required_files = ["openvino_model.xml", "openvino_model.bin", "config.json"]
    for file in required_files:
        file_path = os.path.join(model_path, file)
        if not os.path.exists(file_path):
            print_status(f"缺少必要文件：{file}", "WARNING")
    
    return True


def run_benchmark(
    benchmark_exe: str,
    model_path: str,
    device: str = "CPU",
    prompt: str = "The Sky is blue because",
    max_tokens: int = 20,
    num_warmup: int = 0,
    num_iter: int = 1,
) -> dict:
    """
    執行 benchmark
    
    Returns:
        dict: benchmark 結果
    """
    
    print_header("OpenVINO GenAI Benchmark")
    
    # 顯示配置
    print_status(f"Benchmark 可執行文件：{colorize(benchmark_exe, 'BOLD')}")
    print_status(f"模型路徑：{colorize(model_path, 'BOLD')}")
    print_status(f"設備：{colorize(device, 'BOLD')}")
    print_status(f"提示詞：{colorize(prompt, 'BOLD')}")
    print_status(f"最大令牌數：{colorize(str(max_tokens), 'BOLD')}")
    print_status(f"預熱次數：{colorize(str(num_warmup), 'BOLD')}")
    print_status(f"迭代次數：{colorize(str(num_iter), 'BOLD')}")
    print()
    
    # 構建命令
    cmd = [
        benchmark_exe,
        "-m", model_path,
        "-d", device,
        "-p", prompt,
        "-nw", str(num_warmup),
        "-mt", str(max_tokens),
        "-n", str(num_iter),
    ]
    
    print_status("執行 benchmark...", "PROGRESS")
    print()
    
    # 執行命令
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace'
        )
        
        # 顯示輸出
        if result.stdout:
            print(result.stdout)
        
        if result.stderr:
            print(colorize("錯誤輸出：", "RED"))
            print(result.stderr)
        
        if result.returncode == 0:
            print()
            print_status("Benchmark 完成！", "SUCCESS")
            return {"success": True, "output": result.stdout}
        else:
            print()
            print_status(f"Benchmark 失敗（退出碼：{result.returncode}）", "ERROR")
            return {"success": False, "output": result.stdout, "error": result.stderr}
    
    except Exception as e:
        print_status(f"執行錯誤：{e}", "ERROR")
        return {"success": False, "error": str(e)}


def auto_setup_benchmark():
    """自動設置 benchmark 環境"""
    print_header("自動設置 Benchmark")
    
    print_status("檢查 Git...", "PROGRESS")
    if subprocess.run(["git", "--version"], capture_output=True).returncode != 0:
        print_status("未找到 Git，請先安裝 Git", "ERROR")
        return False
    
    print_status("檢查 CMake...", "PROGRESS")
    if subprocess.run(["cmake", "--version"], capture_output=True).returncode != 0:
        print_status("未找到 CMake，請先安裝 CMake", "ERROR")
        print_status("安裝命令：winget install Kitware.CMake", "INFO")
        return False
    
    # 克隆倉庫
    repo_path = "./src/openvino.genai"
    if not os.path.exists(repo_path):
        print_status("克隆 OpenVINO GenAI 倉庫...", "PROGRESS")
        os.makedirs("./src", exist_ok=True)
        result = subprocess.run(
            ["git", "clone", "https://github.com/openvinotoolkit/openvino.genai.git", repo_path],
            capture_output=True
        )
        if result.returncode != 0:
            print_status("克隆失敗", "ERROR")
            return False
    
    # 編譯
    build_dir = os.path.join(repo_path, "samples/cpp/text_generation/build")
    print_status(f"編譯 benchmark（這可能需要幾分鐘）...", "PROGRESS")
    
    os.makedirs(build_dir, exist_ok=True)
    os.chdir(build_dir)
    
    # CMake 配置
    result = subprocess.run(
        ["cmake", "..", "-G", "Visual Studio 17 2022", "-A", "x64"],
        capture_output=True
    )
    if result.returncode != 0:
        print_status("CMake 配置失敗", "ERROR")
        print(result.stderr.decode('utf-8', errors='replace'))
        return False
    
    # 編譯
    result = subprocess.run(
        ["cmake", "--build", ".", "--config", "Release"],
        capture_output=True
    )
    if result.returncode != 0:
        print_status("編譯失敗", "ERROR")
        print(result.stderr.decode('utf-8', errors='replace'))
        return False
    
    # 返回原始目錄
    os.chdir("../../../../..")
    
    print_status("Benchmark 設置完成！", "SUCCESS")
    return True


def main():
    parser = argparse.ArgumentParser(
        description="OpenVINO GenAI Benchmark 包裝腳本",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
範例用法：

  1. 基本用法（GPU）
     python scripts/run_benchmark.py \\
       --model "./models/open_llama_7b_v2-int4-ov" \\
       --device GPU

  2. 完整參數
     python scripts/run_benchmark.py \\
       --model "./models/open_llama_7b_v2-int4-ov" \\
       --device GPU \\
       --prompt "The Sky is blue because" \\
       --max-tokens 20 \\
       --num-iter 5

  3. 自動設置並運行
     python scripts/run_benchmark.py \\
       --model "./models/open_llama_7b_v2-int4-ov" \\
       --auto-setup
        """
    )
    
    parser.add_argument(
        "--model", "-m",
        type=str,
        required=True,
        help="模型路徑（例如：./models/open_llama_7b_v2-int4-ov）"
    )
    
    parser.add_argument(
        "--device", "-d",
        type=str,
        default="CPU",
        choices=["CPU", "GPU", "NPU"],
        help="推理設備（預設：CPU）"
    )
    
    parser.add_argument(
        "--prompt", "-p",
        type=str,
        default="The Sky is blue because",
        help="測試提示詞"
    )
    
    parser.add_argument(
        "--max-tokens", "-mt",
        type=int,
        default=20,
        help="最大生成令牌數（預設：20）"
    )
    
    parser.add_argument(
        "--num-warmup", "-nw",
        type=int,
        default=0,
        help="預熱次數（預設：0）"
    )
    
    parser.add_argument(
        "--num-iter", "-n",
        type=int,
        default=1,
        help="迭代次數（預設：1）"
    )
    
    parser.add_argument(
        "--auto-setup",
        action="store_true",
        help="自動設置 benchmark 環境（克隆倉庫並編譯）"
    )
    
    parser.add_argument(
        "--benchmark-exe",
        type=str,
        default=None,
        help="benchmark_genai.exe 的路徑（自動偵測）"
    )
    
    args = parser.parse_args()
    
    # 自動設置
    if args.auto_setup:
        if not auto_setup_benchmark():
            sys.exit(1)
    
    # 查找 benchmark 可執行文件
    benchmark_exe = args.benchmark_exe or find_benchmark_exe()
    
    if not benchmark_exe:
        print_status("未找到 benchmark_genai.exe", "ERROR")
        print()
        print_status("請執行以下操作之一：", "INFO")
        print("  1. 使用 --auto-setup 自動設置")
        print("  2. 手動編譯並使用 --benchmark-exe 指定路徑")
        print("  3. 查看 docs/setup/STAGE_9_GUIDE.md 獲取詳細說明")
        sys.exit(1)
    
    # 檢查模型
    if not check_model_path(args.model):
        print()
        print_status("建議：", "INFO")
        print("  1. 確認模型路徑正確")
        print("  2. 使用 Stage 8 下載模型")
        print("  3. 查看 docs/setup/STAGE_8_GUIDE.md")
        sys.exit(1)
    
    # 執行 benchmark
    result = run_benchmark(
        benchmark_exe=benchmark_exe,
        model_path=os.path.abspath(args.model),
        device=args.device,
        prompt=args.prompt,
        max_tokens=args.max_tokens,
        num_warmup=args.num_warmup,
        num_iter=args.num_iter,
    )
    
    if not result["success"]:
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        print_status("用戶中止操作", "WARNING")
        sys.exit(0)
    except Exception as e:
        print()
        print_status(f"發生錯誤：{e}", "ERROR")
        import traceback
        traceback.print_exc()
        sys.exit(1)
