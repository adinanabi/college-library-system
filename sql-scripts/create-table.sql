-- File: create-tables.sql
CREATE TABLE MEMBER_TYPE(
    MemberType VARCHAR(10) PRIMARY KEY,
    MaxLoans INT(2)
);

CREATE TABLE MEMBER (
    MemberID INT(8), 
    Fname VARCHAR(50) NOT NULL, 
    Lname VARCHAR(50) NOT NULL, 
    Email VARCHAR(255) UNIQUE, 
    MemberType VARCHAR(10) CHECK (MemberType IN ('student', 'staff')),
    AccountStatus VARCHAR(10) DEFAULT 'active',
    CONSTRAINT PK_MEMBER PRIMARY KEY (MemberID),
    FOREIGN KEY (MemberType) REFERENCES MEMBER_TYPE(MemberType)
);

CREATE TABLE CLASS (
    ClassNumber INT(4) PRIMARY KEY,
    ClassName VARCHAR(20)
);

CREATE TABLE RESOURCE_T (
    ResourceID INT(8) PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    FloorNumber INT(2) NOT NULL,
    ShelfNumber VARCHAR(6) NOT NULL,
    ISBN VARCHAR(50) UNIQUE,
    ClassNumber INT(4) NOT NULL,
    LoanType INT(2) NOT NULL, 
    RFormat VARCHAR(10) CHECK (RFormat IN ('book', 'dvd','cd','video')),
    FOREIGN KEY (ClassNumber) REFERENCES CLASS(ClassNumber)
);

CREATE TABLE BOOK_AUTHOR (
    ResourceID INT(8) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE CD_MUSICIAN (
    ResourceID INT(8) NOT NULL,
    Musician VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE DVD_DIRECTOR (
    ResourceID INT(8) NOT NULL,
    Director VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE VIDEO_CREATOR (
    ResourceID INT(8) NOT NULL,
    Creator VARCHAR(255) NOT NULL,
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE COPY (
    ResourceID INT(8) NOT NULL,
    CopyNumber INT(4) NOT NULL,
    Availability VARCHAR(20) DEFAULT 'available',
    CONSTRAINT PK_COPY PRIMARY KEY (ResourceID, CopyNumber),
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE LOAN (
    LoanNumber INT(8), 
    MemberID INT(8) NOT NULL,
    ResourceID INT(8) NOT NULL,
    CopyNumber INT(2) NOT NULL,
    IssueDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReturnDate TIMESTAMP,
    CONSTRAINT PK_LOAN PRIMARY KEY (MemberID, ResourceID, CopyNumber, LoanNumber),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),
    FOREIGN KEY (ResourceID, CopyNumber) REFERENCES COPY(ResourceID, CopyNumber)
);

CREATE TABLE RESERVATION (
    ReservationNumber INT(8),
    MemberID INT(8) NOT NULL,
    ResourceID INT(8) NOT NULL,
    ReservationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReservationStatus VARCHAR(50) DEFAULT 'pending',
    RemainingNotifications INT DEFAULT 3,
    CONSTRAINT PK_RESERVATION PRIMARY KEY (MemberID, ResourceID, ReservationNumber),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),
    FOREIGN KEY (ResourceID) REFERENCES RESOURCE_T(ResourceID)
);

CREATE TABLE NOTIFICATION ( 
    NotificationNumber INT(8),  
    MemberID INT(8) NOT NULL, 
    ResourceID INT(8) NOT NULL, 
    ReservationNumber INT(8) NOT NULL, 
    NotificationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT PK_NOTIFICATION PRIMARY KEY (MemberID, ReservationNumber, NotificationNumber),  
    FOREIGN KEY (MemberID, ResourceID, ReservationNumber) REFERENCES RESERVATION(MemberID, ResourceID, ReservationNumber) 
);

CREATE TABLE FINE (
    FineID INT(8),
    MemberID INT(8) NOT NULL,
    ResourceID INT(8) NOT NULL,
    CopyNumber INT(2) NOT NULL,
    LoanNumber INT(8) NOT NULL,
    CONSTRAINT PK_FINE PRIMARY KEY (MemberID, LoanNumber, FineID), 
    FOREIGN KEY (MemberID, ResourceID, CopyNumber, LoanNumber) REFERENCES LOAN(MemberID, ResourceID, CopyNumber, LoanNumber)
);

CREATE TABLE PAYMENT (
    MemberID INT(8) NOT NULL,
    PaymentID INT(8),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaymentAmount INT(4) NOT NULL,
    CONSTRAINT PK_PAYMENT PRIMARY KEY (MemberID, PaymentID),
    FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID)
);

