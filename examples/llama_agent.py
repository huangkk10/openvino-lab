"""
Llama AI Agent - Interactive agent with tool execution capabilities
Combines Llama's understanding with system tool execution
"""

import sys
import yaml
from pathlib import Path

# Import agent components
from agent.safety_checker import SafetyChecker
from agent.intent_recognizer import IntentRecognizer
from agent.tool_router import ToolRouter
from agent.logger import AgentLogger
from agent.executors.command import CommandExecutor
from agent.executors.file import FileOperator


class LlamaAgent:
    """Main AI Agent integrating all components"""
    
    def __init__(self, config_path: str = "config/agent_config.yaml"):
        """
        Initialize LlamaAgent
        
        Args:
            config_path: Path to configuration file
        """
        print("Initializing Llama AI Agent...")
        
        # Load configuration
        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = yaml.safe_load(f)
        
        # Initialize components
        print("  Loading SafetyChecker...")
        self.safety = SafetyChecker(config_path)
        
        print("  Loading Llama model for intent recognition...")
        model_path = self.config['model']['path']
        device = self.config['model']['device']
        self.recognizer = IntentRecognizer(model_path, device)
        
        print("  Initializing tool router...")
        self.router = ToolRouter()
        
        print("  Setting up executors...")
        self.command_executor = CommandExecutor(
            timeout=self.safety.get_timeout('command'),
            max_output_length=self.safety.get_max_output_length()
        )
        self.file_operator = FileOperator(
            project_root=self.config['security']['project_root']
        )
        
        print("  Initializing logger...")
        log_config = self.config.get('logging', {})
        self.logger = AgentLogger(
            log_file=log_config.get('log_file', 'config/logs/agent_log.txt'),
            enabled=log_config.get('enabled', True)
        )
        
        # Register real tool handlers
        self._register_tools()
        
        print("✓ Llama AI Agent initialized successfully!\n")
    
    def _register_tools(self):
        """Register real tool implementations"""
        self.router.register_tool('execute_command', self._execute_command)
        self.router.register_tool('read_file', self._read_file)
        self.router.register_tool('write_file', self._write_file)
        self.router.register_tool('list_directory', self._list_directory)
        self.router.register_tool('run_python', self._run_python)
        self.router.register_tool('chat', self._chat)
    
    def _execute_command(self, command: str) -> str:
        """Execute shell command"""
        # Safety check
        is_safe, reason = self.safety.check_command(command)
        self.logger.log_safety_check('command', command, is_safe, reason)
        
        if not is_safe:
            return f"❌ Command blocked: {reason}"
        
        # User confirmation if required
        if self.safety.should_confirm():
            confirmed = self._ask_confirmation(f"Execute command: {command}")
            self.logger.log_user_confirmation(f"Execute: {command}", confirmed)
            
            if not confirmed:
                return "❌ Operation cancelled by user"
        
        # Execute
        result = self.command_executor.execute(command)
        self.logger.log_execution('execute_command', {'command': command}, result)
        
        if result['success']:
            output = result['stdout'].strip()
            return f"✓ Command executed successfully:\n{output}"
        else:
            error = result.get('error', result.get('stderr', 'Unknown error'))
            return f"❌ Command failed: {error}"
    
    def _read_file(self, path: str) -> str:
        """Read file content"""
        # Safety check
        is_safe, reason = self.safety.check_path(path)
        self.logger.log_safety_check('path', path, is_safe, reason)
        
        if not is_safe:
            return f"❌ Path blocked: {reason}"
        
        # Execute
        result = self.file_operator.read_file(path)
        self.logger.log_execution('read_file', {'path': path}, result)
        
        if result['success']:
            content = result['content']
            size = result['size']
            # Truncate long files for display
            if len(content) > 1000:
                content = content[:1000] + f"\n... (showing first 1000 chars of {size} bytes)"
            return f"✓ File content ({size} bytes):\n{content}"
        else:
            return f"❌ Read failed: {result['error']}"
    
    def _write_file(self, path: str, content: str) -> str:
        """Write content to file"""
        # Safety check
        is_safe, reason = self.safety.check_path(path)
        self.logger.log_safety_check('path', path, is_safe, reason)
        
        if not is_safe:
            return f"❌ Path blocked: {reason}"
        
        # User confirmation if required
        if self.safety.should_confirm():
            confirmed = self._ask_confirmation(f"Write to file: {path}")
            self.logger.log_user_confirmation(f"Write: {path}", confirmed)
            
            if not confirmed:
                return "❌ Operation cancelled by user"
        
        # Execute
        result = self.file_operator.write_file(path, content)
        self.logger.log_execution('write_file', {'path': path, 'content': content}, result)
        
        if result['success']:
            return f"✓ File written successfully: {path} ({result['size']} bytes)"
        else:
            return f"❌ Write failed: {result['error']}"
    
    def _list_directory(self, path: str = '.') -> str:
        """List directory contents"""
        # Safety check
        is_safe, reason = self.safety.check_path(path)
        self.logger.log_safety_check('path', path, is_safe, reason)
        
        if not is_safe:
            return f"❌ Path blocked: {reason}"
        
        # Execute
        result = self.file_operator.list_directory(path)
        self.logger.log_execution('list_directory', {'path': path}, result)
        
        if result['success']:
            entries = result['entries']
            output = f"✓ Directory: {path} ({result['count']} items)\n"
            for entry in entries[:20]:  # Show first 20
                icon = "📁" if entry['type'] == 'dir' else "📄"
                size = f"({entry['size']} bytes)" if entry['type'] == 'file' else ""
                output += f"  {icon} {entry['name']} {size}\n"
            if result['count'] > 20:
                output += f"  ... and {result['count'] - 20} more items"
            return output
        else:
            return f"❌ List failed: {result['error']}"
    
    def _run_python(self, code: str) -> str:
        """Execute Python code"""
        # User confirmation if required
        if self.safety.should_confirm():
            confirmed = self._ask_confirmation(f"Execute Python code: {code[:50]}...")
            self.logger.log_user_confirmation(f"Python: {code[:50]}", confirmed)
            
            if not confirmed:
                return "❌ Operation cancelled by user"
        
        # Execute
        result = self.command_executor.execute_python(code)
        self.logger.log_execution('run_python', {'code': code}, result)
        
        if result['success']:
            output = result['stdout'].strip()
            return f"✓ Python executed successfully:\n{output}"
        else:
            error = result.get('error', result.get('stderr', 'Unknown error'))
            return f"❌ Python failed: {error}"
    
    def _chat(self) -> str:
        """Handle general chat"""
        return "I'm here to help! I can execute commands, read/write files, list directories, and run Python code. What would you like to do?"
    
    def _ask_confirmation(self, message: str) -> bool:
        """Ask user for confirmation"""
        print(f"\n⚠️  Confirmation required:")
        print(f"   {message}")
        response = input("   Proceed? (yes/no): ").strip().lower()
        return response in ['yes', 'y']
    
    def process_input(self, user_input: str) -> str:
        """
        Process user input and return response
        
        Args:
            user_input: Natural language command from user
            
        Returns:
            Response string
        """
        try:
            # Recognize intent
            print("\n🔍 Analyzing your request...")
            intent_result = self.recognizer.recognize(user_input)
            self.logger.log_intent(user_input, intent_result)
            
            intent = intent_result['intent']
            confidence = intent_result['confidence']
            
            print(f"   Intent: {intent} (confidence: {confidence:.2f})")
            
            # Route and execute
            print("   Executing...")
            exec_result = self.router.execute(intent_result)
            
            if exec_result['success']:
                return exec_result['result']
            else:
                return f"❌ Error: {exec_result['error']}"
            
        except Exception as e:
            error_msg = f"Agent error: {str(e)}"
            self.logger.log_error('LlamaAgent', error_msg)
            return f"❌ {error_msg}"
    
    def run(self):
        """Run interactive agent loop"""
        print("=" * 80)
        print("🤖 Llama AI Agent - Interactive Mode")
        print("=" * 80)
        print("\nI can help you with:")
        print("  • Execute shell commands (e.g., 'run dir', 'list files')")
        print("  • Read files (e.g., 'read README.md')")
        print("  • Write files (e.g., 'create test.txt with hello')")
        print("  • List directories (e.g., 'list examples folder')")
        print("  • Run Python code (e.g., 'calculate 2+2')")
        print("\nType 'quit', 'exit', or 'bye' to end the session.")
        print("=" * 80 + "\n")
        
        try:
            while True:
                # Get user input
                user_input = input("You: ").strip()
                
                # Check for exit commands
                if user_input.lower() in ['quit', 'exit', 'bye', 'q']:
                    print("\n👋 Goodbye! Ending session...")
                    self.logger.log_session_end()
                    break
                
                if not user_input:
                    continue
                
                # Process input
                response = self.process_input(user_input)
                
                # Display response
                print(f"\n🤖 Agent: {response}\n")
        
        except KeyboardInterrupt:
            print("\n\n👋 Session interrupted. Goodbye!")
            self.logger.log_session_end()
        except Exception as e:
            print(f"\n❌ Fatal error: {e}")
            self.logger.log_error('run', str(e))
            self.logger.log_session_end()


def main():
    """Main entry point"""
    try:
        agent = LlamaAgent()
        agent.run()
    except Exception as e:
        print(f"\n❌ Failed to initialize agent: {e}")
        print("\nTroubleshooting:")
        print("  1. Make sure you're in the virtual environment")
        print("  2. Check that the Llama model exists at: ./models/open_llama_7b_v2-int4-ov")
        print("  3. Verify config/agent_config.yaml is present")
        sys.exit(1)


if __name__ == "__main__":
    main()
