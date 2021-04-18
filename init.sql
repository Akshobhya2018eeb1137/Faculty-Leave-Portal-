CREATE TABLE Faculty(
  faculty_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(30) UNIQUE,
  name VARCHAR(30),
  designation VARCHAR(10),
  department VARCHAR(10),
  total_leaves INT,
  avail_leaves INT,
  borwd_leaves INT DEFAULT 0,
  leave_rqst BOOLEAN DEFAULT FALSE
);

CREATE TABLE Leaves(
  request_id INT PRIMARY KEY AUTO_INCREMENT,
  faculty_id INT,
  duration INT,
  start_date DATE,
  status VARCHAR(10),
  faculty_comment TINYTEXT,    
  authority_comment TINYTEXT,
  approval_awaited VARCHAR(10),
  sender_dept VARCHAR(10),
  lvl INT,   
  borwd_days INT DEFAULT 0,
  FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)
);

CREATE TABLE Log(
  entry_id INT PRIMARY KEY AUTO_INCREMENT,
  timestamp TIMESTAMP,
  request_id INT,
  record TINYTEXT,
  designation VARCHAR(10),
  name VARCHAR(30),
  FOREIGN KEY (request_id) REFERENCES Leaves(request_id)
);

CREATE TABLE LeaveRoute(
  lvl INT,
  send_from VARCHAR(10),
  send_to VARCHAR(10)
);

INSERT INTO LeaveRoute VALUES(1,'Director','Director');
INSERT INTO LeaveRoute VALUES(2,'Director','Director');
INSERT INTO LeaveRoute VALUES(1,'DFA','Director');
-- INSERT INTO LeaveRoute VALUES(1,'ADFA','Director');
INSERT INTO LeaveRoute VALUES(1,'HoD','Director');
INSERT INTO LeaveRoute VALUES(1,'Faculty','HoD');
INSERT INTO LeaveRoute VALUES(2,'HoD','DFA');
INSERT INTO LeaveRoute VALUES(3,'DFA','DFA');

DELIMITER $$
CREATE Trigger updateLog
AFTER INSERT ON Leaves
FOR EACH ROW
BEGIN
  DECLARE timestamp TIMESTAMP;
  DECLARE name_ VARCHAR(30);
  DECLARE designation_ VARCHAR(10); 

  SELECT CURRENT_TIMESTAMP into timestamp;
  SELECT name, designation INTO name_, designation_ FROM Faculty WHERE faculty_id = NEW.faculty_id;

  INSERT INTO Log(timestamp, request_id, record, designation, name) VALUES(timestamp, NEW.request_id,"new leave request",designation_,name_);
  IF NEW.borwd_days <> 0 THEN
    INSERT INTO Log(timestamp, request_id, record, designation, name) VALUES(timestamp, NEW.request_id,"leave borrow request",designation_,name_);
  END IF;
END; $$
