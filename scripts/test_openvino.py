"""
OpenVINO GenAI 環境測試腳本

用於驗證環境安裝是否成功。
"""

import sys

def test_imports():
    """測試必要的套件是否能正常導入"""
    print("=== 測試套件導入 ===\n")
    
    packages = [
        ("openvino_genai", "OpenVINO GenAI"),
        ("openvino", "OpenVINO"),
        ("openvino_tokenizers", "OpenVINO Tokenizers"),
        ("optimum.intel", "Optimum Intel"),
    ]
    
    success = True
    for package, name in packages:
        try:
            __import__(package)
            print(f"✓ {name} 導入成功")
        except ImportError as e:
            print(f"✗ {name} 導入失敗: {e}")
            success = False
    
    return success

def get_version_info():
    """獲取版本資訊"""
    print("\n=== 版本資訊 ===\n")
    
    try:
        import openvino as ov
        print(f"OpenVINO 版本: {ov.__version__}")
    except Exception as e:
        print(f"無法獲取 OpenVINO 版本: {e}")
    
    try:
        import openvino_genai
        if hasattr(openvino_genai, '__version__'):
            print(f"OpenVINO GenAI 版本: {openvino_genai.__version__}")
        else:
            print("OpenVINO GenAI 版本資訊不可用")
    except Exception as e:
        print(f"無法獲取 OpenVINO GenAI 版本: {e}")

def check_devices():
    """檢查可用的推理設備"""
    print("\n=== 可用的推理設備 ===\n")
    
    try:
        import openvino as ov
        core = ov.Core()
        devices = core.available_devices
        
        if devices:
            print("可用設備:")
            for device in devices:
                print(f"  - {device}")
        else:
            print("未找到可用設備")
    except Exception as e:
        print(f"檢查設備時發生錯誤: {e}")

def main():
    """主函數"""
    print("=" * 60)
    print("OpenVINO GenAI 環境測試")
    print("=" * 60 + "\n")
    
    # 測試導入
    if not test_imports():
        print("\n❌ 某些套件導入失敗，請檢查安裝")
        print("   參考：docs/SETUP_WINDOWS.md")
        sys.exit(1)
    
    # 獲取版本資訊
    get_version_info()
    
    # 檢查設備
    check_devices()
    
    print("\n" + "=" * 60)
    print("✅ OpenVINO GenAI 環境測試完成！")
    print("=" * 60)
    print("\n下一步:")
    print("1. 查看使用指南: docs/README.md")
    print("2. 模型轉換: docs/MODELS.md")
    print("3. 運行範例: examples/simple_inference.py")
    print("\n文檔：")
    print("  - 設置指南：docs/SETUP_WINDOWS.md")
    print("  - 模型指南：docs/MODELS.md")
    print("  - 故障排除：docs/TROUBLESHOOTING.md")

if __name__ == "__main__":
    main()
