"""
測試 IntentRecognizer 修復
"""

import sys
sys.path.insert(0, '.')

from examples.agent.intent_recognizer import IntentRecognizer

print("Loading model...")
recognizer = IntentRecognizer('./models/open_llama_7b_v2-int4-ov', device='CPU')

print("\n=== Test 1: Batch file execution ===")
test_input = "run C:\\Users\\svd\\codes\\openvino-lab\\examples\\run_llama_chatbot.bat"
result = recognizer.recognize(test_input)

print(f"User input: {test_input}")
print(f"Intent: {result['intent']}")
print(f"Parameters: {result['parameters']}")
print(f"Confidence: {result['confidence']:.2f}")
print(f"Raw response: {result.get('raw_response', 'N/A')[:100]}...")

print("\n=== Test 2: Simple command ===")
test_input = "run dir"
result = recognizer.recognize(test_input)

print(f"User input: {test_input}")
print(f"Intent: {result['intent']}")
print(f"Parameters: {result['parameters']}")
print(f"Confidence: {result['confidence']:.2f}")

print("\n=== Test 3: File read ===")
test_input = "read README.md"
result = recognizer.recognize(test_input)

print(f"User input: {test_input}")
print(f"Intent: {result['intent']}")
print(f"Parameters: {result['parameters']}")
print(f"Confidence: {result['confidence']:.2f}")

print("\n✓ All tests completed!")
