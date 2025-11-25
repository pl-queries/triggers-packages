
## 🎓 Course Information

**Assignment:** - Scenarios about triggers & package in PLSQ - Group Work  
  
**Date:** 25-NOV-2025  
**Institution:** AUCA

**Instructor:** Maniraguha Eric

## 👥 Group Members

- **Student 1:** Ineza Agape           27464
- **Student 2:** Ntwari Ashimwe Fiacre 27438
- **Student 3:** Ndarasi Kaliza Chela  27800
- **STudent 4:** MICOMYIZA KANYAMIBWA GHISLAINE 27805

---

# triggers & PL/SQL package examples — repository overview

[![Oracle](https://img.shields.io/badge/Database-Oracle-red.svg)](https://www.oracle.com/)
[![PL/SQL](https://img.shields.io/badge/Language-PL%2FSQL-blue.svg)](https://docs.oracle.com/database/121/LNPLS/toc.htm)
--

This repository demonstrates practical Oracle SQL/PL/SQL examples (in `triggers.sql`) that implement access-control triggers, server error logging, and a small HR payroll package. The project is structured so you can run and examine the objects and the output using SQL*Plus, SQL Developer, or any Oracle client like us vscode using sql developer extension.

---

## Project structure 📁

A quick tree of the repository and what each file/folder contains:

```text
triggers-packages/ # repo root 
├─.gitgnore     #vscode config twazihishe
├─ README.md            # This file:   overview, how-to, screenshots descriptions
├─ triggers.sql         # All SQL/PLSQL objects: tables, triggers, package and sample calls
└─ Screenshots/         # Sample screenshots showing test runs & output
  ├─ partone/                           # Trigger-based screenshots (insert/update attempts, logs)
  │  ├─ triggerrunning.png
  │  ├─ triggerrunning_noerror.png
  │  ├─ table_data.png
  │  ├─ logs.png
  │  └─ notriggerdatacaptured.png
  ├─ partwo/           # Package & dynamic SQL screenshots (function calls, outputs)
  │  ├─ first_run.png
  │  ├─ second_run.png
  │  ├─ output.png
  │  └─ dynamic_calling.png
  └─ challenges/       # Environment / container & privilege debugging screenshots
    ├─ docker (2).png
    ├─ container_run.png
    └─ priviledge_issue.png
```

---

## What you'll find in `triggers.sql` 🔎

- Table definitions & sample data
  - `employees` — a small HR table with sample rows

`code`:  

```sql
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

```
  
- `students` — records of students used to demonstrate access control via triggers
- `access_logs` — a logging table that records suspicious or disallowed access attempts

`code`:

```sql
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

```

- Triggers
  - `auth_access` (BEFORE INSERT OR UPDATE OR DELETE ON students)
    - Purpose: enforce a database-level access policy — deny writes to the `students` table on weekends and outside allowed working hours.
    - Behavior: raises an application error with codes (-20001, -20002) when an operation would violate the policy.
  - `logging_trigger` (AFTER SERVERERROR ON DATABASE)
    - Purpose: capture server/database error events and save a record to `access_logs` for diagnostics or audit.
  
`code`

```sql
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
```

- PL/SQL package `hr_salary_pkg`
  - `calc_rssb_tax(p_salary)` — returns RSSB / payroll tax (sample: 3%)
  - `calc_net_salary(p_salary)` — returns net salary after RSSB deduction
  - `update_salary_dynamic(emp_id, new_salary)` — demonstrates dynamic SQL to update an employee's salary and prints both `USER` and `CURRENT_USER` to show owner vs invoker context

  ---

  ## Screenshots 📷

  **Part 1 (triggers):**

  - `POPULATING TABLE`
    ![alt](/Screenshots/partone/table_data.png)

  - `triggerrunning_noerror.png`
    ![alt](/Screenshots/partone/notriggerdatacaptured.png)

    Here, queries runs and no trigger is triggered since we are working in interval time that we should be working.

  - `notriggerdatacaptured.png`
    ![alt](/Screenshots/partone/notriggerdatacaptured.png)

  - `triggerrunning.png`
  ![alt](/Screenshots/partone/triggerrunning.png)
   Here, queries runs and  trigger is triggered since we are working in 22PM.

  - `logs.png`
  ![alt](/Screenshots/partone/logs.png)
  Here, we have table which stores and help us audit, inspect all denied access or people who to to enter in time which is prohibited.

   **Part 2 (package & dynamic SQL):**
  - `first_run.png`,
    ![alt](/Screenshots/partwo/first_run.png)
    here we run and function was applied
  - `second_run.png`,
    ![alt](/Screenshots/partwo/second_run.png)
    here we run and function was applied twice, data automated itself.
  - `output.png`  
    ![alt](/Screenshots/partwo/output.png)

    functions return expected calculations
  - `hr_salary_pkg`
    ![alt](/Screenshots/partwo/Screenshot%202025-11-22%20225034.png)

    source-code, with commented reasons about user vs current_user
  - `dynamic_calling.png`
    ![alt](/Screenshots/partwo/dynamic_calling.png)
   — illustrates the dynamic update being executed and output from DBMS_OUTPUT.

  Challenges / environment images:
  - `docker (2).png`,
  ![alt](/Screenshots/challenges/docker%20(2).png)
  Running gvenzl oracle image was not an easy task as we had to connect it to vscode as our working environment
   `container_run.png`
   ![alt](/Screenshots/challenges/container_run.png)
   — running inside containers;

   `priviledge_issue.png`
   ![alt](/Screenshots/challenges/priviledge_issue.png)
  Privilege issue encountered during testing. We had to `grant` permission to the user: ntwari as Admin to use triggers

---

## Why this file is useful 💡

- Access control is often enforced at the application level — `auth_access` shows how to add *database-level* rules to prevent changes at the source.
- `logging_trigger` demonstrates database-level error auditing so you can detect and store incidents automatically.
- `hr_salary_pkg` bundles payroll utilities into a single reusable package and shows dynamic SQL + output for learning about invoker/definer security context.

---

## run these in SQL*Plus / SQL Developer

-- View employees and sample data
SELECT * FROM employees;

-- Calculate RSSB & net salary
SELECT hr_salary_pkg.calc_rssb_tax(500000) AS tax FROM dual;
SELECT hr_salary_pkg.calc_net_salary(500000) AS net_salary FROM dual;

-- Dynamic update (updates employee id 101 to new salary)
BEGIN
  hr_salary_pkg.update_salary_dynamic(101, 700000);
END;

-- Try to insert into `students` outside allowed hours (will fail)
INSERT INTO students (student_id, first_name, last_name, marks) VALUES (99999, 'Try', 'Outside', 10);

<b style="color: lightblue; font-size: 26;">You can compare the actual screenshot images in `Screenshots/` after running the examples to verify expected behavior.</b>

---

## Notes & tips 🔧

- The `auth_access` trigger uses `TO_CHAR(SYSDATE, 'DY')` and hour extraction to enforce the window of allowed times (08:00–17:00) and blocks weekends.
- `logging_trigger` uses `SYS_CONTEXT('USERENV', 'SESSION_USER')` to capture the session user for the audit record.
- `hr_salary_pkg.update_salary_dynamic` prints both `USER` and the invoker (`CURRENT_USER`) to illustrate privileges and ownership when using dynamic SQL.

## Where to go from here

- Expand the `access_logs` table to application identifiers, or more detailed stack traces for improved auditing.
- Add tests that try insert/update during blocked times to verify the trigger behavior.
- Add grants or role tests to explore definer vs invoker rights in packages.

---

## Quick checklist (useful for assignments)

- [x] Create `employees`, `students` and `access_logs` tables
- [x] Create and test `auth_access` trigger (blocks weekends and non-office hours)
- [x] Create `logging_trigger` to insert into `access_logs` on server errors
- [x] Implement `hr_salary_pkg` (RSSB tax, net salary, dynamic update)
- [ ] (Optional) Add automated tests / CI for the SQL file

---

## In these exercises, I struggled mainly with understanding how triggers enforce time based restrictions and how logging unauthorized actions works. However, I learned how to create triggers that block operations outside allowed hours and how to record violations for auditing. I also gained confidence in using PL/SQL packages, functions, and dynamic procedures in real system scenarios.
