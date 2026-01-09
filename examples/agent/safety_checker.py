"""
SafetyChecker - Security validation for AI Agent operations
Validates paths and commands against configured security rules
"""

import os
import yaml
from pathlib import Path
from typing import Tuple


class SafetyChecker:
    """Validates operations against security policies"""
    
    def __init__(self, config_path: str = "config/agent_config.yaml"):
        """
        Initialize SafetyChecker with configuration
        
        Args:
            config_path: Path to agent configuration file
        """
        self.config = self._load_config(config_path)
        self.project_root = Path(self.config['security']['project_root']).resolve()
        self.forbidden_commands = self.config['security']['forbidden_commands']
        self.forbidden_paths = self.config['security']['forbidden_paths']
    
    def _load_config(self, config_path: str) -> dict:
        """Load configuration from YAML file"""
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            raise RuntimeError(f"Failed to load config from {config_path}: {e}")
    
    def check_path(self, path: str) -> Tuple[bool, str]:
        """
        Check if a path is safe to operate on
        
        Args:
            path: Path to validate
            
        Returns:
            Tuple of (is_safe, reason)
            - is_safe: True if path is safe, False otherwise
            - reason: Explanation of the result
        """
        try:
            # Convert to absolute path
            abs_path = Path(path).resolve()
            
            # Check if path is within project root
            try:
                abs_path.relative_to(self.project_root)
            except ValueError:
                return False, f"Path is outside project root: {self.project_root}"
            
            # Check against forbidden path patterns
            path_str = str(abs_path)
            for forbidden_pattern in self.forbidden_paths:
                # Remove wildcard for simple prefix matching
                pattern = forbidden_pattern.replace('*', '')
                if path_str.lower().startswith(pattern.lower()):
                    return False, f"Path matches forbidden pattern: {forbidden_pattern}"
            
            return True, "Path is safe"
            
        except Exception as e:
            return False, f"Error validating path: {e}"
    
    def check_command(self, command: str) -> Tuple[bool, str]:
        """
        Check if a command is safe to execute
        
        Args:
            command: Command string to validate
            
        Returns:
            Tuple of (is_safe, reason)
            - is_safe: True if command is safe, False otherwise
            - reason: Explanation of the result
        """
        try:
            # Normalize command to lowercase for checking
            cmd_lower = command.lower().strip()
            
            # Check against forbidden commands
            for forbidden in self.forbidden_commands:
                if forbidden.lower() in cmd_lower:
                    return False, f"Command contains forbidden operation: {forbidden}"
            
            # Additional checks for dangerous patterns
            dangerous_patterns = [
                ('>', 'Redirect output to system files'),
                ('<', 'Redirect input from system files'),
                ('|', 'Pipe to another command (use with caution)'),
            ]
            
            for pattern, warning in dangerous_patterns:
                if pattern in cmd_lower:
                    # For now, just warn but allow (could be made stricter)
                    pass
            
            return True, "Command is safe"
            
        except Exception as e:
            return False, f"Error validating command: {e}"
    
    def should_confirm(self) -> bool:
        """Check if user confirmation is required before execution"""
        return self.config['security'].get('require_confirmation', True)
    
    def get_timeout(self, operation_type: str = 'command') -> int:
        """
        Get timeout for operation type
        
        Args:
            operation_type: Type of operation ('command' or 'python')
            
        Returns:
            Timeout in seconds
        """
        timeouts = self.config['security'].get('timeout', {})
        return timeouts.get(operation_type, 30)
    
    def get_max_output_length(self) -> int:
        """Get maximum allowed output length"""
        return self.config['security'].get('max_output_length', 5000)


# Example usage and testing
if __name__ == "__main__":
    print("Testing SafetyChecker...")
    
    checker = SafetyChecker()
    
    # Test path validation
    print("\n=== Path Validation Tests ===")
    test_paths = [
        "examples/agent/test.py",
        "config/agent_config.yaml",
        "C:\\Windows\\System32\\test.exe",
        "../../../etc/passwd",
        "models/open_llama_7b_v2-int4-ov/config.json"
    ]
    
    for test_path in test_paths:
        is_safe, reason = checker.check_path(test_path)
        status = "✓ SAFE" if is_safe else "✗ UNSAFE"
        print(f"{status}: {test_path}")
        print(f"  Reason: {reason}")
    
    # Test command validation
    print("\n=== Command Validation Tests ===")
    test_commands = [
        "dir",
        "python examples/check_llama_env.py",
        "format C:",
        "del /s /q C:\\temp",
        "shutdown /s /t 0",
        "echo Hello World"
    ]
    
    for test_cmd in test_commands:
        is_safe, reason = checker.check_command(test_cmd)
        status = "✓ SAFE" if is_safe else "✗ UNSAFE"
        print(f"{status}: {test_cmd}")
        print(f"  Reason: {reason}")
    
    # Test configuration values
    print("\n=== Configuration Values ===")
    print(f"Require confirmation: {checker.should_confirm()}")
    print(f"Command timeout: {checker.get_timeout('command')}s")
    print(f"Python timeout: {checker.get_timeout('python')}s")
    print(f"Max output length: {checker.get_max_output_length()} chars")
