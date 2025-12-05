# 🏗️ SOLID Principles and Design Patterns Implementation

This document explains how SOLID principles and design patterns are implemented in the FastAPI Calculator application.

---

## 📐 SOLID Principles

### 1. Single Responsibility Principle (SRP)
> "A class should have one, and only one, reason to change."

#### Implementation in Our Project:

**✅ Models Package (`app/models/`)**
- **Responsibility**: Define database schema and ORM mappings only
- `user.py` - Handles User table structure
- `calculation.py` - Handles Calculation table structure
- Each model focuses solely on data structure

**✅ Schemas Package (`app/schemas/`)**
- **Responsibility**: Request/response validation and data transfer
- `user.py` - User data validation schemas
- `calculation.py` - Calculation data validation schemas
- `token.py` - Token response schemas
- Separated from models to avoid mixing concerns

**✅ Auth Package (`app/auth/`)**
- **Responsibility**: Authentication and security
- `jwt.py` - JWT token creation and validation
- `dependencies.py` - Authentication dependencies
- `redis.py` - Token blacklisting
- Each module has a specific security-related purpose

**✅ Core Package (`app/core/`)**
- **Responsibility**: Application configuration
- `config.py` - Centralized configuration management
- Single source of truth for settings

**Example:**
```python
# ❌ BAD: Multiple responsibilities
class User:
    def __init__(self, username, password):
        self.username = username
        self.password = password
    
    def save_to_database(self):
        # Database logic
        pass
    
    def send_welcome_email(self):
        # Email logic
        pass
    
    def hash_password(self):
        # Security logic
        pass

# ✅ GOOD: Single responsibility
# models/user.py - Database structure only
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    hashed_password = Column(String)

# auth/password.py - Security only
class PasswordHasher:
    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)

# services/email.py - Email only
class EmailService:
    @staticmethod
    def send_welcome_email(user: User):
        pass
```

---

### 2. Open/Closed Principle (OCP)
> "Software entities should be open for extension but closed for modification."

#### Implementation in Our Project:

**✅ Schema Inheritance**
```python
# schemas/base.py
class BaseSchema(BaseModel):
    """Base schema with common configuration"""
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {}
        }

# schemas/user.py - Extended without modifying base
class UserCreate(BaseSchema):
    username: str
    email: EmailStr
    password: str

class UserResponse(BaseSchema):
    id: int
    username: str
    email: EmailStr
    is_active: bool
```

**✅ Calculation Operations - Strategy Pattern**

Create a new file to demonstrate extensibility:

```python
# operations/calculator.py
from abc import ABC, abstractmethod
from typing import Union

class CalculationStrategy(ABC):
    """Abstract base class for calculation strategies"""
    
    @abstractmethod
    def calculate(self, a: float, b: float) -> float:
        pass

class AdditionStrategy(CalculationStrategy):
    def calculate(self, a: float, b: float) -> float:
        return a + b

class SubtractionStrategy(CalculationStrategy):
    def calculate(self, a: float, b: float) -> float:
        return a - b

class MultiplicationStrategy(CalculationStrategy):
    def calculate(self, a: float, b: float) -> float:
        return a * b

class DivisionStrategy(CalculationStrategy):
    def calculate(self, a: float, b: float) -> float:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

# Calculator using strategies - can add new operations without modification
class Calculator:
    def __init__(self):
        self._strategies = {
            'add': AdditionStrategy(),
            'subtract': SubtractionStrategy(),
            'multiply': MultiplicationStrategy(),
            'divide': DivisionStrategy()
        }
    
    def register_strategy(self, operation: str, strategy: CalculationStrategy):
        """Register new calculation strategy without modifying existing code"""
        self._strategies[operation] = strategy
    
    def calculate(self, operation: str, a: float, b: float) -> float:
        if operation not in self._strategies:
            raise ValueError(f"Unknown operation: {operation}")
        return self._strategies[operation].calculate(a, b)

# Usage - Easy to extend with new operations
calculator = Calculator()

# Can add new operations without modifying Calculator class
class PowerStrategy(CalculationStrategy):
    def calculate(self, a: float, b: float) -> float:
        return a ** b

calculator.register_strategy('power', PowerStrategy())
```

---

### 3. Liskov Substitution Principle (LSP)
> "Derived classes must be substitutable for their base classes."

#### Implementation in Our Project:

**✅ Database Models**
```python
# All models inherit from Base and can be used interchangeably
from app.database import Base

class User(Base):
    __tablename__ = "users"
    # User-specific fields

class Calculation(Base):
    __tablename__ = "calculations"
    # Calculation-specific fields

# Both can be used with SQLAlchemy Session operations
def get_entity(session: Session, model_class: Base, entity_id: int):
    """Works with any model that inherits from Base"""
    return session.query(model_class).filter(model_class.id == entity_id).first()

# Usage
user = get_entity(session, User, 1)
calc = get_entity(session, Calculation, 1)
```

**✅ Pydantic Schemas**
```python
# All schemas inherit from BaseModel and maintain substitutability
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str
    # Can be used wherever UserBase is expected

class UserResponse(UserBase):
    id: int
    is_active: bool
    # Can also be used wherever UserBase is expected

# Function accepting base type works with derived types
def validate_user_data(user: UserBase) -> bool:
    return len(user.username) >= 3 and '@' in user.email

# Works with all derived types
validate_user_data(UserCreate(username="test", email="test@example.com", password="pass"))
validate_user_data(UserResponse(id=1, username="test", email="test@example.com", is_active=True))
```

---

### 4. Interface Segregation Principle (ISP)
> "Clients should not be forced to depend on interfaces they don't use."

#### Implementation in Our Project:

**✅ Separate Schemas for Different Use Cases**
```python
# schemas/user.py

# CREATE - Only fields needed for creation
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

# UPDATE - Only fields that can be updated
class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None

# RESPONSE - Only fields for API responses (no password)
class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    is_active: bool
    created_at: datetime

# LOGIN - Only fields needed for login
class UserLogin(BaseModel):
    username: str
    password: str

# Clients only depend on what they need:
# - Registration endpoint uses UserCreate
# - Update endpoint uses UserUpdate
# - Get user endpoint uses UserResponse
# - Login endpoint uses UserLogin
```

**✅ Calculation Schemas**
```python
# schemas/calculation.py

# Base - Common fields
class CalculationBase(BaseModel):
    operation: str
    operand_a: float
    operand_b: float

# Create - Fields needed for creation
class CalculationCreate(CalculationBase):
    pass

# Update - Only fields that can be updated
class CalculationUpdate(BaseModel):
    operation: Optional[str] = None
    operand_a: Optional[float] = None
    operand_b: Optional[float] = None

# Response - Includes computed result
class CalculationResponse(CalculationBase):
    id: int
    result: float
    user_id: int
    created_at: datetime
```

---

### 5. Dependency Inversion Principle (DIP)
> "Depend on abstractions, not concretions."

#### Implementation in Our Project:

**✅ Database Dependency Injection**
```python
# database.py - Abstraction
def get_db():
    """Dependency that provides database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# main.py - High-level module depends on abstraction
@app.post("/calculations/", response_model=CalculationResponse)
def create_calculation(
    calculation: CalculationCreate,
    db: Session = Depends(get_db),  # Depends on abstraction
    current_user: User = Depends(get_current_active_user)
):
    # Business logic doesn't care about database implementation
    new_calc = Calculation(**calculation.dict(), user_id=current_user.id)
    db.add(new_calc)
    db.commit()
    return new_calc
```

**✅ Authentication Dependency**
```python
# auth/dependencies.py - Abstraction
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """Abstract authentication - could be JWT, OAuth, API Key, etc."""
    # Implementation details hidden
    credentials_exception = HTTPException(...)
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception
    return user

# main.py - Depends on abstraction
@app.get("/calculations/", response_model=List[CalculationResponse])
def list_calculations(
    current_user: User = Depends(get_current_active_user),  # Don't care how auth works
    db: Session = Depends(get_db)
):
    return db.query(Calculation).filter(Calculation.user_id == current_user.id).all()
```

**✅ Configuration Dependency**
```python
# core/config.py - Abstraction
class Settings(BaseSettings):
    DATABASE_URL: str
    JWT_SECRET_KEY: str
    # ... other settings
    
    class Config:
        env_file = ".env"

settings = Settings()

# Other modules depend on settings abstraction
# Can easily swap implementations (env vars, config files, AWS Secrets Manager, etc.)
```

---

## 🎨 Design Patterns

### 1. Repository Pattern

The Repository pattern abstracts data access logic.

**Implementation:**
```python
# repositories/user_repository.py
from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate

class UserRepository:
    """Repository for User data access"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, user_id: int) -> Optional[User]:
        return self.db.query(User).filter(User.id == user_id).first()
    
    def get_by_username(self, username: str) -> Optional[User]:
        return self.db.query(User).filter(User.username == username).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        return self.db.query(User).offset(skip).limit(limit).all()
    
    def create(self, user_data: UserCreate) -> User:
        db_user = User(**user_data.dict(exclude={'password'}))
        # Handle password hashing
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        return db_user
    
    def update(self, user: User, updates: dict) -> User:
        for key, value in updates.items():
            setattr(user, key, value)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def delete(self, user: User) -> None:
        self.db.delete(user)
        self.db.commit()

# Usage in endpoints
def get_user_endpoint(
    user_id: int,
    db: Session = Depends(get_db)
):
    repo = UserRepository(db)
    user = repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404)
    return user
```

---

### 2. Factory Pattern

The Factory pattern creates objects without exposing creation logic.

**Implementation:**
```python
# auth/jwt.py - Token Factory
from datetime import datetime, timedelta
from jose import jwt
from app.core.config import settings

class TokenFactory:
    """Factory for creating JWT tokens"""
    
    @staticmethod
    def create_access_token(data: dict) -> str:
        """Create access token with expiration"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire, "type": "access"})
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.ALGORITHM)
    
    @staticmethod
    def create_refresh_token(data: dict) -> str:
        """Create refresh token with longer expiration"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode.update({"exp": expire, "type": "refresh"})
        return jwt.encode(to_encode, settings.JWT_REFRESH_SECRET_KEY, algorithm=settings.ALGORITHM)
    
    @classmethod
    def create_tokens(cls, user_id: int, username: str) -> dict:
        """Factory method to create both tokens"""
        data = {"sub": username, "user_id": user_id}
        return {
            "access_token": cls.create_access_token(data),
            "refresh_token": cls.create_refresh_token(data),
            "token_type": "bearer"
        }

# Usage
tokens = TokenFactory.create_tokens(user.id, user.username)
```

---

### 3. Strategy Pattern

The Strategy pattern defines a family of algorithms and makes them interchangeable.

**Implementation:** (Already shown in OCP section)

Additional example:
```python
# auth/password_strategies.py
from abc import ABC, abstractmethod
from passlib.context import CryptContext

class PasswordHashStrategy(ABC):
    @abstractmethod
    def hash(self, password: str) -> str:
        pass
    
    @abstractmethod
    def verify(self, plain_password: str, hashed_password: str) -> bool:
        pass

class BcryptStrategy(PasswordHashStrategy):
    def __init__(self, rounds: int = 12):
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=rounds)
    
    def hash(self, password: str) -> str:
        return self.pwd_context.hash(password)
    
    def verify(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)

class Argon2Strategy(PasswordHashStrategy):
    def __init__(self):
        self.pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
    
    def hash(self, password: str) -> str:
        return self.pwd_context.hash(password)
    
    def verify(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)

# Password manager using strategy
class PasswordManager:
    def __init__(self, strategy: PasswordHashStrategy):
        self._strategy = strategy
    
    def set_strategy(self, strategy: PasswordHashStrategy):
        self._strategy = strategy
    
    def hash_password(self, password: str) -> str:
        return self._strategy.hash(password)
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self._strategy.verify(plain_password, hashed_password)

# Usage - Easy to switch hashing algorithms
password_manager = PasswordManager(BcryptStrategy(rounds=12))
hashed = password_manager.hash_password("mypassword")

# Can switch to Argon2 without changing client code
password_manager.set_strategy(Argon2Strategy())
```

---

### 4. Dependency Injection Pattern

FastAPI's built-in dependency injection system.

**Implementation:**
```python
# Multiple levels of dependencies
from fastapi import Depends

# Level 1: Database
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Level 2: Authentication (depends on database)
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    # Validate token and get user
    return user

# Level 3: Authorization (depends on authentication)
async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# Level 4: Business logic (depends on authorization and database)
@app.post("/calculations/")
def create_calculation(
    calculation: CalculationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # All dependencies automatically injected
    # Clean, testable, and maintainable
    pass
```

---

### 5. Singleton Pattern

Ensures only one instance of a class exists.

**Implementation:**
```python
# core/config.py
from functools import lru_cache

@lru_cache()  # Singleton through memoization
def get_settings() -> Settings:
    return Settings()

# Always returns the same instance
settings1 = get_settings()
settings2 = get_settings()
# settings1 is settings2 == True
```

---

### 6. Builder Pattern

Constructs complex objects step by step.

**Implementation:**
```python
# services/calculation_builder.py
from typing import Optional
from app.models.calculation import Calculation
from app.operations.calculator import Calculator

class CalculationBuilder:
    """Builder for creating calculations with validation"""
    
    def __init__(self):
        self._operation: Optional[str] = None
        self._operand_a: Optional[float] = None
        self._operand_b: Optional[float] = None
        self._user_id: Optional[int] = None
        self._calculator = Calculator()
    
    def set_operation(self, operation: str) -> 'CalculationBuilder':
        self._operation = operation
        return self
    
    def set_operands(self, a: float, b: float) -> 'CalculationBuilder':
        self._operand_a = a
        self._operand_b = b
        return self
    
    def set_user(self, user_id: int) -> 'CalculationBuilder':
        self._user_id = user_id
        return self
    
    def validate(self) -> bool:
        """Validate all required fields are set"""
        return all([
            self._operation is not None,
            self._operand_a is not None,
            self._operand_b is not None,
            self._user_id is not None
        ])
    
    def build(self) -> Calculation:
        """Build and return the calculation"""
        if not self.validate():
            raise ValueError("Cannot build calculation: missing required fields")
        
        result = self._calculator.calculate(
            self._operation,
            self._operand_a,
            self._operand_b
        )
        
        return Calculation(
            operation=self._operation,
            operand_a=self._operand_a,
            operand_b=self._operand_b,
            result=result,
            user_id=self._user_id
        )

# Usage - Fluent interface
calculation = (CalculationBuilder()
    .set_operation("add")
    .set_operands(10, 5)
    .set_user(user.id)
    .build())
```

---

## 📊 Benefits Summary

### SOLID Principles Benefits:
1. **Maintainability** - Easy to understand and modify
2. **Testability** - Components can be tested in isolation
3. **Flexibility** - Easy to extend without breaking existing code
4. **Reusability** - Components can be reused across the application
5. **Scalability** - Architecture supports growth

### Design Patterns Benefits:
1. **Repository** - Centralized data access, easy to test
2. **Factory** - Simplified object creation, consistent interface
3. **Strategy** - Flexible algorithms, easy to extend
4. **Dependency Injection** - Loose coupling, highly testable
5. **Singleton** - Controlled resource access
6. **Builder** - Complex object construction, readable code

---

## 🧪 Testing with SOLID & Patterns

The architecture makes testing easier:

```python
# test_calculator_with_patterns.py
import pytest
from app.operations.calculator import Calculator, AdditionStrategy, PowerStrategy

def test_calculator_strategy_pattern():
    """Test calculator with strategy pattern"""
    calculator = Calculator()
    
    # Test built-in strategies
    assert calculator.calculate('add', 5, 3) == 8
    assert calculator.calculate('multiply', 5, 3) == 15
    
    # Test extensibility - add new strategy
    calculator.register_strategy('power', PowerStrategy())
    assert calculator.calculate('power', 2, 3) == 8

def test_dependency_injection():
    """Test with mocked dependencies"""
    from unittest.mock import Mock
    
    # Mock database
    mock_db = Mock()
    mock_user = Mock(id=1, username="testuser")
    
    # Function using dependency injection is easy to test
    def get_user(user_id: int, db=mock_db):
        return db.query().filter().first()
    
    # No need for real database in tests
    mock_db.query().filter().first.return_value = mock_user
    user = get_user(1)
    assert user.username == "testuser"
```

---

## 📚 Further Reading

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns by Gang of Four](https://en.wikipedia.org/wiki/Design_Patterns)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [FastAPI Dependency Injection](https://fastapi.tiangolo.com/tutorial/dependencies/)
- [Python Design Patterns](https://refactoring.guru/design-patterns/python)

---

## ✅ Compliance Checklist

- [x] Single Responsibility - Each module has one purpose
- [x] Open/Closed - Extensible without modification
- [x] Liskov Substitution - Derived classes are interchangeable
- [x] Interface Segregation - Minimal, focused interfaces
- [x] Dependency Inversion - Depend on abstractions
- [x] Repository Pattern - Data access abstraction
- [x] Factory Pattern - Object creation
- [x] Strategy Pattern - Interchangeable algorithms
- [x] Dependency Injection - Loose coupling
- [x] Singleton Pattern - Single instance
- [x] Builder Pattern - Complex construction

Your application now follows industry best practices! 🎉
