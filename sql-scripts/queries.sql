-- File: queries.sql
SELECT DISTINCT
    M.MemberID,
    M.Fname,
    M.Lname,
    LV.LoanNumber,
    LV.IssueDate,
    LV.ReturnDate,
    R.Title AS ResourceTitle
FROM
    MEMBER M
JOIN
    LOANVIEW LV ON M.MemberID = LV.MemberID
JOIN
    RESOURCE_T R ON LV.ResourceID = R.ResourceID
WHERE
    LV.ReturnDate IS NULL AND NOW() > LV.DueDate;



SELECT M.MemberID, M.Fname, M.Lname, COUNT(L.LoanNumber) AS NumOfLoans
FROM MEMBER M
JOIN LOAN L ON M.MemberID = L.MemberID
WHERE YEAR(L.IssueDate) = 2023
GROUP BY M.MemberID, M.Fname, M.Lname
ORDER BY NumOfLoans DESC
LIMIT 5;






SELECT
    RT.Title AS Resource_Title,
    RT.FloorNumber,
    RT.ShelfNumber,
    BA.Author AS AuthorName,
    COUNT(C.Availability) AS Available_Copies
FROM
    RESOURCE_T RT
JOIN
    COPY C ON RT.ResourceID = C.ResourceID
LEFT JOIN
    BOOK_AUTHOR BA ON RT.ResourceID = BA.ResourceID
WHERE
    RT.Title = 'Engineering Mathematics'
    AND C.Availability = 'available'
GROUP BY
    RT.Title, RT.FloorNumber, RT.ShelfNumber, BA.Author;






SELECT 
    R.ResourceID, 
    R.Title,
    CD.Musician,
    R.RFormat, 
    R.ClassNumber
FROM 
    RESOURCE_T R
JOIN 
    CLASS C ON R.ClassNumber = C.ClassNumber
JOIN 
    CD_MUSICIAN CD ON R.ResourceID = CD.ResourceID
WHERE 
    C.ClassName = 'Music' AND R.RFormat = 'cd';






SELECT
    ResourceID,
    Title,
    LoanType,
    ROUND(AVG(NumOfBorrowings), 2) AS NumOfBorrowings,
    ROUND(AVG(NumOfBorrowings / (DATE(STR_TO_DATE('2023-11-28', '%Y-%m-%d')) - DATE(STR_TO_DATE('2023-11-10', '%Y-%m-%d')) + 1)), 2) AS AvgNumOfBorrowingsPerDay
FROM (
    SELECT
        R.ResourceID,
        R.Title,
        R.LoanType,
        COUNT(L.LoanNumber) AS NumOfBorrowings
    FROM
        RESOURCE_T R
    LEFT JOIN
        LOAN L ON R.ResourceID = L.ResourceID
    WHERE
        L.IssueDate BETWEEN STR_TO_DATE('2023-11-10', '%Y-%m-%d') AND STR_TO_DATE('2023-11-28', '%Y-%m-%d')
    GROUP BY
        R.ResourceID, R.Title, R.LoanType
) subquery
GROUP BY
    ResourceID, Title, LoanType
ORDER BY
    AvgNumOfBorrowingsPerDay DESC
LIMIT 10;




SELECT
    R.ResourceID,
    R.Title,
    COUNT(C.CopyNumber) AS TotalCopies,
    SUM(CASE WHEN C.Availability = 'available' THEN 1 ELSE 0 END) AS AvailableCopies
FROM
    RESOURCE_T R
LEFT JOIN
    COPY C ON R.ResourceID = C.ResourceID
GROUP BY
    R.ResourceID, R.Title
HAVING
    SUM(CASE WHEN C.Availability = 'available' THEN 1 ELSE 0 END) = 0;




SELECT R.ReservationNumber, R.ReservationDate, R.ResourceID, RT.Title 
FROM RESERVATION R 
JOIN RESOURCE_T RT ON R.ResourceID = RT.ResourceID 
WHERE NOW() > R.ReservationDate;





SELECT
    R.ReservationNumber,
    R.ResourceID,
    RT.Title AS ResourceTitle,
    R.ReservationDate,
    CONCAT(M.Fname, ' ', M.Lname) AS MemberName,
    N.NotificationDate,
    CASE
        WHEN CURDATE() < DATE_ADD(N.NotificationDate, INTERVAL 2 DAY) THEN 'pending'
        ELSE 'expired'
    END AS NotificationStatus
FROM
    RESERVATION R
JOIN
    MEMBER M ON R.MemberID = M.MemberID
JOIN
    RESOURCE_T RT ON R.ResourceID = RT.ResourceID
LEFT JOIN
    NOTIFICATION N ON R.ReservationNumber = N.ReservationNumber
WHERE
    R.MemberID = 20159029;






SELECT
    M.Fname || ' ' || M.Lname AS MemberName,
    L.LoanNumber,
    R.Title AS ResourceTitle,
    L.IssueDate,
    L.ReturnDate,
    CASE
        WHEN L.ReturnDate IS NULL THEN 'On Loan'
        WHEN L.ReturnDate > L.IssueDate + RT.LoanType + 1 THEN 'Returned late'
        ELSE 'Returned on time'
    END AS LoanStatus,
    CASE
        WHEN L.ReturnDate IS NULL AND L.IssueDate + RT.LoanType > CURRENT_TIMESTAMP THEN L.IssueDate + RT.LoanType
        ELSE NULL
    END AS DueDate
FROM
    LOAN L
JOIN
    MEMBER M ON L.MemberID = M.MemberID
JOIN
    RESOURCE_T R ON L.ResourceID = R.ResourceID
JOIN
    RESOURCE_T RT ON R.ResourceID = RT.ResourceID
WHERE
    M.MemberID = 20159030;






SELECT
    F.FineID,
    F.MemberID,
    F.ResourceID,
    F.CopyNumber,
    F.LoanNumber,
    LV.IssueDate AS LoanIssueDate,
    LV.ReturnDate AS LoanReturnDate,
    CASE
        WHEN LV.ReturnDate IS NOT NULL THEN EXTRACT(DAY FROM LV.ReturnDate - LV.DueDate)
        ELSE EXTRACT(DAY FROM CURRENT_DATE - LV.DueDate)
    END AS FineAmount
FROM
    FINE F
JOIN
    LoanView LV ON F.MemberID = LV.MemberID
WHERE
    F.MemberID = 20159042;






SELECT
    M.MemberID,
    M.Fname AS MemberFirstName,
    M.Lname AS MemberLastName,
    M.Email,
    M.MemberType,
    M.AccountStatus,
    COUNT(CASE WHEN LV.ReturnDate IS NULL THEN 1 END) AS TotalLoan,
    COALESCE(SUM(LV.Overduedays), 0) - COALESCE(P.PaymentAmount, 0) AS AmountDue
FROM MEMBER M
LEFT JOIN LoanView LV ON M.MemberID = LV.MemberID
LEFT JOIN (
    SELECT MemberID, SUM(PaymentAmount) AS PaymentAmount
    FROM PAYMENT
    GROUP BY MemberID
) P ON M.MemberID = P.MemberID
WHERE M.AccountStatus = 'suspended'
GROUP BY M.MemberID, M.Fname, M.Lname, M.Email, M.MemberType, M.AccountStatus, P.PaymentAmount;






SELECT
    R.ReservationNumber,
    R.MemberID,
    M.Fname AS MemberFirstName,
    M.Lname AS MemberLastName,
    R.ResourceID,
    RT.Title AS ResourceTitle,
    R.ReservationDate,
    R.ReservationStatus,
    (
        SELECT COUNT(*)
        FROM NOTIFICATION N
        WHERE N.MemberID = R.MemberID
            AND N.ResourceID = R.ResourceID
            AND N.ReservationNumber = R.ReservationNumber
    ) AS RemainingNotifications
FROM
    RESERVATION R
JOIN
    MEMBER M ON R.MemberID = M.MemberID
JOIN
    RESOURCE_T RT ON R.ResourceID = RT.ResourceID
WHERE RT.Title = 'Principles of marketing engineering and analytics';