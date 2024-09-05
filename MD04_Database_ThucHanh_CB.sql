create database MD04_Database_ThucHanh_CB;
use MD04_Database_ThucHanh_CB;

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    book_title VARCHAR(100) NOT NULL,
    book_author VARCHAR(100) NOT NULL
);

CREATE TABLE Readers (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Phone VARCHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100),
    INDEX idx_name (Name)
);
CREATE TABLE BorrowingRecords (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_date DATE NOT NULL,
    return_date DATE,
    book_id INT NOT NULL,
    reader_id INT NOT NULL,
    FOREIGN KEY (book_id)
        REFERENCES Books (book_id),
    FOREIGN KEY (reader_id)
        REFERENCES Readers (Id)
);

INSERT INTO Books (book_title, book_author) VALUES
('To Kill a Mockingbird', 'Harper Lee'),
('1984', 'George Orwell'),
('The Great Gatsby', 'F. Scott Fitzgerald'),
('Pride and Prejudice', 'Jane Austen'),
('The Catcher in the Rye', 'J.D. Salinger');

INSERT INTO Readers (Name, Phone, email) VALUES
('Nguyễn Văn An', '0123456789', 'an.nguyen@gmail.com'),
('Lê Thị Bích', '0987654321', 'bich.le@gmail.com'),
('Trần Văn Cường', '0912345678', 'cuong.tran@yahoo.com'),
('Phạm Thị Dung', '0908765432', 'dung.pham@hotmail.com'),
('Nguyễn Văn Đông', '0999888777', 'dong.nguyen@outlook.com'),
('Đoàn Thị Phương', '0123987654', 'phuong.doan@gmail.com'),
('Vũ Văn Hoàng', '0912348765', 'hoang.vu@abc.com'),
('Hoàng Thị Hạnh', '0987654322', 'hanh.hoang@xyz.com'),
('Bùi Văn Khánh', '0123456788', 'khanh.bui@lmn.com'),
('Nguyễn Thị Lan', '0912345677', 'lan.nguyen@ghi.com'),
('Lê Văn Mạnh', '0908765431', 'manh.le@jkl.com'),
('Trần Thị Ngọc', '0999888766', 'ngoc.tran@def.com'),
('Phạm Văn Quang', '0123987653', 'quang.pham@pqr.com'),
('Nguyễn Thị Thu', '0912348764', 'thu.nguyen@stu.com'),
('Đoàn Văn Tùng', '0908765430', 'tung.doan@vwx.com');


INSERT INTO BorrowingRecords (borrow_date, return_date, book_id, reader_id) VALUES
('2024-09-01', '2024-09-10', 1, 1),  -- Nguyễn Văn An mượn sách To Kill a Mockingbird
('2024-09-03', NULL, 3, 2),          -- Lê Thị Bích mượn sách The Great Gatsby, chưa trả
('2024-09-05', '2024-09-12', 5, 3),  -- Trần Văn Cường mượn sách The Catcher in the Rye
('2024-09-06', '2024-09-13', 2, 4),  -- Phạm Thị Dung mượn sách 1984
('2024-09-07', '2024-09-14', 4, 5),  -- Nguyễn Văn Đông mượn sách Pride and Prejudice
('2024-09-08', NULL, 1, 6);          -- Đoàn Thị Phương mượn sách To Kill a Mockingbird, chưa trả


-- 1. Viết truy vấn SQL để lấy thông tin tất cả các giao dịch mượn sách, bao gồm tên sách, tên
-- độc giả, ngày mượn, và ngày trả 
select b.book_title as 'tên sách',
r.name as 'tên độc giả',
br.borrow_date as'Ngày mượn sách',
br.Return_date as'Ngày trả sách' 
 from BorrowingRecords  br
join books b on b.book_id = br.book_id
join readers r on r.id = br.reader_id;


-- Viết truy vấn SQL để tìm tất cả các sách mà độc giả bất kỳ đã mượn (ví dụ độc giả có tên
-- Nguyễn Văn A)

SELECT b.book_title AS "Tên Sách",
r.Name AS "Tên Độc Giả",
br.borrow_date AS "Ngày Mượn",
br.return_date AS "Ngày Trả"
FROM BorrowingRecords br
JOIN Books b ON br.book_id = b.book_id
JOIN Readers r ON br.reader_id = r.Id
WHERE r.Name = 'Nguyễn Văn An';

-- Đếm số lần một cuốn sách đã được mượn

select b.book_title,
count(br.book_id) as 'số sách đã mượn'
 from BorrowingRecords br
join Books b ON br.book_id = b.book_id
group by 
b.book_title;

-- Truy vấn tên của độc giả đã mượn nhiều sách nhất 
SELECT 
    r.Name AS "Tên Độc Giả",
    COUNT(br.book_id) AS "Số Lần Mượn"
FROM 
    BorrowingRecords br
JOIN 
    Readers r ON br.reader_id = r.Id
GROUP BY 
    r.Name
ORDER BY 
    COUNT(br.book_id) DESC
LIMIT 1;

-- Tạo một view tên là borrowed_books để hiển thị thông tin của tất cả các sách đã được
-- mượn, bao gồm tên sách, tên độc giả, và ngày mượn. Sử dụng các bảng Books, Readers, và
-- BorrowingRecord

create view borrowed_books as 
select b.book_title AS "Tên Sách",
    r.Name AS "Tên Độc Giả",
    br.borrow_date AS "Ngày Mượn" from BorrowingRecords br
join Books b on b.book_id = br.book_id
join readers r on r.id = br.reader_id;
 
-- Viết một thủ tục tên là get_books_borrowed_by_reader nhận một tham số là
-- reader_id . Thủ tục này sẽ trả về danh sách các sách mà độc giả đó đã mượn, bao gồm tên
-- sách và ngày mượn.

DELIMITER //

CREATE PROCEDURE get_books_borrowed_by_reader(IN reader_id INT)
BEGIN
    SELECT 
        b.book_title AS "Tên Sách",
        br.borrow_date AS "Ngày Mượn"
    FROM 
        BorrowingRecords br
    JOIN 
        Books b ON br.book_id = b.book_id
    WHERE 
        br.reader_id = reader_id;
END //

DELIMITER ;

-- Tạo một Trigger trong MySQL để tự động cập nhật ngày trả sách trong bảng
-- BorrowingRecords khi cuốn sách được trả. Cụ thể, khi một bản ghi trong bảng
-- BorrowingRecords được cập nhật với giá trị return_date , Trigger sẽ ghi lại ngày hiện tại
-- (ngày trả sách) nếu return_date chưa được điền trước đó



DELIMITER //

create trigger update_return_date
before update on BorrowingRecords 
for each row 
begin 
if new.return_date is null and old.return_date is not null THEN
set new.return_date = curdate();
end if;
end//
DELIMITER ;

























