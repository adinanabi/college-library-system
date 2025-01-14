-- File: views.sql
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


SELECT * FROM PopularResources1;




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
            END))  
        OR (L.ReturnDate IS NOT NULL AND L.ReturnDate >   
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


SELECT * FROM LoanView;
   




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


SELECT * FROM MemberSummary;