-- File: create-tables.sql
CREATE TABLE MEMBER_TYPE(
    MemberType VARCHAR(10) PRIMARY KEY,
    MaxLoans INT
);

CREATE TABLE MEMBER (
    MemberID INT, 
    Fname VARCHAR(50) NOT NULL, 
    Lname VARCHAR(50) NOT NULL, 
    Email VARCHAR(100) UNIQUE, 
    MemberType VARCHAR(10) CHECK (MemberType IN ('student', 'staff')),
    AccountStatus VARCHAR(10) DEFAULT 'active',
    CONSTRAINT PK_MEMBER PRIMARY KEY (MemberID),
    FOREIGN KEY (MemberType) REFERENCES MEMBER_TYPE(MemberType)
);

CREATE TABLE CLASS (
    ClassNumber INT PRIMARY KEY,
    ClassName VARCHAR(20)
);

CREATE TABLE RESOURCE_T (
    ResourceID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    FloorNumber INT NOT NULL,
    ShelfNumber VARCHAR(6) NOT NULL,
    ISBN VARCHAR(50) UNIQUE,
    ClassNumber INT NOT NULL,
    LoanType INT NOT NULL, 
    RFormat ENUM('book', 'dvd', 'cd', 'video') NOT NULL,
    FOREIGN KEY (ClassNumber) REFERENCES CLASS(ClassNumber)
);

CREATE TABLE BOOK_AUTHOR (
    ResourceID INT NOT NULL,
    Author VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE CD_MUSICIAN (
    ResourceID INT NOT NULL,
    Musician VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE DVD_DIRECTOR (
    ResourceID INT NOT NULL,
    Director VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE VIDEO_CREATOR (
    ResourceID INT NOT NULL,
    Creator VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE COPY (
    ResourceID INT NOT NULL,
    CopyNumber INT NOT NULL,
    Availability VARCHAR(20) DEFAULT 'available',
    CONSTRAINT PK_COPY PRIMARY KEY (ResourceID, CopyNumber),
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE LOAN (
    LoanNumber INT, 
    MemberID INT NOT NULL,
    ResourceID INT NOT NULL,
    CopyNumber INT NOT NULL,
    IssueDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReturnDate TIMESTAMP,
    CONSTRAINT PK_LOAN PRIMARY KEY (MemberID, ResourceID, CopyNumber, LoanNumber),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),
    FOREIGN KEY (ResourceID, CopyNumber) REFERENCES COPY(ResourceID, CopyNumber)
);

CREATE TABLE RESERVATION (
    ReservationNumber INT,
    MemberID INT NOT NULL,
    ResourceID INT NOT NULL,
    ReservationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReservationStatus VARCHAR(50) DEFAULT 'pending',
    RemainingNotifications INT DEFAULT 3,
    CONSTRAINT PK_RESERVATION PRIMARY KEY (MemberID, ResourceID, ReservationNumber),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE NOTIFICATION ( 
    NotificationNumber INT,  
    MemberID INT NOT NULL, 
    ResourceID INT NOT NULL, 
    ReservationNumber INT NOT NULL, 
    NotificationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT PK_NOTIFICATION PRIMARY KEY (MemberID, ReservationNumber, NotificationNumber),  
    FOREIGN KEY (MemberID, ResourceID, ReservationNumber) REFERENCES RESERVATION(MemberID, ResourceID, ReservationNumber) 
);

CREATE TABLE FINE (
    FineID INT,
    MemberID INT NOT NULL,
    ResourceID INT NOT NULL,
    CopyNumber INT NOT NULL,
    LoanNumber INT NOT NULL,
    CONSTRAINT PK_FINE PRIMARY KEY (MemberID, LoanNumber, FineID), 
    FOREIGN KEY (MemberID, ResourceID, CopyNumber, LoanNumber) REFERENCES LOAN(MemberID, ResourceID, CopyNumber, LoanNumber)
);

CREATE TABLE PAYMENT (
    MemberID INT NOT NULL,
    PaymentID INT,
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaymentAmount INT NOT NULL,
    CONSTRAINT PK_PAYMENT PRIMARY KEY (MemberID, PaymentID),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID)
);