#!/usr/bin/env python3
"""
通用 HuggingFace 模型下載腳本

此腳本允許從 HuggingFace Hub 下載任何模型，支援：
- 指定模型 ID（repository ID）
- 自訂保存位置和模型名稱
- 自動進度追蹤
- 錯誤處理和恢復

使用範例：
    # 下載 OpenLLaMA 7B 模型（OpenVINO 優化版）
    python scripts/download_hf_model.py \\
        --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \\
        --model-name "open_llama_7b_v2-int4" \\
        --output-dir "./models"

    # 下載並指定自訂位置
    python scripts/download_hf_model.py \\
        --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \\
        --output-path "D:/Models/open_llama"

    # 使用預設設定（存到 ./models）
    python scripts/download_hf_model.py \\
        --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"
"""

import argparse
import os
import sys
from pathlib import Path
from typing import Optional
import json
from datetime import datetime

try:
    from huggingface_hub import snapshot_download, model_info
except ImportError:
    print("❌ 錯誤：huggingface_hub 未安裝")
    print("💡 請執行：pip install huggingface_hub")
    sys.exit(1)

# ==================== 常數 ====================

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
        "PROGRESS": ("📦 ", "CYAN"),
    }

    icon, color = status_map.get(status, ("ℹ️  ", "BLUE"))
    print(f"{icon} {colorize(message, color)}")


def print_section(title: str):
    """列印小節標題"""
    print(f"\n{colorize('=' * 50, 'CYAN')}")
    print(colorize(f"  {title}", "CYAN"))
    print(colorize('=' * 50, 'CYAN'))


def format_size(bytes_size: float) -> str:
    """將位元組轉換為易讀格式"""
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if bytes_size < 1024.0:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.2f} PB"


def get_model_info(repo_id: str) -> Optional[dict]:
    """取得模型信息"""
    try:
        print_status(f"正在取得模型信息...", "PROGRESS")
        info = model_info(repo_id)
        
        # 計算模型大小
        size_bytes = 0
        if hasattr(info, "siblings"):
            for file_info in info.siblings:
                if hasattr(file_info, "size") and file_info.size is not None:
                    size_bytes += file_info.size
        
        return {
            "repo_id": repo_id,
            "private": info.private if hasattr(info, "private") else False,
            "size": size_bytes,
            "size_formatted": format_size(size_bytes) if size_bytes > 0 else "未知",
        }
    except Exception as e:
        print_status(f"無法取得模型信息：{e}", "WARNING")
        return None


def download_model(
    repo_id: str,
    local_dir: str,
    model_name: Optional[str] = None,
) -> bool:
    """
    下載 HuggingFace 模型
    
    Args:
        repo_id: HuggingFace 模型 ID（例如："OpenVINO/open_llama_7b_v2-int4-ov"）
        local_dir: 本地保存目錄
        model_name: 模型名稱（用於顯示和日誌）
    
    Returns:
        bool: 下載是否成功
    """
    
    if model_name is None:
        model_name = repo_id.split("/")[-1]
    
    print_header(f"下載模型：{model_name}")
    
    # 顯示模型信息
    print_section("模型信息")
    print_status(f"Repository ID: {colorize(repo_id, 'BOLD')}")
    print_status(f"保存位置: {colorize(local_dir, 'BOLD')}")
    print()
    
    # 取得模型大小信息
    model_info_dict = get_model_info(repo_id)
    if model_info_dict:
        print_status(f"估計大小: {colorize(model_info_dict['size_formatted'], 'BOLD')}")
        print_status(f"私有模型: {colorize('是' if model_info_dict['private'] else '否', 'BOLD')}")
    
    print()
    
    # 建立目錄
    os.makedirs(local_dir, exist_ok=True)
    
    # 檢查是否已存在
    if os.path.exists(local_dir) and len(os.listdir(local_dir)) > 0:
        print_status("模型目錄已存在，將嘗試繼續下載", "WARNING")
    
    print_section("開始下載")
    print_status("下載可能需要數分鐘，取決於網絡速度和模型大小", "INFO")
    print()
    
    try:
        result_path = snapshot_download(
            repo_id=repo_id,
            local_dir=local_dir,
            repo_type="model",
            resume_download=True,
            local_dir_use_symlinks=False,
        )
        
        print()
        print_section("下載完成")
        print_status(f"模型已保存到：{colorize(result_path, 'BOLD')}", "SUCCESS")
        
        # 統計文件
        file_count = 0
        total_size = 0
        for root, dirs, files in os.walk(result_path):
            for file in files:
                file_count += 1
                file_path = os.path.join(root, file)
                total_size += os.path.getsize(file_path)
        
        print()
        print_status(f"文件數: {colorize(str(file_count), 'BOLD')}")
        print_status(f"總大小: {colorize(format_size(total_size), 'BOLD')}")
        
        # 列出主要文件
        print()
        print_status("主要文件：", "INFO")
        main_files = ["openvino_model.xml", "openvino_model.bin", "config.json", 
                      "tokenizer.json", "tokenizer_config.json", "generation_config.json"]
        for file in main_files:
            file_path = os.path.join(result_path, file)
            if os.path.exists(file_path):
                size = os.path.getsize(file_path)
                print(f"  ✓ {file} ({format_size(size)})")
        
        print()
        return True
        
    except Exception as e:
        print()
        print_section("下載失敗")
        print_status(f"錯誤: {str(e)}", "ERROR")
        print()
        print_status("故障排除建議：", "INFO")
        print("  1. 檢查網絡連接")
        print("  2. 確認 repo_id 正確無誤")
        print("  3. 嘗試升級 huggingface_hub: pip install --upgrade huggingface_hub")
        print("  4. 檢查 HuggingFace 網站是否有服務問題")
        print()
        return False


def verify_model(local_dir: str, model_name: str) -> bool:
    """驗證模型文件完整性"""
    print_section("驗證模型")
    
    if not os.path.exists(local_dir):
        print_status("模型目錄不存在", "ERROR")
        return False
    
    # 檢查必要文件（OpenVINO 模型）
    required_files = ["openvino_model.xml", "openvino_model.bin", "config.json"]
    optional_files = ["tokenizer.json", "tokenizer_config.json", "generation_config.json"]
    
    missing_required = []
    missing_optional = []
    
    for file in required_files:
        file_path = os.path.join(local_dir, file)
        if not os.path.exists(file_path):
            missing_required.append(file)
        else:
            print_status(f"✓ {file} 存在", "SUCCESS")
    
    print()
    
    for file in optional_files:
        file_path = os.path.join(local_dir, file)
        if not os.path.exists(file_path):
            missing_optional.append(file)
        else:
            print_status(f"✓ {file} 存在", "SUCCESS")
    
    print()
    
    if missing_required:
        print_status(f"缺少必要文件：{', '.join(missing_required)}", "ERROR")
        return False
    
    if missing_optional:
        print_status(f"缺少可選文件：{', '.join(missing_optional)}", "WARNING")
    
    print_status("模型驗證成功！", "SUCCESS")
    return True


def create_manifest(model_dir: str, repo_id: str, model_name: str):
    """建立模型清單（用於記錄和追蹤）"""
    manifest = {
        "model_name": model_name,
        "repo_id": repo_id,
        "downloaded_at": datetime.now().isoformat(),
        "downloaded_from": "HuggingFace Hub",
        "local_path": os.path.abspath(model_dir),
    }
    
    manifest_path = os.path.join(model_dir, ".manifest.json")
    try:
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2, ensure_ascii=False)
        print_status(f"已建立模型清單：.manifest.json", "INFO")
    except Exception as e:
        print_status(f"無法建立清單：{e}", "WARNING")


def main():
    """主程序"""
    parser = argparse.ArgumentParser(
        description="通用 HuggingFace 模型下載工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
範例用法：

  1. 下載 OpenLLaMA 7B（OpenVINO 優化版）
     python scripts/download_hf_model.py \\
       --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \\
       --model-name "open_llama_7b_v2-int4"

  2. 下載到自訂位置
     python scripts/download_hf_model.py \\
       --repo-id "OpenVINO/open_llama_7b_v2-int4-ov" \\
       --output-path "D:/MyModels/open_llama"

  3. 使用預設設定（存到 ./models）
     python scripts/download_hf_model.py \\
       --repo-id "OpenVINO/open_llama_7b_v2-int4-ov"

  4. 下載 TinyLlama（標準 PyTorch 版本）
     python scripts/download_hf_model.py \\
       --repo-id "TinyLlama/TinyLlama-1.1B-Chat-v1.0" \\
       --model-name "tinyllama-pytorch"
        """
    )
    
    parser.add_argument(
        "--repo-id",
        type=str,
        required=True,
        help="HuggingFace Repository ID（例如：OpenVINO/open_llama_7b_v2-int4-ov）",
    )
    
    parser.add_argument(
        "--model-name",
        type=str,
        default=None,
        help="本地模型名稱（用於目錄名和日誌，預設為 repo-id 的最後部分）",
    )
    
    parser.add_argument(
        "--output-dir",
        type=str,
        default="./models",
        help="輸出目錄（預設：./models）",
    )
    
    parser.add_argument(
        "--output-path",
        type=str,
        default=None,
        help="完整的輸出路徑（例如：./models/my_model），覆蓋 --output-dir",
    )
    
    parser.add_argument(
        "--no-verify",
        action="store_true",
        help="跳過下載後的驗證步驟",
    )
    
    parser.add_argument(
        "--no-manifest",
        action="store_true",
        help="不建立 .manifest.json 文件",
    )
    
    args = parser.parse_args()
    
    # 決定輸出路徑
    if args.output_path:
        local_dir = args.output_path
    else:
        model_name = args.model_name or args.repo_id.split("/")[-1]
        local_dir = os.path.join(args.output_dir, model_name)
    
    # 確保路徑是絕對路徑
    local_dir = os.path.abspath(local_dir)
    
    # 下載模型
    success = download_model(
        repo_id=args.repo_id,
        local_dir=local_dir,
        model_name=args.model_name,
    )
    
    if not success:
        sys.exit(1)
    
    # 驗證模型
    if not args.no_verify:
        verify_success = verify_model(local_dir, args.model_name or args.repo_id)
        if not verify_success and not args.no_verify:
            print_status("模型驗證失敗，但文件已下載", "WARNING")
    
    # 建立清單
    if not args.no_manifest:
        create_manifest(
            local_dir,
            args.repo_id,
            args.model_name or args.repo_id.split("/")[-1],
        )
    
    # 使用說明
    print_section("下一步")
    print_status("模型已準備好！", "SUCCESS")
    print()
    print_status("使用推理腳本進行推理：", "INFO")
    inference_cmd = 'python scripts/run_inference_simple.py --prompt "您的問題"'
    print(f"  {colorize(inference_cmd, 'BOLD')}")
    print()
    print_status("注意：", "INFO")
    print("  • 下載的 OpenVINO 模型需要 OpenVINO GenAI 庫（目前不兼容）")
    print("  • 推薦使用 run_inference_simple.py（基於 PyTorch/Transformers）")
    print()
    
    print_status("模型信息已保存到：.manifest.json", "INFO")
    print()


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
        sys.exit(1)
