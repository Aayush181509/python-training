# SOLID Principles in Python

SOLID is an acronym representing five fundamental design principles of object-oriented programming and design. These principles help developers create more maintainable, understandable, and flexible software.

| Letter | Principle | Description |
|--------|-----------|-------------|
| **S** | Single Responsibility | A class should have only one reason to change |
| **O** | Open/Closed | Open for extension, closed for modification |
| **L** | Liskov Substitution | Subtypes must be substitutable for their base types |
| **I** | Interface Segregation | Many specific interfaces are better than one general interface |
| **D** | Dependency Inversion | Depend on abstractions, not concretions |

---
## 1. Single Responsibility Principle (SRP)

> **"A class should have only one reason to change."**

Each class should focus on doing one thing well. This makes the code easier to understand, test, and maintain.

### ❌ Bad Example - Violating SRP


```python
# BAD: This class has multiple responsibilities
class Employee:
    def __init__(self, name: str, salary: float):
        self.name = name
        self.salary = salary
    
    def calculate_pay(self) -> float:
        """Calculate monthly pay - HR responsibility"""
        return self.salary / 12
    
    def save_to_database(self):
        """Save employee to database - Database responsibility"""
        print(f"Saving {self.name} to database...")
    
    def generate_report(self) -> str:
        """Generate employee report - Reporting responsibility"""
        return f"Employee Report: {self.name}, Annual Salary: ${self.salary}"

# Usage
emp = Employee("John Doe", 60000)
print(emp.calculate_pay())
print(emp.generate_report())
```

    5000.0
    Employee Report: John Doe, Annual Salary: $60000


### ✅ Good Example - Following SRP


```python
# GOOD: Each class has a single responsibility

class Employee:
    """Only responsible for employee data"""
    def __init__(self, name: str, salary: float):
        self.name = name
        self.salary = salary


class PayrollCalculator:
    """Responsible for pay calculations"""
    @staticmethod
    def calculate_monthly_pay(employee: Employee) -> float:
        return employee.salary / 12
    
    @staticmethod
    def calculate_bonus(employee: Employee, percentage: float) -> float:
        return employee.salary * percentage / 100


class EmployeeRepository:
    """Responsible for database operations"""
    def save(self, employee: Employee):
        print(f"Saving {employee.name} to database...")
    
    def find_by_name(self, name: str) -> Employee:
        # Database lookup logic here
        pass


class EmployeeReportGenerator:
    """Responsible for generating reports"""
    @staticmethod
    def generate_summary(employee: Employee) -> str:
        return f"Employee Report: {employee.name}, Annual Salary: ${employee.salary}"
    
    @staticmethod
    def generate_detailed_report(employee: Employee) -> str:
        monthly = PayrollCalculator.calculate_monthly_pay(employee)
        return f"Detailed Report\nName: {employee.name}\nAnnual: ${employee.salary}\nMonthly: ${monthly:.2f}"


# Usage
emp = Employee("John Doe", 60000)
print(PayrollCalculator.calculate_monthly_pay(emp))
print(EmployeeReportGenerator.generate_detailed_report(emp))
```

    5000.0
    Detailed Report
    Name: John Doe
    Annual: $60000
    Monthly: $5000.00


---
## 2. Open/Closed Principle (OCP)

> **"Software entities should be open for extension, but closed for modification."**

You should be able to add new functionality without changing existing code. This is typically achieved through inheritance or composition.

### ❌ Bad Example - Violating OCP


```python
# BAD: Adding new discount types requires modifying this class
class DiscountCalculator:
    def calculate_discount(self, customer_type: str, amount: float) -> float:
        if customer_type == "regular":
            return amount * 0.1
        elif customer_type == "premium":
            return amount * 0.2
        elif customer_type == "vip":
            return amount * 0.3
        # Every new customer type requires modifying this method!
        else:
            return 0

calc = DiscountCalculator()
print(f"Regular discount: ${calc.calculate_discount('regular', 100)}")
print(f"VIP discount: ${calc.calculate_discount('vip', 100)}")
```

    Regular discount: $10.0
    VIP discount: $30.0


### ✅ Good Example - Following OCP


```python
from abc import ABC, abstractmethod

# GOOD: Open for extension (new discount strategies), closed for modification

class DiscountStrategy(ABC):
    """Abstract base class for discount strategies"""
    @abstractmethod
    def calculate(self, amount: float) -> float:
        pass


class RegularDiscount(DiscountStrategy):
    def calculate(self, amount: float) -> float:
        return amount * 0.1


class PremiumDiscount(DiscountStrategy):
    def calculate(self, amount: float) -> float:
        return amount * 0.2


class VIPDiscount(DiscountStrategy):
    def calculate(self, amount: float) -> float:
        return amount * 0.3


# Easy to add new discount types without modifying existing code!
class SeasonalDiscount(DiscountStrategy):
    def __init__(self, seasonal_rate: float = 0.15):
        self.seasonal_rate = seasonal_rate
    
    def calculate(self, amount: float) -> float:
        return amount * self.seasonal_rate


class DiscountCalculator:
    """Calculator that works with any discount strategy"""
    def __init__(self, strategy: DiscountStrategy):
        self.strategy = strategy
    
    def apply_discount(self, amount: float) -> float:
        discount = self.strategy.calculate(amount)
        return amount - discount


# Usage
amount = 100

regular_calc = DiscountCalculator(RegularDiscount())
print(f"Regular: ${amount} -> ${regular_calc.apply_discount(amount)}")

vip_calc = DiscountCalculator(VIPDiscount())
print(f"VIP: ${amount} -> ${vip_calc.apply_discount(amount)}")

seasonal_calc = DiscountCalculator(SeasonalDiscount(0.25))
print(f"Seasonal (25%): ${amount} -> ${seasonal_calc.apply_discount(amount)}")
```

    Regular: $100 -> $90.0
    VIP: $100 -> $70.0
    Seasonal (25%): $100 -> $75.0


---
## 3. Liskov Substitution Principle (LSP)

> **"Objects of a superclass should be replaceable with objects of its subclasses without breaking the application."**

If class B is a subclass of class A, then we should be able to replace A with B without disrupting the behavior of our program.

### ❌ Bad Example - Violating LSP


```python
# BAD: Square violates the expected behavior of Rectangle
class Rectangle:
    def __init__(self, width: int, height: int):
        self._width = width
        self._height = height
    
    @property
    def width(self) -> int:
        return self._width
    
    @width.setter
    def width(self, value: int):
        self._width = value
    
    @property
    def height(self) -> int:
        return self._height
    
    @height.setter
    def height(self, value: int):
        self._height = value
    
    def area(self) -> int:
        return self._width * self._height


class Square(Rectangle):
    def __init__(self, size: int):
        super().__init__(size, size)
    
    @Rectangle.width.setter
    def width(self, value: int):
        # This breaks LSP - changing width also changes height
        self._width = value
        self._height = value
    
    @Rectangle.height.setter
    def height(self, value: int):
        # This breaks LSP - changing height also changes width
        self._width = value
        self._height = value


def print_area(shape: Rectangle):
    shape.width = 5
    shape.height = 10
    # We expect area to be 50 for any Rectangle
    print(f"Expected area: 50, Actual area: {shape.area()}")

# This works correctly
rect = Rectangle(2, 3)
print_area(rect)

# This violates LSP - we get 100 instead of 50!
square = Square(5)
print_area(square)
```

    Expected area: 50, Actual area: 50
    Expected area: 50, Actual area: 100


### ✅ Good Example - Following LSP


```python
from abc import ABC, abstractmethod

# GOOD: Use a common abstraction that both shapes can properly implement

class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass
    
    @abstractmethod
    def perimeter(self) -> float:
        pass


class Rectangle(Shape):
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height
    
    def area(self) -> float:
        return self.width * self.height
    
    def perimeter(self) -> float:
        return 2 * (self.width + self.height)


class Square(Shape):
    def __init__(self, side: float):
        self.side = side
    
    def area(self) -> float:
        return self.side ** 2
    
    def perimeter(self) -> float:
        return 4 * self.side


class Circle(Shape):
    def __init__(self, radius: float):
        self.radius = radius
    
    def area(self) -> float:
        import math
        return math.pi * self.radius ** 2
    
    def perimeter(self) -> float:
        import math
        return 2 * math.pi * self.radius


def print_shape_info(shape: Shape):
    """Works correctly with any Shape subclass"""
    print(f"Area: {shape.area():.2f}, Perimeter: {shape.perimeter():.2f}")


# All shapes work correctly - LSP is satisfied
shapes = [
    Rectangle(5, 10),
    Square(7),
    Circle(5)
]

for shape in shapes:
    print(f"{shape.__class__.__name__}: ", end="")
    print_shape_info(shape)
```

    Rectangle: Area: 50.00, Perimeter: 30.00
    Square: Area: 49.00, Perimeter: 28.00
    Circle: Area: 78.54, Perimeter: 31.42


---
## 4. Interface Segregation Principle (ISP)

> **"Clients should not be forced to depend on interfaces they do not use."**

Instead of one large interface, it's better to have many smaller, more specific interfaces. Classes should only implement the methods they need.

### ❌ Bad Example - Violating ISP


```python
from abc import ABC, abstractmethod

# BAD: One large interface that forces classes to implement methods they don't need
class Worker(ABC):
    @abstractmethod
    def work(self):
        pass
    
    @abstractmethod
    def eat(self):
        pass
    
    @abstractmethod
    def sleep(self):
        pass
    
    @abstractmethod
    def code(self):
        pass
    
    @abstractmethod
    def manage(self):
        pass


class Developer(Worker):
    def work(self):
        print("Developer is working")
    
    def eat(self):
        print("Developer is eating")
    
    def sleep(self):
        print("Developer is sleeping")
    
    def code(self):
        print("Developer is coding")
    
    def manage(self):
        # Developers don't manage! But forced to implement this
        raise NotImplementedError("Developers don't manage!")


class Robot(Worker):
    def work(self):
        print("Robot is working")
    
    def eat(self):
        # Robots don't eat! But forced to implement this
        raise NotImplementedError("Robots don't eat!")
    
    def sleep(self):
        # Robots don't sleep!
        raise NotImplementedError("Robots don't sleep!")
    
    def code(self):
        print("Robot is coding")
    
    def manage(self):
        raise NotImplementedError("Robots don't manage!")


dev = Developer()
dev.code()
```

    Developer is coding


### ✅ Good Example - Following ISP


```python
from abc import ABC, abstractmethod

# GOOD: Small, specific interfaces

class Workable(ABC):
    @abstractmethod
    def work(self):
        pass


class Eatable(ABC):
    @abstractmethod
    def eat(self):
        pass


class Sleepable(ABC):
    @abstractmethod
    def sleep(self):
        pass


class Codeable(ABC):
    @abstractmethod
    def code(self):
        pass


class Manageable(ABC):
    @abstractmethod
    def manage(self):
        pass


# Developer implements only what it needs
class Developer(Workable, Eatable, Sleepable, Codeable):
    def work(self):
        print("Developer is working")
    
    def eat(self):
        print("Developer is eating")
    
    def sleep(self):
        print("Developer is sleeping")
    
    def code(self):
        print("Developer is coding")


# Manager implements only what it needs
class Manager(Workable, Eatable, Sleepable, Manageable):
    def work(self):
        print("Manager is working")
    
    def eat(self):
        print("Manager is eating")
    
    def sleep(self):
        print("Manager is sleeping")
    
    def manage(self):
        print("Manager is managing the team")


# Robot only implements what robots can do
class Robot(Workable, Codeable):
    def work(self):
        print("Robot is working")
    
    def code(self):
        print("Robot is coding")


# Usage
dev = Developer()
dev.work()
dev.code()

robot = Robot()
robot.work()
robot.code()
```

    Developer is working
    Developer is coding
    Robot is working
    Robot is coding


---
## 5. Dependency Inversion Principle (DIP)

> **"High-level modules should not depend on low-level modules. Both should depend on abstractions."**

> **"Abstractions should not depend on details. Details should depend on abstractions."**

This principle promotes loose coupling between classes by introducing abstractions (interfaces) between them.

### ❌ Bad Example - Violating DIP


```python
# BAD: High-level module directly depends on low-level modules

class MySQLDatabase:
    def connect(self):
        print("Connecting to MySQL...")
    
    def execute(self, query: str):
        print(f"MySQL executing: {query}")


class EmailService:
    def send_email(self, to: str, message: str):
        print(f"Sending email to {to}: {message}")


class UserService:
    """High-level module directly depends on concrete implementations"""
    def __init__(self):
        # Tightly coupled to specific implementations
        self.database = MySQLDatabase()
        self.email_service = EmailService()
    
    def create_user(self, name: str, email: str):
        self.database.connect()
        self.database.execute(f"INSERT INTO users VALUES ('{name}', '{email}')")
        self.email_service.send_email(email, f"Welcome, {name}!")


# Hard to test, hard to switch databases or email providers
service = UserService()
service.create_user("John", "john@example.com")
```

    Connecting to MySQL...
    MySQL executing: INSERT INTO users VALUES ('John', 'john@example.com')
    Sending email to john@example.com: Welcome, John!


### ✅ Good Example - Following DIP


```python
from abc import ABC, abstractmethod

# GOOD: Depend on abstractions

# Abstractions (Interfaces)
class Database(ABC):
    @abstractmethod
    def connect(self):
        pass
    
    @abstractmethod
    def execute(self, query: str):
        pass


class NotificationService(ABC):
    @abstractmethod
    def send(self, to: str, message: str):
        pass


# Concrete implementations
class MySQLDatabase(Database):
    def connect(self):
        print("Connecting to MySQL...")
    
    def execute(self, query: str):
        print(f"MySQL executing: {query}")


class PostgreSQLDatabase(Database):
    def connect(self):
        print("Connecting to PostgreSQL...")
    
    def execute(self, query: str):
        print(f"PostgreSQL executing: {query}")


class EmailNotification(NotificationService):
    def send(self, to: str, message: str):
        print(f"Email to {to}: {message}")


class SMSNotification(NotificationService):
    def send(self, to: str, message: str):
        print(f"SMS to {to}: {message}")


class PushNotification(NotificationService):
    def send(self, to: str, message: str):
        print(f"Push notification to {to}: {message}")


# High-level module depends on abstractions
class UserService:
    def __init__(self, database: Database, notifier: NotificationService):
        self.database = database
        self.notifier = notifier
    
    def create_user(self, name: str, contact: str):
        self.database.connect()
        self.database.execute(f"INSERT INTO users VALUES ('{name}', '{contact}')")
        self.notifier.send(contact, f"Welcome, {name}!")


# Easy to switch implementations!
print("Using MySQL + Email:")
service1 = UserService(MySQLDatabase(), EmailNotification())
service1.create_user("John", "john@example.com")

print("\nUsing PostgreSQL + SMS:")
service2 = UserService(PostgreSQLDatabase(), SMSNotification())
service2.create_user("Jane", "+1234567890")
```

    Using MySQL + Email:
    Connecting to MySQL...
    MySQL executing: INSERT INTO users VALUES ('John', 'john@example.com')
    Email to john@example.com: Welcome, John!
    
    Using PostgreSQL + SMS:
    Connecting to PostgreSQL...
    PostgreSQL executing: INSERT INTO users VALUES ('Jane', '+1234567890')
    SMS to +1234567890: Welcome, Jane!


### Testing with DIP - Mock Implementations


```python
# DIP makes testing easy with mock implementations

class MockDatabase(Database):
    def __init__(self):
        self.queries = []
    
    def connect(self):
        print("Mock DB connected")
    
    def execute(self, query: str):
        self.queries.append(query)
        print(f"Mock DB recorded query: {query}")


class MockNotification(NotificationService):
    def __init__(self):
        self.sent_messages = []
    
    def send(self, to: str, message: str):
        self.sent_messages.append((to, message))
        print(f"Mock notification recorded: {to} -> {message}")


# Testing with mocks
print("Testing UserService:")
mock_db = MockDatabase()
mock_notifier = MockNotification()

test_service = UserService(mock_db, mock_notifier)
test_service.create_user("TestUser", "test@test.com")

# Verify behavior
print(f"\nQueries executed: {mock_db.queries}")
print(f"Notifications sent: {mock_notifier.sent_messages}")
```

    Testing UserService:
    Mock DB connected
    Mock DB recorded query: INSERT INTO users VALUES ('TestUser', 'test@test.com')
    Mock notification recorded: test@test.com -> Welcome, TestUser!
    
    Queries executed: ["INSERT INTO users VALUES ('TestUser', 'test@test.com')"]
    Notifications sent: [('test@test.com', 'Welcome, TestUser!')]


---
## Real-World Example: Order Processing System

Let's combine all SOLID principles in a practical example.


```python
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List
from datetime import datetime


# === Data Classes (Single Responsibility) ===
@dataclass
class Product:
    id: str
    name: str
    price: float


@dataclass
class OrderItem:
    product: Product
    quantity: int
    
    @property
    def total(self) -> float:
        return self.product.price * self.quantity


@dataclass
class Order:
    id: str
    items: List[OrderItem]
    customer_email: str
    created_at: datetime = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()
    
    @property
    def subtotal(self) -> float:
        return sum(item.total for item in self.items)
```


```python
# === Interfaces (Interface Segregation) ===

class PaymentProcessor(ABC):
    @abstractmethod
    def process_payment(self, amount: float) -> bool:
        pass


class DiscountCalculator(ABC):
    @abstractmethod
    def calculate_discount(self, order: Order) -> float:
        pass


class TaxCalculator(ABC):
    @abstractmethod
    def calculate_tax(self, amount: float) -> float:
        pass


class OrderRepository(ABC):
    @abstractmethod
    def save(self, order: Order) -> None:
        pass
    
    @abstractmethod
    def find_by_id(self, order_id: str) -> Order:
        pass


class Notifier(ABC):
    @abstractmethod
    def notify(self, recipient: str, message: str) -> None:
        pass
```


```python
# === Concrete Implementations (Open/Closed - can add new ones without modifying existing) ===

class CreditCardProcessor(PaymentProcessor):
    def process_payment(self, amount: float) -> bool:
        print(f"Processing ${amount:.2f} via Credit Card")
        return True


class PayPalProcessor(PaymentProcessor):
    def process_payment(self, amount: float) -> bool:
        print(f"Processing ${amount:.2f} via PayPal")
        return True


class PercentageDiscount(DiscountCalculator):
    def __init__(self, percentage: float):
        self.percentage = percentage
    
    def calculate_discount(self, order: Order) -> float:
        return order.subtotal * (self.percentage / 100)


class BulkDiscount(DiscountCalculator):
    def calculate_discount(self, order: Order) -> float:
        total_items = sum(item.quantity for item in order.items)
        if total_items >= 10:
            return order.subtotal * 0.15
        elif total_items >= 5:
            return order.subtotal * 0.10
        return 0


class StandardTax(TaxCalculator):
    def __init__(self, rate: float = 0.13):
        self.rate = rate
    
    def calculate_tax(self, amount: float) -> float:
        return amount * self.rate


class InMemoryOrderRepository(OrderRepository):
    def __init__(self):
        self._orders = {}
    
    def save(self, order: Order) -> None:
        self._orders[order.id] = order
        print(f"Order {order.id} saved to memory")
    
    def find_by_id(self, order_id: str) -> Order:
        return self._orders.get(order_id)


class EmailNotifier(Notifier):
    def notify(self, recipient: str, message: str) -> None:
        print(f"Email sent to {recipient}: {message}")
```


```python
# === Order Service (Dependency Inversion - depends on abstractions) ===

class OrderService:
    """High-level module that orchestrates order processing"""
    
    def __init__(
        self,
        payment_processor: PaymentProcessor,
        discount_calculator: DiscountCalculator,
        tax_calculator: TaxCalculator,
        repository: OrderRepository,
        notifier: Notifier
    ):
        self.payment_processor = payment_processor
        self.discount_calculator = discount_calculator
        self.tax_calculator = tax_calculator
        self.repository = repository
        self.notifier = notifier
    
    def process_order(self, order: Order) -> bool:
        """Process an order: calculate totals, payment, save, notify"""
        print(f"\n{'='*50}")
        print(f"Processing Order: {order.id}")
        print(f"{'='*50}")
        
        # Calculate totals
        subtotal = order.subtotal
        discount = self.discount_calculator.calculate_discount(order)
        after_discount = subtotal - discount
        tax = self.tax_calculator.calculate_tax(after_discount)
        total = after_discount + tax
        
        print(f"Subtotal: ${subtotal:.2f}")
        print(f"Discount: -${discount:.2f}")
        print(f"Tax: +${tax:.2f}")
        print(f"Total: ${total:.2f}")
        
        # Process payment
        if self.payment_processor.process_payment(total):
            self.repository.save(order)
            self.notifier.notify(
                order.customer_email,
                f"Your order {order.id} has been confirmed! Total: ${total:.2f}"
            )
            return True
        return False
```


```python
# === Putting it all together ===

# Create products
laptop = Product("P001", "Laptop", 999.99)
mouse = Product("P002", "Mouse", 49.99)
keyboard = Product("P003", "Keyboard", 79.99)

# Create order
order = Order(
    id="ORD-001",
    items=[
        OrderItem(laptop, 1),
        OrderItem(mouse, 2),
        OrderItem(keyboard, 1)
    ],
    customer_email="customer@example.com"
)

# Create service with specific implementations
order_service = OrderService(
    payment_processor=CreditCardProcessor(),
    discount_calculator=PercentageDiscount(10),  # 10% discount
    tax_calculator=StandardTax(0.13),  # 13% tax
    repository=InMemoryOrderRepository(),
    notifier=EmailNotifier()
)

# Process the order
order_service.process_order(order)
```

    
    ==================================================
    Processing Order: ORD-001
    ==================================================
    Subtotal: $1179.96
    Discount: -$118.00
    Tax: +$138.06
    Total: $1200.02
    Processing $1200.02 via Credit Card
    Order ORD-001 saved to memory
    Email sent to customer@example.com: Your order ORD-001 has been confirmed! Total: $1200.02





    True




```python
# Easy to swap implementations!
# Process same type of order with different configurations

bulk_order = Order(
    id="ORD-002",
    items=[
        OrderItem(mouse, 5),
        OrderItem(keyboard, 5)
    ],
    customer_email="bulk@example.com"
)

# Different service configuration - PayPal + Bulk discount
bulk_order_service = OrderService(
    payment_processor=PayPalProcessor(),
    discount_calculator=BulkDiscount(),
    tax_calculator=StandardTax(0.08),  # Different tax rate
    repository=InMemoryOrderRepository(),
    notifier=EmailNotifier()
)

bulk_order_service.process_order(bulk_order)
```

    
    ==================================================
    Processing Order: ORD-002
    ==================================================
    Subtotal: $649.90
    Discount: -$97.48
    Tax: +$44.19
    Total: $596.61
    Processing $596.61 via PayPal
    Order ORD-002 saved to memory
    Email sent to bulk@example.com: Your order ORD-002 has been confirmed! Total: $596.61





    True



---
## Summary

| Principle | Key Idea | Benefit |
|-----------|----------|--------|
| **SRP** | One class, one responsibility | Easier testing and maintenance |
| **OCP** | Extend without modifying | Reduces risk of breaking existing code |
| **LSP** | Subclasses are substitutable | Reliable polymorphism |
| **ISP** | Small, specific interfaces | No forced implementations |
| **DIP** | Depend on abstractions | Loose coupling, easy testing |

### Key Takeaways

1. **Start simple** - Don't over-engineer. Apply SOLID when complexity grows.
2. **Use abstractions** - Python's `ABC` module helps define interfaces.
3. **Dependency Injection** - Pass dependencies instead of creating them inside classes.
4. **Composition over inheritance** - Often leads to more flexible code.
5. **Test-Driven Development** - SOLID principles naturally emerge when writing testable code.
