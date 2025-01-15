# college-library-system
![Library Banner](https://images.pexels.com/photos/2041540/pexels-photo-2041540.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2)  
---
## Overview

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
    - [Triggers](./sql-scripts/triggers.sql): Automation for actions like updating resource availability.
    - [Insert Data](./sql-scripts/insert-data.sql): Populating the database with significant test data.
    - [Create Views](./sql-scripts/create-views.sql): Specialized views tailored for different user groups.
    - [Queries](./sql-scripts/queries.sql): Pre-defined queries for common operations.

---
## Objectives and How They Are Solved

### 🎯 Objectives
1. **Efficient Resource Management**: Track and manage books, DVDs, CDs, and other resources.
2. **Loan and Reservation Tracking**: Monitor loans, reservations, and overdue items.
3. **Fine Management**: Calculate and track overdue fines and payments.
4. **Demand Analysis**: Identify popular resources to aid library staff in decision-making.
5. **Automated Operations**: Use triggers to ensure real-time updates for availability and fines.

### Solutions
- **Resource Management**:
  - Comprehensive database schema with entities like `Resource`, `Member`, `Loan`, `Reservation`, and more.
  - Each resource is categorized with details such as class, format, and location.

- **Loan and Reservation Tracking**:
  - A normalized schema tracks which resources are loaned or reserved by members.
  - Views provide real-time insights into overdue loans and pending reservations.

- **Fine Management**:
  - A `Fine` table and SQL triggers calculate overdue fines based on days exceeded.

- **Demand Analysis**:
  - Views analyze loan and reservation data to identify high-demand resources.

- **Automated Operations**:
  - Triggers handle updates for resource availability and member status (e.g., suspension due to unpaid fines).

---
## ER Diagram
Below is the ER diagram illustrating the conceptual schema of the database:
![ER_Diagram](./screenshots/popular-resources.png)
---
## Key Outputs: Views and Queries

### 📊 Views

### 1. **Popular Resources**
- **Purpose**: This view helps librarians monitor and analyze library services by displaying the number of existing copies, loans, and reservations for each resource. It allows librarians to:
  - Assess the demand for specific resources.
  - Strategically add more copies of high-demand items.
  - Adjust loan periods (e.g., shortening them to 7 days) based on resource usage.
- **SQL Code**:
  ```sql
  CREATE VIEW PopularResources1 AS 
  SELECT
      R.ResourceID,
      R.Title,
      R.LoanType,
      COUNT(DISTINCT C.CopyNumber) AS NumOfCopies,
      COUNT(DISTINCT L.LoanNumber) AS NumOfLoans,
      COUNT(DISTINCT RS.ReservationNumber) AS NumOfReservations
  FROM RESOURCE_T R
  LEFT JOIN COPY C ON R.ResourceID = C.ResourceID
  LEFT JOIN LOAN L ON R.ResourceID = L.ResourceID
  LEFT JOIN RESERVATION RS ON R.ResourceID = RS.ResourceID
  GROUP BY R.ResourceID, R.Title, R.LoanType
  ORDER BY NumOfLoans DESC;
- **Output**:
  ![Popular Resources Output](./screenshots/popular-resources.png)

### 2. **Overdue Loans**
- **Purpose**: This view provides real-time monitoring of loan records within the library system. It is primarily used by librarians to:
  - Display details of all loans, including overdue days and loan statuses.
  - Extract overdue days for subsequent fine calculations.
  - Analyze loan trends and ensure timely returns. The view is designed to optimize storage space by calculating derived attributes (e.g., overdue days and loan statuses) dynamically rather than storing them in the database.
- **SQL Code**:
  ```sql
  CREATE VIEW LoanView AS  
  SELECT  
      L.LoanNumber AS LoanNumber,  
      L.MemberID AS MemberID,  
      M.Fname AS MemberFirstName,  
      M.Lname AS MemberLastName,  
      R.ResourceID AS ResourceID,  
      R.Title AS ResourceTitle,  
      L.IssueDate AS IssueDate,  
      L.ReturnDate AS ReturnDate,  
      L.CopyNumber AS CopyNumber,  
      R.LoanType AS LoanType,  
      CASE   
          WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
          WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
          WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
      END AS DueDate,  
      CASE   
          WHEN (L.ReturnDate IS NULL AND CURRENT_DATE >   
              (CASE   
                  WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
                  WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
                  WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
              END)) THEN EXTRACT(DAY FROM   
              (CASE   
                  WHEN L.ReturnDate IS NULL THEN CURRENT_DATE  
                  ELSE L.ReturnDate  
              END) -   
              (CASE   
                  WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
                  WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
                  WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
              END))  
          ELSE NULL  
      END AS OverdueDays,  
      CASE   
          WHEN L.ReturnDate IS NULL AND CURRENT_DATE >   
              (CASE   
                  WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
                  WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
                  WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
              END) THEN 'Overdue'  
          WHEN L.ReturnDate IS NULL AND CURRENT_DATE <=   
              (CASE   
                  WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
                  WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
                  WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
              END) THEN 'Not Returned (Due Soon)'  
          WHEN L.ReturnDate IS NOT NULL AND L.ReturnDate >   
              (CASE   
                  WHEN R.LoanType = 0 THEN L.IssueDate + INTERVAL '0' DAY  
                  WHEN R.LoanType = 2 THEN L.IssueDate + INTERVAL '2' DAY  
                  WHEN R.LoanType = 14 THEN L.IssueDate + INTERVAL '14' DAY  
              END) THEN 'Overdue'  
          ELSE 'Returned'  
      END AS LoanStatus 
  FROM LOAN L  
  JOIN MEMBER M ON L.MemberID = M.MemberID 
  JOIN RESOURCE_T R ON L.ResourceID = R.ResourceID;
- **Output**:
  ![Overdue Loans Output](./screenshots/popular-resources.png)
  
### 3. **Pending Reservations**
- **Purpose**: The Member Summary view provides both librarians and members with a detailed overview of member account details. It allows:
  - Librarians to analyze trends in overdue loans and payment history, which may inform decisions like extending loan periods or enforcing stricter policies.
  - Members to track their current account status, including overdue fines, total payments made, and the remaining amount due. This helps promote responsible use of library resources by making members aware of their financial obligations.
- **SQL Code**:
  ```sql
  CREATE VIEW MemberSummary AS   
  SELECT   
      M.MemberID,   
      M.Fname AS MemberFirstName,   
      M.Lname AS MemberLastName,   
      M.Email, 
      M.MemberType,   
      M.AccountStatus,   
      COUNT(CASE WHEN LV.ReturnDate IS NULL THEN 1 END) AS TotalLoan,  
      COALESCE(SUM(LV.Overduedays), 0) AS AmountDue,   
      COALESCE(SUM(DISTINCT P.PaymentAmount), 0) AS PaymentAmount, 
      COALESCE(SUM(LV.Overduedays), 0) - COALESCE(SUM(DISTINCT P.PaymentAmount), 0) AS RemainingDue 
  FROM MEMBER M   
  LEFT JOIN LoanView LV ON M.MemberID = LV.MemberID   
  LEFT JOIN PAYMENT P ON M.MemberID = P.MemberID   
  GROUP BY M.MemberID, M.Fname, M.Lname, M.Email, M.MemberType, M.AccountStatus;
- **Output**:
   ![Pending Reservations Output](./screenshots/popular-resources.png)

---
## Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/adinanabi/college-library-system.git
   cd college-library-system
2. **Set up the database**:
  - Run create-tables.sql to create the database schema.
  - Populate the database with sample data using insert-data.sql.
---
## Usage

After setting up the database, execute the following SQL scripts to utilize the system:
- **Execute SQL scripts**:
- `create-views.sql`: Creates tailored views for different user roles.
- `queries.sql`: Contains 12 pre-defined queries for common operations.
- `triggers.sql`: Automates resource availability updates.

You can run these scripts in your MySQL environment (e.g., MySQL Workbench) to interact with the database and retrieve useful information.

---
## Technologies Used
- Database: MySQL
- Languages: SQL
- Tools: MySQL Workbench, ER diagramming tool

---
## License
This project is for educational purposes and is licensed under the [MIT License](./LICENSE).
