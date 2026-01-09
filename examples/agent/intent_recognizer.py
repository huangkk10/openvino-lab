"""
IntentRecognizer - Recognizes user intent using Llama
Parses natural language commands into structured tool calls
"""

import re
import json
from typing import Dict, Optional
import openvino_genai as ov_genai


class IntentRecognizer:
    """Recognizes user intent from natural language using Llama"""
    
    # System prompt for intent recognition
    SYSTEM_PROMPT = """Analyze the user command and return JSON with intent and parameters.

Tools:
- execute_command: Run shell command. Params: {"command": "cmd"}
  Examples: "run dir", "execute test.bat", "run C:\\path\\to\\file.bat"
- read_file: Read file. Params: {"path": "filepath"}
  Examples: "read README.md", "show config.yaml"
- write_file: Write file. Params: {"path": "filepath", "content": "text"}
  Examples: "create test.txt", "write to file.log"
- list_directory: List dir. Params: {"path": "dirpath"}
  Examples: "list examples", "show directory"
- run_python: Run Python. Params: {"code": "python code"}
  Examples: "calculate 2+2", "run python: print('hi')"
- chat: General talk. Params: {} (NO OTHER PARAMS)
  Examples: "hello", "help", "what can you do"

IMPORTANT: 
- For "chat" intent, parameters MUST be empty: {}
- For "execute_command", extract ONLY the command path/text
- Match the exact parameter names shown above

JSON format: {"intent":"tool","parameters":{...},"confidence":0.9}"""

    def __init__(self, model_path: str, device: str = "CPU"):
        """
        Initialize IntentRecognizer with Llama model
        
        Args:
            model_path: Path to OpenVINO model
            device: Device to run on (CPU, GPU, NPU)
        """
        try:
            self.pipe = ov_genai.LLMPipeline(model_path, device)
            self.config = ov_genai.GenerationConfig()
            self.config.max_new_tokens = 200
            self.config.temperature = 0.1  # Low temperature for more deterministic output
            self.config.do_sample = False
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Llama model: {e}")
    
    def recognize(self, user_input: str) -> Dict:
        """
        Recognize intent from user input
        
        Args:
            user_input: Natural language command from user
            
        Returns:
            Dictionary with:
            - intent: Tool name to invoke
            - parameters: Tool parameters
            - confidence: Confidence score (0.0-1.0)
            - raw_response: Raw model output for debugging
        """
        try:
            # Build prompt
            prompt = f"""{self.SYSTEM_PROMPT}

User command: {user_input}

JSON response:"""
            
            # Get Llama's response
            response = self.pipe.generate(prompt, self.config)
            raw_response = response.strip()
            
            # Try to extract JSON from response, pass original input for fallback
            result = self._parse_response(raw_response, user_input)
            result['raw_response'] = raw_response
            
            return result
            
        except Exception as e:
            return {
                'intent': 'error',
                'parameters': {},
                'confidence': 0.0,
                'error': str(e)
            }
    
    def _parse_response(self, response: str, user_input: str = "") -> Dict:
        """
        Parse Llama's response into structured format
        
        Args:
            response: Raw response from Llama
            user_input: Original user input for fallback recognition
            
        Returns:
            Dictionary with intent, parameters, confidence
        """
        try:
            # Try to find JSON in the response
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                json_str = json_match.group(0)
                parsed = json.loads(json_str)
                
                # Validate required fields
                if 'intent' in parsed:
                    intent = parsed.get('intent', 'unknown')
                    parameters = parsed.get('parameters', {})
                    confidence = parsed.get('confidence', 0.5)
                    
                    # Validate parameters based on intent
                    validated_params = self._validate_parameters(intent, parameters)
                    
                    return {
                        'intent': intent,
                        'parameters': validated_params,
                        'confidence': confidence
                    }
            
            # Fallback: try simple pattern matching on user input
            if user_input:
                return self._fallback_recognition(user_input)
            else:
                return self._fallback_recognition(response)
            
        except json.JSONDecodeError:
            # Use user input for fallback if available
            if user_input:
                return self._fallback_recognition(user_input)
            else:
                return self._fallback_recognition(response)
    
    def _validate_parameters(self, intent: str, parameters: Dict) -> Dict:
        """
        Validate and clean parameters based on intent
        
        Args:
            intent: Tool intent
            parameters: Raw parameters from Llama
            
        Returns:
            Validated parameters dictionary
        """
        # Define expected parameters for each intent
        expected_params = {
            'execute_command': ['command'],
            'read_file': ['path'],
            'write_file': ['path', 'content'],
            'list_directory': ['path'],
            'run_python': ['code'],
            'chat': []  # No parameters for chat
        }
        
        if intent not in expected_params:
            return parameters
        
        expected = expected_params[intent]
        
        # For chat, always return empty dict
        if intent == 'chat':
            return {}
        
        # Filter parameters to only include expected ones
        validated = {}
        for key in expected:
            if key in parameters:
                validated[key] = parameters[key]
        
        return validated
    
    def _fallback_recognition(self, text: str) -> Dict:
        """
        Fallback intent recognition using pattern matching
        
        Args:
            text: Text to analyze
            
        Returns:
            Dictionary with intent, parameters, confidence
        """
        text_lower = text.lower()
        
        # Command execution patterns
        if any(keyword in text_lower for keyword in ['run', 'execute', 'command', 'dir', 'ls']):
            # Try to extract command
            for pattern in [r'command["\']:\s*["\']([^"\']+)["\']', r'run\s+(.+)', r'execute\s+(.+)']:
                match = re.search(pattern, text, re.IGNORECASE)
                if match:
                    return {
                        'intent': 'execute_command',
                        'parameters': {'command': match.group(1).strip()},
                        'confidence': 0.6
                    }
        
        # File reading patterns
        if any(keyword in text_lower for keyword in ['read', 'show', 'cat', 'display']):
            match = re.search(r'(?:read|show|cat|display)\s+(.+)', text, re.IGNORECASE)
            if match:
                return {
                    'intent': 'read_file',
                    'parameters': {'path': match.group(1).strip()},
                    'confidence': 0.6
                }
        
        # Directory listing patterns
        if any(keyword in text_lower for keyword in ['list', 'ls', 'directory']):
            match = re.search(r'(?:list|ls|directory)\s+(.+)', text, re.IGNORECASE)
            path = match.group(1).strip() if match else '.'
            return {
                'intent': 'list_directory',
                'parameters': {'path': path},
                'confidence': 0.6
            }
        
        # Default to chat
        return {
            'intent': 'chat',
            'parameters': {},
            'confidence': 0.3
        }


# Example usage and testing
if __name__ == "__main__":
    import sys
    
    print("Testing IntentRecognizer...")
    print("Note: This requires the Llama model to be available.")
    
    # Model path from config
    model_path = "./models/open_llama_7b_v2-int4-ov"
    
    try:
        recognizer = IntentRecognizer(model_path, device="CPU")
        print(f"✓ Model loaded from: {model_path}")
        
        # Test cases
        test_inputs = [
            "run dir command",
            "read the file README.md",
            "list files in examples directory",
            "hello, how are you?",
            "create a file test.txt with content 'hello world'",
        ]
        
        print("\n=== Intent Recognition Tests ===")
        for user_input in test_inputs:
            print(f"\nUser: {user_input}")
            result = recognizer.recognize(user_input)
            print(f"Intent: {result['intent']}")
            print(f"Parameters: {result['parameters']}")
            print(f"Confidence: {result['confidence']:.2f}")
            if 'error' in result:
                print(f"Error: {result['error']}")
        
    except Exception as e:
        print(f"✗ Error: {e}")
        print("Make sure the Llama model is available at:", model_path)
        sys.exit(1)
