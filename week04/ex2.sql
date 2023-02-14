CREATE TABLE Specialization (
    name char(255) NOT NULL PRIMARY KEY
);
CREATE TABLE Student (
    id INT NOT NULL PRIMARY KEY,
    name char(255) NOT NULL,
    native_language char(255) NOT NULL
);
CREATE TABLE Course (
    name char(255) NOT NULL PRIMARY KEY,
    credits INT NOT NULL
);
CREATE TABLE StudentSpecialization (
    student_id INT NOT NULL,
    specialization_name char(255),
    PRIMARY KEY (student_id, specialization_name),
    FOREIGN KEY (student_id) REFERENCES Student(id),
    FOREIGN KEY (specialization_name) REFERENCES Specialization(name)
);
CREATE TABLE StudentCourse (
    student_id INT NOT NULL,
    course_name char(255) NOT NULL,
    PRIMARY KEY (student_id, course_name),
    FOREIGN KEY (student_id) REFERENCES Student(id),
    FOREIGN KEY (course_name) REFERENCES Course(name)
);

-- Random data
INSERT INTO Student (id, name, native_language) VALUES (1, 'Student', 'English');
INSERT INTO Student (id, name, native_language) VALUES (2, 'Sus', 'English');
INSERT INTO Student (id, name, native_language) VALUES (3, 'Whatislove', 'Russian');
INSERT INTO Student (id, name, native_language) VALUES (4, 'Robot', 'Binary code');
INSERT INTO Student (id, name, native_language) VALUES (5, 'User', 'None');
INSERT INTO Student (id, name, native_language) VALUES (6, 'tnedutS', 'Russian');
INSERT INTO Student (id, name, native_language) VALUES (7, 'DB course enjoyer', 'SQL');
INSERT INTO Student (id, name, native_language) VALUES (8, 'A', 'English');
INSERT INTO Student (id, name, native_language) VALUES (9, 'B', 'Russian');
INSERT INTO Student (id, name, native_language) VALUES (10, 'C', 'English');
INSERT INTO Student (id, name, native_language) VALUES (11, 'D', 'Tatarian');

INSERT INTO Specialization (name) VALUES ('Robotics');
INSERT INTO Specialization (name) VALUES ('Software Engineering');
INSERT INTO Specialization (name) VALUES ('Data Science');

INSERT INTO Course (name, credits) VALUES ('Physics', 10);
INSERT INTO Course (name, credits) VALUES ('Databases', 2);
INSERT INTO Course (name, credits) VALUES ('Statistics', 5);

INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (1, 'Software Engineering');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (7, 'Software Engineering');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (11, 'Software Engineering');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (3, 'Software Engineering');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (9, 'Software Engineering');

INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (4, 'Robotics');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (5, 'Robotics');

INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (2, 'Data Science');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (6, 'Data Science');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (8, 'Data Science');
INSERT INTO StudentSpecialization (student_id, specialization_name) VALUES (10, 'Data Science');

INSERT INTO StudentCourse (student_id, course_name)  VALUES (7, 'Databases');
INSERT INTO StudentCourse (student_id, course_name)  VALUES (11, 'Databases');
INSERT INTO StudentCourse (student_id, course_name)  VALUES (1, 'Databases');

INSERT INTO StudentCourse (student_id, course_name) VALUES (4, 'Physics');

INSERT INTO StudentCourse (student_id, course_name) VALUES (6, 'Statistics');

-- Queries
SELECT name FROM Student LIMIT 10;
SELECT name FROM Student
            WHERE native_language != 'Russian';
SELECT name FROM Student
    INNER JOIN StudentSpecialization SS on Student.id = SS.student_id
    WHERE specialization_name = 'Robotics';
SELECT Student.name, course_name FROM Student
    INNER JOIN StudentCourse SC on Student.id = SC.student_id
    INNER JOIN Course C2 on C2.name = SC.course_name
    WHERE credits < 3;

SELECT course_name FROM StudentCourse
    INNER JOIN Student S on S.id = StudentCourse.student_id
    WHERE S.native_language = 'English';