use bproject;

select * from books;
select * from branch;
select * from employee;
select * from issued_status;
select * from members;
select * from return_status;
-- CRUD OPERARTIONS 
-- TASKS
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
 
INSERT INTO BOOKS (isbn, book_title, category, rental_price, `status`, author, publisher)
VALUES ("978-2-60129-456-2", 'SHOCK NOC', 'Classic', 8.00, 'yes', 'GOLD ROGER', 'GG ROWLING');
 select * from books;
 
-- Task 2: Update an Existing Member's Address
update members
set member_address = '569 FULARE T'
WHERE member_id = 'C101';

select * From members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

select * from issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101' ;

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,COUNT(issued_id) FROM issued_status
GROUP BY 1
HAVING COUNT(issued_id) > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_counts
AS
SELECT b.isbn,b.book_title , COUNT(ist.issued_book_isbn) AS no_issued FROM BOOKS AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP  BY 1,2;
 
SELECT * FROM book_counts;

-- Task 7. Retrieve All Books in a Specific Category:

select * from books
where category = 'fantasy';

-- Task 8: Find Total Rental Income by Category:

select b.category, sum(rental_price), count(*) from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1;

-- 9 List Members Who Registered in the Last 180 Days:

INSERT INTO members(MEMBER_ID,MEMBER_NAME,MEMBER_ADDRESS,REG_DATE)
VALUES
(189,'GOSH','76 ST ST', '2025-08-26'),
(190,'JOSEPH','96 QT', '2025-06-15');

select * from members
where reg_date between '2024-01-1' and '2024-06-01';

select * from members
where reg_date >=  current_date - interval 180 day;

-- 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT E1.*,
E2.EMP_NAME AS MANAGER,
B.*,
B.MANAGER_ID 
 FROM 
EMPLOYEE AS E1
JOIN BRANCH AS B
ON B.BRANCH_ID = E1.BRANCH_ID
JOIN employee AS E2
ON B.MANAGER_ID = E2.EMP_ID;

-- 11 Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE EXPENSIVE 
SELECT * FROM BOOKS
WHERE RENTAL_PRICE>7.0;

SELECT * FROM expensive;

-- 12 Retrieve the List of Books Not Yet Returned
SELECT * FROM ISSUED_STATUS AS ISD
LEFT JOIN return_status AS RS
ON ISD.ISSUED_ID = RS.issued_id
WHERE RETURN_ID IS null;

-- Advanced SQL Operations
select * from books;
select * from branch;
select * from employee;
select * from issued_status;
select * from members;
select * from return_status;

use bproject;

/* 13: Identify Members with Overdue Books : Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue. */ 

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30

-- ist.issued_member_id, m.member_id, b.book_title from issued_status as ist

select 
ist.issued_id,
m.member_name,
b.book_title,
ist.issued_date,
current_Date - ist.issued_date
from issued_status as ist 
join members as m
on m.member_id = ist.issued_member_id
join books as b
on b.book_title  = ist.issued_book_name
left join return_status as r
on b.isbn = r.return_book_isbn
where 
r.return_date is null
and 
(current_date - ist.issued_date) > 30
order by 1
;

/* 14: Update Book Status on Return : Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).
*/

-- manual way of solving this task
select * from issued_status
where issued_book_isbn = '978-0-451-52993-5';

select * from books 
where isbn = '978-0-451-52993-5';

update books 
set status = 'no'
where isbn = '978-0-451-52993-5';

select * from return_status
where issued_id = 'IS122';

--
INSERT INTO return_status(return_id,issued_id,return_date)
VALUES
('RS189', 'IS122' , current_date);

select * from return_status
where issued_id = 'IS122';

update books 
set status = 'yes'
where isbn = '978-0-451-52993-5';

-- Store Procedures

DROP PROCEDURE IF EXISTS add_return_records;


DELIMITER //

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE);

    -- Fetch book info into variables
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1;

    -- Update book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Return a message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END;
//

DELIMITER ;



-- Testing the procedure add_return_records

-- Assign test values

SET @issued_id := 'IS135';
SET @isbn := '978-0-307-58837-1';

-- Check book details
SELECT * 
FROM books
WHERE isbn = @isbn;

-- Check issued book details
SELECT * 
FROM issued_status
WHERE issued_book_isbn = @isbn;

-- Check return details
SELECT * 
FROM return_status
WHERE issued_id = @issued_id;

-- Call the procedure with test data
CALL add_return_records('RS138', 'IS135');
CALL add_return_records('RS148', 'IS140');



/*15: Branch Performance Report : Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
-- books as bk
select * from books;
select * from branch;
select * from return_status;
select * from employee;

create table branch_report
as
select 
b.branch_id,
b.manager_id,
count(ist.issued_id) as no_of_books_issued,
count(r.issued_id) as no_of_books_returned,
sum(bk.rental_price) as total_revenue
from issued_status as ist
join employee as e
on e.emp_id = ist.issued_emp_id
join branch as b
on e.branch_id = b.branch_id 
left join return_status as r
on ist.issued_id = r.issued_id
join books as bk 
on ist.issued_book_isbn = bk.isbn 
group by 1,2;

drop table branch_report;

select * from branch_report;

/* 16: Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in 
the last 18 months.
*/
drop table active_members;


select * from active_members;
create table active_members
as
select * from members
where member_id in(
select distinct issued_member_id from issued_status
where issued_date >= current_date - interval 18 MONTH );

select * from active_members;


select * from issued_status;

/* 17: Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, 
and their branch.
*/
select 
e.emp_name,
b.*,
count(ist.issued_id) as number_of_books_issued 
from issued_status as ist
join employee as e
on e.emp_id = ist.issued_emp_id
join branch as b
on b.branch_id = e.branch_id
group by 1,2 
ORDER BY number_of_books_issued DESC
limit 3;

/* 18: Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member 
name, book title, and the number of times they've issued damaged books.
*/



/* 19: Stored Procedure Objective:

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance.

The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available,it should be issued, 
and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available. */
 
 select * from books;
 
 select * from issued_status;

DELIMITER //

CREATE PROCEDURE issued_book
(	
	IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)

BEGIN
	DECLARE 
	v_status VARCHAr(10);
--  ALL THE VARIBALE

-- ALL THE CODE
--  CHECKING IF THE BOOK IS AVAILABLE 'YES'
	SELECT status
	INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn
    LIMIT 1;

	IF v_status = 'yes' THEN
		INSERT INTO issued_status(
			issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id)
		VALUES(p_issued_id,
            p_issued_member_id,
            current_date(),
            p_issued_book_isbn,
            p_issued_emp_id
        );
	
    
 -- Update books table (set status to "no")
		UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Success message
        SELECT CONCAT('Book issued successfully! ISBN: ', p_issued_book_isbn) AS message;

	ELSEIF v_status = 'no' THEN
        -- Book unavailable
        SELECT CONCAT('Book is already issued! ISBN: ', p_issued_book_isbn) AS message;

	ELSE
        -- No matching ISBN
        SELECT CONCAT('Book not found in database. ISBN: ', p_issued_book_isbn) AS message;
	END IF;
END//

DELIMITER ;

--  Testing the procedure

-- Show current books
SELECT * FROM books;

-- Show issued_status before issuing
SELECT * FROM issued_status;

-- Case 1: Issue an available book (should succeed)
CALL issued_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

-- Case 2: Try issuing a book marked as unavailable (should show error message)
CALL issued_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

-- Case 3: Try issuing a book that doesn't exist (should show warning)
CALL issued_book('IS157', 'C108', '999-9-999-99999-9', 'E104');

-- Check updates in books table
SELECT * FROM books WHERE isbn IN ('978-0-553-29698-2', '978-0-375-41398-8');

-- Check issued records after issuing
SELECT * FROM issued_status;


/* 20: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50.
 The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines */
-- Drop old table if exists

DROP TABLE IF EXISTS overdue_summary;

-- Create new table with CTAS
CREATE TABLE overdue_summary AS
SELECT 
    ist.issued_member_id AS member_id,
    
    -- Count overdue books (not returned within 30 days)
    SUM(
        CASE 
            WHEN rs.return_id IS NULL 
                 AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
            THEN 1 ELSE 0 
        END
    ) AS overdue_books,
    
    -- Total fine = days overdue * $0.50
    SUM(
        CASE 
            WHEN rs.return_id IS NULL 
                 AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
            THEN (DATEDIFF(CURDATE(), ist.issued_date) - 30) * 0.50
            ELSE 0 
        END
    ) AS total_fine,
    
    -- Total books issued by each member
    COUNT(ist.issued_id) AS total_books_issued

FROM issued_status ist
LEFT JOIN return_status rs
       ON ist.issued_id = rs.issued_id
GROUP BY ist.issued_member_id;


