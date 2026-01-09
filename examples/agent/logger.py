"""
AgentLogger - Logging system for AI Agent operations
Records all operations, intents, and execution results
"""

import os
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional


class AgentLogger:
    """Logs agent operations to file"""
    
    def __init__(self, log_file: str, enabled: bool = True):
        """
        Initialize AgentLogger
        
        Args:
            log_file: Path to log file
            enabled: Whether logging is enabled
        """
        self.log_file = Path(log_file)
        self.enabled = enabled
        
        if self.enabled:
            # Create log directory if needed
            self.log_file.parent.mkdir(parents=True, exist_ok=True)
            
            # Write header if new file
            if not self.log_file.exists():
                self._write_header()
    
    def _write_header(self):
        """Write log file header"""
        with open(self.log_file, 'w', encoding='utf-8') as f:
            f.write("=" * 80 + "\n")
            f.write("AI Agent Operation Log\n")
            f.write(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 80 + "\n\n")
    
    def _format_timestamp(self) -> str:
        """Get formatted timestamp"""
        return datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    def log_intent(self, user_input: str, intent_result: Dict):
        """
        Log intent recognition
        
        Args:
            user_input: Original user input
            intent_result: Result from IntentRecognizer
        """
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{self._format_timestamp()}] INTENT\n")
            f.write(f"User Input: {user_input}\n")
            f.write(f"Recognized Intent: {intent_result.get('intent', 'unknown')}\n")
            f.write(f"Parameters: {intent_result.get('parameters', {})}\n")
            f.write(f"Confidence: {intent_result.get('confidence', 0.0):.2f}\n")
            f.write("-" * 80 + "\n\n")
    
    def log_execution(self, tool: str, parameters: Dict, result: Dict):
        """
        Log tool execution
        
        Args:
            tool: Tool name
            parameters: Execution parameters
            result: Execution result
        """
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{self._format_timestamp()}] EXECUTION\n")
            f.write(f"Tool: {tool}\n")
            f.write(f"Parameters: {parameters}\n")
            f.write(f"Success: {result.get('success', False)}\n")
            
            if result.get('success'):
                # Log successful result
                if 'stdout' in result:
                    output = result['stdout'][:200]  # Truncate
                    f.write(f"Output: {output}...\n")
                elif 'content' in result:
                    content = str(result['content'])[:200]
                    f.write(f"Content: {content}...\n")
                elif 'result' in result:
                    f.write(f"Result: {result['result']}\n")
            else:
                # Log error
                error = result.get('error', 'Unknown error')
                f.write(f"Error: {error}\n")
            
            f.write("-" * 80 + "\n\n")
    
    def log_safety_check(self, check_type: str, target: str, is_safe: bool, reason: str):
        """
        Log safety check
        
        Args:
            check_type: Type of check ('path' or 'command')
            target: What was checked
            is_safe: Whether it passed
            reason: Reason for decision
        """
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{self._format_timestamp()}] SAFETY CHECK\n")
            f.write(f"Type: {check_type}\n")
            f.write(f"Target: {target}\n")
            f.write(f"Status: {'✓ SAFE' if is_safe else '✗ UNSAFE'}\n")
            f.write(f"Reason: {reason}\n")
            f.write("-" * 80 + "\n\n")
    
    def log_user_confirmation(self, action: str, confirmed: bool):
        """
        Log user confirmation
        
        Args:
            action: Action that was confirmed/rejected
            confirmed: Whether user confirmed
        """
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{self._format_timestamp()}] USER CONFIRMATION\n")
            f.write(f"Action: {action}\n")
            f.write(f"Response: {'✓ CONFIRMED' if confirmed else '✗ REJECTED'}\n")
            f.write("-" * 80 + "\n\n")
    
    def log_error(self, component: str, error: str):
        """
        Log error
        
        Args:
            component: Component where error occurred
            error: Error message
        """
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(f"[{self._format_timestamp()}] ERROR\n")
            f.write(f"Component: {component}\n")
            f.write(f"Error: {error}\n")
            f.write("-" * 80 + "\n\n")
    
    def log_session_end(self):
        """Log end of session"""
        if not self.enabled:
            return
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write("\n" + "=" * 80 + "\n")
            f.write(f"Session Ended: {self._format_timestamp()}\n")
            f.write("=" * 80 + "\n\n")
    
    def get_log_content(self, max_lines: int = 100) -> str:
        """
        Get recent log content
        
        Args:
            max_lines: Maximum number of lines to return
            
        Returns:
            Recent log content
        """
        if not self.log_file.exists():
            return "No log file found"
        
        try:
            with open(self.log_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            if len(lines) <= max_lines:
                return ''.join(lines)
            else:
                return ''.join(lines[-max_lines:])
        except Exception as e:
            return f"Error reading log: {e}"


# Example usage and testing
if __name__ == "__main__":
    print("Testing AgentLogger...")
    
    # Create test logger
    log_file = "config/logs/test_agent_log.txt"
    logger = AgentLogger(log_file, enabled=True)
    
    print(f"Log file: {log_file}")
    
    # Test 1: Log intent
    print("\n=== Test 1: Log Intent ===")
    logger.log_intent(
        "run dir command",
        {
            'intent': 'execute_command',
            'parameters': {'command': 'dir'},
            'confidence': 0.85
        }
    )
    print("✓ Intent logged")
    
    # Test 2: Log execution
    print("\n=== Test 2: Log Execution ===")
    logger.log_execution(
        'execute_command',
        {'command': 'dir'},
        {
            'success': True,
            'stdout': 'File1.txt\nFile2.txt\n...',
            'return_code': 0
        }
    )
    print("✓ Execution logged")
    
    # Test 3: Log safety check
    print("\n=== Test 3: Log Safety Check ===")
    logger.log_safety_check(
        'command',
        'format C:',
        False,
        'Command contains forbidden operation: format'
    )
    print("✓ Safety check logged")
    
    # Test 4: Log user confirmation
    print("\n=== Test 4: Log User Confirmation ===")
    logger.log_user_confirmation(
        'Execute: del temp.txt',
        True
    )
    print("✓ User confirmation logged")
    
    # Test 5: Log error
    print("\n=== Test 5: Log Error ===")
    logger.log_error(
        'IntentRecognizer',
        'Model failed to load'
    )
    print("✓ Error logged")
    
    # Test 6: End session
    print("\n=== Test 6: End Session ===")
    logger.log_session_end()
    print("✓ Session end logged")
    
    # Test 7: Read log
    print("\n=== Test 7: Read Log ===")
    log_content = logger.get_log_content(max_lines=20)
    print("Recent log content:")
    print(log_content)
