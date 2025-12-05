"""
Calculation Repository

Handles all database operations related to calculations.
Follows Repository Pattern and Single Responsibility Principle.
"""

from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.calculation import Calculation
from app.repositories import BaseRepository


class CalculationRepository(BaseRepository[Calculation]):
    """
    Repository for Calculation entities.
    
    Provides specialized methods for calculation-related database operations.
    """
    
    def __init__(self, db: Session):
        """Initialize calculation repository"""
        super().__init__(db, Calculation)
    
    def get_by_user(self, user_id: int, skip: int = 0, limit: int = 100) -> List[Calculation]:
        """
        Get all calculations for a specific user.
        
        Args:
            user_id: User ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of calculations for the user
        """
        return (
            self.db.query(Calculation)
            .filter(Calculation.user_id == user_id)
            .order_by(Calculation.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    def get_by_operation(self, operation: str, skip: int = 0, limit: int = 100) -> List[Calculation]:
        """
        Get calculations by operation type.
        
        Args:
            operation: Operation type (add, subtract, multiply, divide)
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of calculations with the specified operation
        """
        return (
            self.db.query(Calculation)
            .filter(Calculation.operation == operation)
            .order_by(Calculation.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    def get_by_user_and_operation(
        self, 
        user_id: int, 
        operation: str, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[Calculation]:
        """
        Get calculations for a specific user and operation.
        
        Args:
            user_id: User ID
            operation: Operation type
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of calculations matching the criteria
        """
        return (
            self.db.query(Calculation)
            .filter(
                Calculation.user_id == user_id,
                Calculation.operation == operation
            )
            .order_by(Calculation.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    def count_by_user(self, user_id: int) -> int:
        """
        Count calculations for a specific user.
        
        Args:
            user_id: User ID
            
        Returns:
            Number of calculations
        """
        return self.db.query(Calculation).filter(Calculation.user_id == user_id).count()
    
    def count_by_operation(self, operation: str) -> int:
        """
        Count calculations by operation type.
        
        Args:
            operation: Operation type
            
        Returns:
            Number of calculations
        """
        return self.db.query(Calculation).filter(Calculation.operation == operation).count()
    
    def delete_by_user(self, user_id: int) -> int:
        """
        Delete all calculations for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            Number of calculations deleted
        """
        count = self.db.query(Calculation).filter(Calculation.user_id == user_id).count()
        self.db.query(Calculation).filter(Calculation.user_id == user_id).delete()
        self.db.commit()
        return count
    
    def get_user_calculation(self, calculation_id: int, user_id: int) -> Optional[Calculation]:
        """
        Get a specific calculation for a user.
        
        Ensures a user can only access their own calculations.
        
        Args:
            calculation_id: Calculation ID
            user_id: User ID
            
        Returns:
            Calculation if found and belongs to user, None otherwise
        """
        return (
            self.db.query(Calculation)
            .filter(
                Calculation.id == calculation_id,
                Calculation.user_id == user_id
            )
            .first()
        )
    
    def update_user_calculation(
        self, 
        calculation_id: int, 
        user_id: int, 
        **kwargs
    ) -> Optional[Calculation]:
        """
        Update a calculation for a specific user.
        
        Ensures a user can only update their own calculations.
        
        Args:
            calculation_id: Calculation ID
            user_id: User ID
            **kwargs: Fields to update
            
        Returns:
            Updated calculation if found and belongs to user, None otherwise
        """
        calculation = self.get_user_calculation(calculation_id, user_id)
        if calculation:
            for key, value in kwargs.items():
                if hasattr(calculation, key) and value is not None:
                    setattr(calculation, key, value)
            self.db.commit()
            self.db.refresh(calculation)
        return calculation
    
    def delete_user_calculation(self, calculation_id: int, user_id: int) -> bool:
        """
        Delete a calculation for a specific user.
        
        Ensures a user can only delete their own calculations.
        
        Args:
            calculation_id: Calculation ID
            user_id: User ID
            
        Returns:
            True if deleted, False if not found or doesn't belong to user
        """
        calculation = self.get_user_calculation(calculation_id, user_id)
        if calculation:
            self.db.delete(calculation)
            self.db.commit()
            return True
        return False
