"""
ToolRouter - Routes intents to appropriate tool executors
Maps recognized intents to executable tool functions
"""

from typing import Dict, Callable, Any, Optional


class ToolRouter:
    """Routes intents to appropriate tool executors"""
    
    def __init__(self):
        """Initialize ToolRouter with tool registry"""
        self.tools: Dict[str, Callable] = {}
        self._setup_default_tools()
    
    def _setup_default_tools(self):
        """Setup default tool handlers (placeholders for now)"""
        self.tools = {
            'execute_command': self._placeholder_execute_command,
            'read_file': self._placeholder_read_file,
            'write_file': self._placeholder_write_file,
            'list_directory': self._placeholder_list_directory,
            'run_python': self._placeholder_run_python,
            'chat': self._placeholder_chat,
            'error': self._placeholder_error,
            'unknown': self._placeholder_unknown
        }
    
    def register_tool(self, intent: str, handler: Callable):
        """
        Register a new tool handler
        
        Args:
            intent: Intent name
            handler: Function to handle this intent
        """
        self.tools[intent] = handler
    
    def route(self, intent_result: Dict) -> Dict[str, Any]:
        """
        Route intent to appropriate tool
        
        Args:
            intent_result: Result from IntentRecognizer containing:
                - intent: Tool name
                - parameters: Tool parameters
                - confidence: Confidence score
                
        Returns:
            Dictionary with:
            - success: Whether routing succeeded
            - tool: Tool name that was invoked
            - handler: Callable tool handler
            - message: Status message
        """
        intent = intent_result.get('intent', 'unknown')
        parameters = intent_result.get('parameters', {})
        confidence = intent_result.get('confidence', 0.0)
        
        # Check if tool exists
        if intent not in self.tools:
            return {
                'success': False,
                'tool': intent,
                'handler': None,
                'message': f"Unknown tool: {intent}",
                'parameters': parameters
            }
        
        # Check confidence threshold
        if confidence < 0.3:
            return {
                'success': False,
                'tool': intent,
                'handler': None,
                'message': f"Low confidence ({confidence:.2f}) for intent: {intent}",
                'parameters': parameters
            }
        
        # Return tool handler
        handler = self.tools[intent]
        return {
            'success': True,
            'tool': intent,
            'handler': handler,
            'message': f"Routed to {intent} (confidence: {confidence:.2f})",
            'parameters': parameters
        }
    
    def execute(self, intent_result: Dict) -> Dict[str, Any]:
        """
        Route and execute intent
        
        Args:
            intent_result: Result from IntentRecognizer
            
        Returns:
            Execution result dictionary
        """
        route_result = self.route(intent_result)
        
        if not route_result['success']:
            return {
                'success': False,
                'error': route_result['message']
            }
        
        # Execute the handler
        try:
            handler = route_result['handler']
            parameters = route_result['parameters']
            result = handler(**parameters)
            return {
                'success': True,
                'tool': route_result['tool'],
                'result': result
            }
        except Exception as e:
            return {
                'success': False,
                'tool': route_result['tool'],
                'error': f"Execution error: {e}"
            }
    
    def list_tools(self) -> list:
        """Get list of available tools"""
        return list(self.tools.keys())
    
    # Placeholder handlers (will be replaced with real implementations)
    
    def _placeholder_execute_command(self, command: str) -> str:
        """Placeholder for command execution"""
        return f"[PLACEHOLDER] Would execute command: {command}"
    
    def _placeholder_read_file(self, path: str) -> str:
        """Placeholder for file reading"""
        return f"[PLACEHOLDER] Would read file: {path}"
    
    def _placeholder_write_file(self, path: str, content: str) -> str:
        """Placeholder for file writing"""
        return f"[PLACEHOLDER] Would write to {path}: {content[:50]}..."
    
    def _placeholder_list_directory(self, path: str = '.') -> str:
        """Placeholder for directory listing"""
        return f"[PLACEHOLDER] Would list directory: {path}"
    
    def _placeholder_run_python(self, code: str) -> str:
        """Placeholder for Python execution"""
        return f"[PLACEHOLDER] Would run Python code: {code[:50]}..."
    
    def _placeholder_chat(self) -> str:
        """Placeholder for chat response"""
        return "[PLACEHOLDER] This is a chat response"
    
    def _placeholder_error(self, **kwargs) -> str:
        """Placeholder for error handling"""
        return f"[PLACEHOLDER] Error occurred: {kwargs}"
    
    def _placeholder_unknown(self, **kwargs) -> str:
        """Placeholder for unknown intents"""
        return f"[PLACEHOLDER] Unknown intent with params: {kwargs}"


# Example usage and testing
if __name__ == "__main__":
    print("Testing ToolRouter...")
    
    router = ToolRouter()
    
    # Test routing
    print("\n=== Available Tools ===")
    print(f"Registered tools: {router.list_tools()}")
    
    print("\n=== Routing Tests ===")
    
    # Test cases simulating IntentRecognizer output
    test_cases = [
        {
            'intent': 'execute_command',
            'parameters': {'command': 'dir'},
            'confidence': 0.8
        },
        {
            'intent': 'read_file',
            'parameters': {'path': 'README.md'},
            'confidence': 0.9
        },
        {
            'intent': 'unknown_tool',
            'parameters': {},
            'confidence': 0.5
        },
        {
            'intent': 'execute_command',
            'parameters': {'command': 'format C:'},
            'confidence': 0.2  # Low confidence
        },
        {
            'intent': 'chat',
            'parameters': {},
            'confidence': 0.7
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\nTest {i}: {test_case['intent']} (confidence: {test_case['confidence']})")
        
        # Test routing
        route_result = router.route(test_case)
        print(f"  Routing: {'✓' if route_result['success'] else '✗'} {route_result['message']}")
        
        # Test execution
        if route_result['success']:
            exec_result = router.execute(test_case)
            if exec_result['success']:
                print(f"  Execution: ✓ {exec_result['result']}")
            else:
                print(f"  Execution: ✗ {exec_result['error']}")
    
    # Test custom tool registration
    print("\n=== Custom Tool Registration ===")
    
    def custom_tool(message: str) -> str:
        return f"Custom tool says: {message}"
    
    router.register_tool('custom_tool', custom_tool)
    
    custom_intent = {
        'intent': 'custom_tool',
        'parameters': {'message': 'Hello from custom tool!'},
        'confidence': 0.95
    }
    
    result = router.execute(custom_intent)
    if result['success']:
        print(f"✓ Custom tool executed: {result['result']}")
    else:
        print(f"✗ Custom tool failed: {result['error']}")
