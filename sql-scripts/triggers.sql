-- File: triggers.sql
DELIMITER //

CREATE TRIGGER LoanCreated
AFTER INSERT ON LOAN
FOR EACH ROW
BEGIN
    UPDATE COPY 
    SET Availability = 'unavailable' 
    WHERE ResourceID = NEW.ResourceID AND CopyNumber = NEW.CopyNumber;
END//

CREATE TRIGGER LoanReturned
BEFORE UPDATE ON LOAN
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NOT NULL THEN
        UPDATE COPY 
        SET Availability = 'available' 
        WHERE ResourceID = NEW.ResourceID AND CopyNumber = NEW.CopyNumber;
    END IF;
END//

DELIMITER ;