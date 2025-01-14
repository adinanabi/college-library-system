# college-library-system
![Library Banner](https://images.pexels.com/photos/2041540/pexels-photo-2041540.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2)  
---
## 📖Overview

This project is a database management application developed as part of the Database Design module coursework for MSc in Computing and Information Systems. It simulates a **College Library System** with functionalities to manage resources, loans, reservations, and fines effectively.

The project involved designing the database schema, normalizing it, and implementing it using **MySQL**. The system supports queries, views, and triggers to handle various library-related operations seamlessly.

---
## Features
- **Database Design**
  - [Conceptual Schema (ER Diagram)](./database-design/er-diagram.png): ER diagram following Chen notation.
  - [Relational Schema](./database-design/relational-schema.pdf): Derived from the ER diagram and normalized to 3NF.
  - [Normalization Documentation](./database-design/normalisation.pdf): Comprehensive documentation of the normalization process.
  - [Data Dictionary](./database-design/data-dictionary.pdf): Description of entities, attributes, and assumptions.

- **Database Implementation**
  - MySQL scripts for:
    - [Create Tables](./sql-scripts/create-tables.sql): Creating tables with primary/foreign key constraints and validation checks.
    - [Insert Data](./sql-scripts/insert-data.sql): Populating the database with significant test data.
    - [Create Views](./sql-scripts/create-views.sql): Specialized views tailored for different user groups.
    - [Queries](./sql-scripts/queries.sql): Pre-defined queries for common operations.
    - [Triggers](./sql-scripts/triggers.sql): Automation for actions like updating resource availability.
---
## ⚙️Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/adinanabi/college-library-system.git
   cd college-library-system
2. **Set up the database**:
  - Run create-tables.sql to create the database schema.
  - Populate the database with sample data using insert-data.sql.
3. **Execute the SQL scripts**:
  - create-views.sql: Creates tailored views for different user roles.
  - queries.sql: Contains 12 pre-defined queries for common operations.
  - triggers.sql: Automates resource availability updates.


---
## Technologies Used
- Database: MySQL
- Languages: SQL
- Tools: MySQL Workbench, ER diagramming tools

---
## License
This project is for educational purposes and is licensed under the [MIT License](./LICENSE).
