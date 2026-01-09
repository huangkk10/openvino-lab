"""
CommandExecutor - Executes shell commands safely
Runs system commands with timeout and output capture
"""

import subprocess
import sys
from typing import Dict, Optional
from pathlib import Path


class CommandExecutor:
    """Executes shell commands with safety checks and timeout"""
    
    def __init__(self, timeout: int = 30, max_output_length: int = 5000):
        """
        Initialize CommandExecutor
        
        Args:
            timeout: Maximum execution time in seconds
            max_output_length: Maximum output length to capture
        """
        self.timeout = timeout
        self.max_output_length = max_output_length
        
        # Detect shell based on platform
        if sys.platform == 'win32':
            self.shell = True  # Use shell on Windows
        else:
            self.shell = False  # Use direct execution on Unix
    
    def execute(self, command: str, cwd: Optional[str] = None) -> Dict:
        """
        Execute a shell command
        
        Args:
            command: Command to execute
            cwd: Working directory (optional)
            
        Returns:
            Dictionary with:
            - success: Whether command succeeded
            - stdout: Standard output
            - stderr: Standard error
            - return_code: Exit code
            - error: Error message (if failed)
        """
        try:
            # Prepare execution parameters
            exec_params = {
                'shell': self.shell,
                'capture_output': True,
                'text': True,
                'timeout': self.timeout
            }
            
            if cwd:
                exec_params['cwd'] = cwd
            
            # Execute command
            result = subprocess.run(command, **exec_params)
            
            # Truncate output if too long
            stdout = result.stdout
            stderr = result.stderr
            
            if len(stdout) > self.max_output_length:
                stdout = stdout[:self.max_output_length] + f"\n... (truncated, {len(stdout)} chars total)"
            
            if len(stderr) > self.max_output_length:
                stderr = stderr[:self.max_output_length] + f"\n... (truncated, {len(stderr)} chars total)"
            
            return {
                'success': result.returncode == 0,
                'stdout': stdout,
                'stderr': stderr,
                'return_code': result.returncode
            }
            
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'stdout': '',
                'stderr': '',
                'return_code': -1,
                'error': f'Command timed out after {self.timeout} seconds'
            }
        except Exception as e:
            return {
                'success': False,
                'stdout': '',
                'stderr': '',
                'return_code': -1,
                'error': f'Execution error: {str(e)}'
            }
    
    def execute_python(self, code: str, timeout: Optional[int] = None) -> Dict:
        """
        Execute Python code
        
        Args:
            code: Python code to execute
            timeout: Timeout in seconds (uses default if None)
            
        Returns:
            Execution result dictionary
        """
        if timeout is None:
            timeout = self.timeout
        
        # Execute Python code using subprocess
        command = f'{sys.executable} -c "{code}"'
        return self.execute(command)


# Example usage and testing
if __name__ == "__main__":
    print("Testing CommandExecutor...")
    
    executor = CommandExecutor(timeout=5, max_output_length=1000)
    
    print("\n=== Command Execution Tests ===")
    
    # Test 1: Simple command (Windows dir or Unix ls)
    if sys.platform == 'win32':
        test_commands = [
            ("dir", "List current directory"),
            ("echo Hello World", "Echo test"),
            ("python --version", "Check Python version"),
            ("timeout /t 10", "Timeout test (should fail)"),  # This will timeout
            ("invalid_command_xyz", "Invalid command test"),
        ]
    else:
        test_commands = [
            ("ls -la", "List current directory"),
            ("echo Hello World", "Echo test"),
            ("python --version", "Check Python version"),
            ("sleep 10", "Timeout test (should fail)"),
            ("invalid_command_xyz", "Invalid command test"),
        ]
    
    for command, description in test_commands:
        print(f"\n--- {description} ---")
        print(f"Command: {command}")
        
        result = executor.execute(command)
        
        if result['success']:
            print(f"✓ Success (exit code: {result['return_code']})")
            if result['stdout']:
                print(f"Output:\n{result['stdout'][:200]}")
        else:
            print(f"✗ Failed")
            if 'error' in result:
                print(f"Error: {result['error']}")
            if result['stderr']:
                print(f"Stderr: {result['stderr'][:200]}")
    
    # Test 2: Python code execution
    print("\n=== Python Code Execution Tests ===")
    
    python_tests = [
        ("print('Hello from Python')", "Simple print"),
        ("print(2 + 2)", "Math calculation"),
        ("import sys; print(sys.version)", "Import test"),
    ]
    
    for code, description in python_tests:
        print(f"\n--- {description} ---")
        print(f"Code: {code}")
        
        result = executor.execute_python(code)
        
        if result['success']:
            print(f"✓ Success")
            print(f"Output: {result['stdout'].strip()}")
        else:
            print(f"✗ Failed")
            if 'error' in result:
                print(f"Error: {result['error']}")
