"""
Calculator Operations Module

Implements the Strategy Pattern for extensible calculation operations.
Follows the Open/Closed Principle - open for extension, closed for modification.
"""

from abc import ABC, abstractmethod
from typing import Dict


class CalculationStrategy(ABC):
    """
    Abstract base class for calculation strategies.
    Defines the interface that all calculation operations must implement.
    
    This follows the Strategy Pattern and Dependency Inversion Principle.
    """
    
    @abstractmethod
    def calculate(self, a: float, b: float) -> float:
        """
        Perform the calculation operation.
        
        Args:
            a: First operand
            b: Second operand
            
        Returns:
            Result of the calculation
            
        Raises:
            ValueError: If the operation cannot be performed
        """
        pass
    
    @abstractmethod
    def get_name(self) -> str:
        """Get the name of the operation"""
        pass


class AdditionStrategy(CalculationStrategy):
    """Addition operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        return a + b
    
    def get_name(self) -> str:
        return "add"


class SubtractionStrategy(CalculationStrategy):
    """Subtraction operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        return a - b
    
    def get_name(self) -> str:
        return "subtract"


class MultiplicationStrategy(CalculationStrategy):
    """Multiplication operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        return a * b
    
    def get_name(self) -> str:
        return "multiply"


class DivisionStrategy(CalculationStrategy):
    """Division operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
    
    def get_name(self) -> str:
        return "divide"


class PowerStrategy(CalculationStrategy):
    """Power/exponentiation operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        try:
            return a ** b
        except OverflowError:
            raise ValueError("Result too large to compute")
    
    def get_name(self) -> str:
        return "power"


class ModuloStrategy(CalculationStrategy):
    """Modulo operation strategy"""
    
    def calculate(self, a: float, b: float) -> float:
        if b == 0:
            raise ValueError("Cannot perform modulo with zero")
        return a % b
    
    def get_name(self) -> str:
        return "modulo"


class Calculator:
    """
    Calculator that uses strategy pattern for operations.
    
    This class follows:
    - Strategy Pattern: Uses interchangeable calculation strategies
    - Open/Closed Principle: Can add new operations without modifying this class
    - Single Responsibility: Only responsible for coordinating calculations
    """
    
    def __init__(self):
        """Initialize calculator with default strategies"""
        self._strategies: Dict[str, CalculationStrategy] = {}
        self._register_default_strategies()
    
    def _register_default_strategies(self):
        """Register all default calculation strategies"""
        default_strategies = [
            AdditionStrategy(),
            SubtractionStrategy(),
            MultiplicationStrategy(),
            DivisionStrategy(),
            PowerStrategy(),
            ModuloStrategy()
        ]
        
        for strategy in default_strategies:
            self._strategies[strategy.get_name()] = strategy
    
    def register_strategy(self, operation: str, strategy: CalculationStrategy):
        """
        Register a new calculation strategy.
        
        This method allows extending the calculator with new operations
        without modifying existing code (Open/Closed Principle).
        
        Args:
            operation: Name of the operation
            strategy: Strategy implementation for the operation
        """
        self._strategies[operation] = strategy
    
    def unregister_strategy(self, operation: str):
        """
        Remove a calculation strategy.
        
        Args:
            operation: Name of the operation to remove
        """
        if operation in self._strategies:
            del self._strategies[operation]
    
    def get_available_operations(self) -> list[str]:
        """Get list of all available operations"""
        return list(self._strategies.keys())
    
    def calculate(self, operation: str, a: float, b: float) -> float:
        """
        Perform a calculation using the specified operation.
        
        Args:
            operation: Name of the operation to perform
            a: First operand
            b: Second operand
            
        Returns:
            Result of the calculation
            
        Raises:
            ValueError: If operation is unknown or calculation fails
        """
        if operation not in self._strategies:
            available = ", ".join(self.get_available_operations())
            raise ValueError(
                f"Unknown operation: '{operation}'. "
                f"Available operations: {available}"
            )
        
        try:
            return self._strategies[operation].calculate(a, b)
        except Exception as e:
            raise ValueError(f"Calculation error: {str(e)}")


# Global calculator instance (Singleton pattern)
_calculator_instance = None


def get_calculator() -> Calculator:
    """
    Get the global calculator instance.
    
    Implements Singleton pattern to ensure only one calculator exists.
    Can be used as a dependency in FastAPI endpoints.
    
    Returns:
        The global Calculator instance
    """
    global _calculator_instance
    if _calculator_instance is None:
        _calculator_instance = Calculator()
    return _calculator_instance
