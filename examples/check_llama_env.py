"""
快速驗證 Llama 環境
檢查所有必要元件是否就緒
"""

import sys
import os

def check_environment():
    """檢查環境設置"""
    print("=" * 70)
    print("🔍 Llama 環境檢查")
    print("=" * 70 + "\n")
    
    checks = []
    
    # 1. Python 版本
    print("1️⃣ Python 版本...")
    py_version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print(f"   ✅ Python {py_version}\n")
    checks.append(("Python", True, py_version))
    
    # 2. OpenVINO
    print("2️⃣ OpenVINO...")
    try:
        import openvino as ov
        ov_version = ov.__version__
        print(f"   ✅ OpenVINO {ov_version}\n")
        checks.append(("OpenVINO", True, ov_version))
    except ImportError as e:
        print(f"   ❌ OpenVINO 未安裝: {e}\n")
        checks.append(("OpenVINO", False, str(e)))
    
    # 3. OpenVINO GenAI
    print("3️⃣ OpenVINO GenAI...")
    try:
        import openvino_genai as ov_genai
        genai_version = ov_genai.__version__
        print(f"   ✅ OpenVINO GenAI {genai_version}\n")
        checks.append(("OpenVINO GenAI", True, genai_version))
    except ImportError as e:
        print(f"   ❌ OpenVINO GenAI 未安裝: {e}\n")
        checks.append(("OpenVINO GenAI", False, str(e)))
    
    # 4. Transformers
    print("4️⃣ Transformers...")
    try:
        import transformers
        tf_version = transformers.__version__
        print(f"   ✅ Transformers {tf_version}\n")
        checks.append(("Transformers", True, tf_version))
    except ImportError as e:
        print(f"   ❌ Transformers 未安裝: {e}\n")
        checks.append(("Transformers", False, str(e)))
    
    # 5. 模型檢查
    print("5️⃣ Llama 模型...")
    model_path = "./models/open_llama_7b_v2-int4-ov"
    if os.path.exists(model_path):
        # 檢查必要檔案
        required_files = [
            "openvino_model.xml",
            "openvino_model.bin",
            "openvino_tokenizer.xml",
            "openvino_tokenizer.bin",
            "config.json"
        ]
        
        missing = []
        for file in required_files:
            if not os.path.exists(os.path.join(model_path, file)):
                missing.append(file)
        
        if not missing:
            print(f"   ✅ 模型完整 ({model_path})\n")
            checks.append(("Llama Model", True, model_path))
        else:
            print(f"   ⚠️  模型不完整，缺少: {', '.join(missing)}\n")
            checks.append(("Llama Model", False, f"Missing: {missing}"))
    else:
        print(f"   ❌ 模型不存在: {model_path}\n")
        checks.append(("Llama Model", False, "Not found"))
    
    # 6. 可用設備
    print("6️⃣ 可用推理設備...")
    try:
        import openvino as ov
        core = ov.Core()
        devices = core.available_devices
        print(f"   ✅ 可用設備: {', '.join(devices)}\n")
        checks.append(("Devices", True, ', '.join(devices)))
    except Exception as e:
        print(f"   ❌ 無法檢查設備: {e}\n")
        checks.append(("Devices", False, str(e)))
    
    # 總結
    print("=" * 70)
    print("📊 檢查結果")
    print("=" * 70 + "\n")
    
    passed = sum(1 for _, status, _ in checks if status)
    total = len(checks)
    
    for name, status, info in checks:
        status_icon = "✅" if status else "❌"
        print(f"{status_icon} {name:20} {info}")
    
    print("\n" + "=" * 70)
    print(f"結果: {passed}/{total} 項目通過")
    
    if passed == total:
        print("🎉 環境完整！可以開始使用 Llama 模型！")
        print("\n下一步:")
        print("  python examples/llama_quick_start.py")
        print("  python examples/llama_chatbot.py")
    else:
        print("⚠️  環境不完整，請參考 LLAMA_SETUP_PLAN.md 進行設置")
    
    print("=" * 70)
    
    return passed == total

if __name__ == "__main__":
    success = check_environment()
    sys.exit(0 if success else 1)
