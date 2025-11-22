SET SERVEROUTPUT ON;

--TODO Table Employee
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name  VARCHAR2(100),
    last_name   VARCHAR2(100),
    salary      NUMBER(12,2)
);

--sample data
INSERT INTO employees (employee_id, first_name, last_name, salary)
VALUES (101, 'Agape', 'Ineza', 500000);

INSERT INTO employees (employee_id, first_name, last_name, salary)
VALUES (102, 'Alice', 'Mukamana', 350000);

INSERT INTO employees (employee_id, first_name, last_name, salary)
VALUES (103, 'Eric', 'Ndayishimiye', 275000);

INSERT INTO employees (employee_id, first_name, last_name, salary)
VALUES (104, 'Grace', 'Iradukunda', 800000);

COMMIT;

SELECT * from employees;

-- TODO: Table iraza storing students info
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    first_name VARCHAR(200) NOT NULL,
    last_name VARCHAR(200) NOT NULL,
    marks NUMBER NOT NULL
);

--TODO: Table iraza capture errors
CREATE TABLE access_logs (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username      VARCHAR2(200),
    attempt_time  DATE,
    action_type   VARCHAR2(100),
    description   VARCHAR2(200)
);

-- TODO:sample data zidufasha ko visualizinga the trigger easier
INSERT INTO students VALUES (27438,'Fiacre','Ntwari', 27);
INSERT INTO students VALUES (27800,'Chela','Kaliza', 30);
INSERT INTO students VALUES (27464,'Agape', 'Ineza', 28);
INSERT INTO students VALUES (27805,'Ghislaine','KANYAMIBWA', 29);

-- Trigger to log unauthorized access attempts
CREATE OR REPLACE TRIGGER auth_access
BEFORE INSERT OR UPDATE OR DELETE ON students
DECLARE
    v_day   VARCHAR2(10);
    v_hour  NUMBER;
BEGIN
    v_day  := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));

    -- Weekends block
    IF v_day IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Access denied: Weekend restriction.');
    END IF;

    -- Time restriction
    IF v_hour < 8 OR v_hour >= 17 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Access denied: Allowed time is 08:00–17:00.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER logging_trigger
AFTER SERVERERROR
ON DATABASE
DECLARE
BEGIN
    INSERT INTO access_logs(username, attempt_time, action_type, description)
    VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYSDATE,
        'DATA ACCESS ATTEMPT',
        'Violation of AUCA access policy detected.'
    );
END;
/


-- TODO: part 2


CREATE OR REPLACE PACKAGE hr_salary_pkg AS

    -- Function to calculate RSSB based on 3% tax
    FUNCTION calc_rssb_tax(p_salary NUMBER) RETURN NUMBER;

    -- Function to calculate NET salary
    FUNCTION calc_net_salary(p_salary NUMBER) RETURN NUMBER;

    -- Dynamic procedure (updates employee salary)
    PROCEDURE update_salary_dynamic(emp_id NUMBER, new_salary NUMBER);

END hr_salary_pkg;
/


CREATE OR REPLACE PACKAGE BODY hr_salary_pkg AS

    --------------------------------------------------------------------
    -- USER vs CURRENT_USER
    -- USER = schema executing the code (owner of objects)
    -- CURRENT_USER = user invoking the PL/SQL (Invoker rights)
    -- Useful in applications where privileges differ.
    --------------------------------------------------------------------

    FUNCTION calc_rssb_tax(p_salary NUMBER)
    RETURN NUMBER IS
    BEGIN
        RETURN p_salary * 0.03; -- 3% RSSB
    END;

    FUNCTION calc_net_salary(p_salary NUMBER)
    RETURN NUMBER IS
    BEGIN
        RETURN p_salary - calc_rssb_tax(p_salary);
    END;

    -- Dynamic SQL salary update
    PROCEDURE update_salary_dynamic(emp_id NUMBER, new_salary NUMBER) IS
        sql_stmt  VARCHAR2(200);
    BEGIN
        sql_stmt := 'UPDATE employees SET salary = :1 WHERE employee_id = :2';

        EXECUTE IMMEDIATE sql_stmt USING new_salary, emp_id;

        DBMS_OUTPUT.PUT_LINE('Updated by user: ' || USER);
        DBMS_OUTPUT.PUT_LINE('Invoker (CURRENT_USER): ' || SYS_CONTEXT('USERENV','CURRENT_USER'));
    END;

END hr_salary_pkg;
/


--Sample Calls
-- TODO:Calculate RSSB tax:
SELECT hr_salary_pkg.calc_rssb_tax(500000) AS tax FROM dual;

--Calculate net salary:
SELECT hr_salary_pkg.calc_net_salary(500000) AS net_salary FROM dual;

-- TODO:Execute dynamic salary update:
BEGIN
    hr_salary_pkg.update_salary_dynamic(101, 700000);
END;
/
