"""
FileOperator - Safe file operations with path validation
Handles reading, writing, and listing files
"""

import os
from pathlib import Path
from typing import Dict, List, Optional


class FileOperator:
    """Performs file operations with safety checks"""
    
    def __init__(self, project_root: str, max_file_size: int = 10 * 1024 * 1024):
        """
        Initialize FileOperator
        
        Args:
            project_root: Root directory for file operations
            max_file_size: Maximum file size to read (bytes)
        """
        self.project_root = Path(project_root).resolve()
        self.max_file_size = max_file_size
    
    def _validate_path(self, path: str) -> tuple[bool, str, Optional[Path]]:
        """
        Validate that path is within project root
        
        Args:
            path: Path to validate
            
        Returns:
            Tuple of (is_valid, message, resolved_path)
        """
        try:
            abs_path = Path(path).resolve()
            
            # Check if within project root
            try:
                abs_path.relative_to(self.project_root)
            except ValueError:
                return False, f"Path is outside project root: {self.project_root}", None
            
            return True, "Path is valid", abs_path
            
        except Exception as e:
            return False, f"Path validation error: {e}", None
    
    def read_file(self, path: str, encoding: str = 'utf-8') -> Dict:
        """
        Read contents of a file
        
        Args:
            path: Path to file
            encoding: Text encoding (default: utf-8)
            
        Returns:
            Dictionary with:
            - success: Whether operation succeeded
            - content: File content (if successful)
            - size: File size in bytes
            - error: Error message (if failed)
        """
        # Validate path
        is_valid, message, abs_path = self._validate_path(path)
        if not is_valid:
            return {
                'success': False,
                'error': message
            }
        
        try:
            # Check if file exists
            if not abs_path.exists():
                return {
                    'success': False,
                    'error': f"File not found: {path}"
                }
            
            # Check if it's a file
            if not abs_path.is_file():
                return {
                    'success': False,
                    'error': f"Not a file: {path}"
                }
            
            # Check file size
            file_size = abs_path.stat().st_size
            if file_size > self.max_file_size:
                return {
                    'success': False,
                    'error': f"File too large: {file_size} bytes (max: {self.max_file_size})"
                }
            
            # Read file
            with open(abs_path, 'r', encoding=encoding) as f:
                content = f.read()
            
            return {
                'success': True,
                'content': content,
                'size': file_size,
                'path': str(abs_path)
            }
            
        except UnicodeDecodeError:
            return {
                'success': False,
                'error': f"Cannot decode file with {encoding} encoding (binary file?)"
            }
        except Exception as e:
            return {
                'success': False,
                'error': f"Read error: {str(e)}"
            }
    
    def write_file(self, path: str, content: str, encoding: str = 'utf-8', 
                   create_dirs: bool = True) -> Dict:
        """
        Write content to a file
        
        Args:
            path: Path to file
            content: Content to write
            encoding: Text encoding (default: utf-8)
            create_dirs: Create parent directories if needed
            
        Returns:
            Dictionary with success status and any errors
        """
        # Validate path
        is_valid, message, abs_path = self._validate_path(path)
        if not is_valid:
            return {
                'success': False,
                'error': message
            }
        
        try:
            # Create parent directories if needed
            if create_dirs:
                abs_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write file
            with open(abs_path, 'w', encoding=encoding) as f:
                f.write(content)
            
            return {
                'success': True,
                'path': str(abs_path),
                'size': len(content.encode(encoding))
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"Write error: {str(e)}"
            }
    
    def list_directory(self, path: str = '.', show_hidden: bool = False) -> Dict:
        """
        List contents of a directory
        
        Args:
            path: Directory path
            show_hidden: Include hidden files
            
        Returns:
            Dictionary with list of files and directories
        """
        # Validate path
        is_valid, message, abs_path = self._validate_path(path)
        if not is_valid:
            return {
                'success': False,
                'error': message
            }
        
        try:
            # Check if directory exists
            if not abs_path.exists():
                return {
                    'success': False,
                    'error': f"Directory not found: {path}"
                }
            
            # Check if it's a directory
            if not abs_path.is_dir():
                return {
                    'success': False,
                    'error': f"Not a directory: {path}"
                }
            
            # List contents
            entries = []
            for entry in abs_path.iterdir():
                # Skip hidden files if requested
                if not show_hidden and entry.name.startswith('.'):
                    continue
                
                entry_info = {
                    'name': entry.name,
                    'type': 'dir' if entry.is_dir() else 'file',
                    'size': entry.stat().st_size if entry.is_file() else 0
                }
                entries.append(entry_info)
            
            # Sort: directories first, then files
            entries.sort(key=lambda x: (x['type'] == 'file', x['name'].lower()))
            
            return {
                'success': True,
                'path': str(abs_path),
                'entries': entries,
                'count': len(entries)
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"List error: {str(e)}"
            }
    
    def file_info(self, path: str) -> Dict:
        """
        Get information about a file or directory
        
        Args:
            path: Path to check
            
        Returns:
            Dictionary with file/directory information
        """
        # Validate path
        is_valid, message, abs_path = self._validate_path(path)
        if not is_valid:
            return {
                'success': False,
                'error': message
            }
        
        try:
            if not abs_path.exists():
                return {
                    'success': False,
                    'error': f"Path not found: {path}"
                }
            
            stat = abs_path.stat()
            
            return {
                'success': True,
                'path': str(abs_path),
                'name': abs_path.name,
                'type': 'dir' if abs_path.is_dir() else 'file',
                'size': stat.st_size,
                'modified': stat.st_mtime
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"Info error: {str(e)}"
            }


# Example usage and testing
if __name__ == "__main__":
    import sys
    
    print("Testing FileOperator...")
    
    # Use current directory as project root
    project_root = Path.cwd()
    operator = FileOperator(str(project_root))
    
    print(f"Project root: {project_root}")
    
    # Test 1: List directory
    print("\n=== List Directory Test ===")
    result = operator.list_directory('.')
    if result['success']:
        print(f"✓ Found {result['count']} entries")
        for entry in result['entries'][:5]:  # Show first 5
            print(f"  [{entry['type']:4}] {entry['name']}")
        if result['count'] > 5:
            print(f"  ... and {result['count'] - 5} more")
    else:
        print(f"✗ {result['error']}")
    
    # Test 2: Read file
    print("\n=== Read File Test ===")
    test_file = "README.md"
    result = operator.read_file(test_file)
    if result['success']:
        print(f"✓ Read {result['size']} bytes from {test_file}")
        print(f"First 100 chars: {result['content'][:100]}...")
    else:
        print(f"✗ {result['error']}")
    
    # Test 3: Write file
    print("\n=== Write File Test ===")
    test_content = "# Test File\nThis is a test file created by FileOperator.\n"
    result = operator.write_file("config/temp/test_write.txt", test_content)
    if result['success']:
        print(f"✓ Wrote {result['size']} bytes to {result['path']}")
    else:
        print(f"✗ {result['error']}")
    
    # Test 4: File info
    print("\n=== File Info Test ===")
    result = operator.file_info("README.md")
    if result['success']:
        print(f"✓ File info:")
        print(f"  Name: {result['name']}")
        print(f"  Type: {result['type']}")
        print(f"  Size: {result['size']} bytes")
    else:
        print(f"✗ {result['error']}")
    
    # Test 5: Invalid path (outside project)
    print("\n=== Security Test (outside project) ===")
    result = operator.read_file("C:\\Windows\\System32\\drivers\\etc\\hosts")
    if result['success']:
        print("✗ SECURITY ISSUE: Read file outside project!")
    else:
        print(f"✓ Security check passed: {result['error']}")
