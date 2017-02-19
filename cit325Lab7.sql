/*Create and Fix Up the Store*/
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

SPOOL cit325Lab7.txt

UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER := 2;
 
  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;
 
  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);
 
BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
 
    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;

BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;


/*
    [10 points] Create an insert_contact procedure that writes an all or nothing procedure. The procedure inserts into the member, contact, address, and telephone tables, which means you use transaction control language (TCL). TCL principles require you put the database in a transactional state, which applies to any Oracle session/connection by default. A TCL lets you commit after a successful insert into all tables, but TCL requires that you roll back all SQL DML statements with only a single failure. The roll back should limit its scope to the current procedure, which means it rolls back only to the local save point. Failures should only occur when an insert into any one of the four tables fails.
*/


DECLARE

	PV_FIRST_NAME VARCHAR(20) := 'Charles';
	PV_MIDDLE_NAME VARCHAR(20) := 'Francis';
	PV_LAST_NAME VARCHAR(20) := 'Xavier';
	PV_CONTACT_TYPE VARCHAR(20) := 'CUSTOMER';
	PV_ACCOUNT_NUMBER VARCHAR(20) := 'SLC-000008';
	PV_MEMBER_TYPE VARCHAR(20) := 'INDIVIDUAL';
	PV_CREDIT_CARD_NUMBER VARCHAR(20) := '7777-6666-5555-4444';
	PV_CREDIT_CARD_TYPE VARCHAR(20) := 'DISCOVER_CARD';
	PV_CITY VARCHAR(20) := 'Milbridge';
	PV_STATE_PROVINCE VARCHAR(20) := 'Maine';
	PV_POSTAL_CODE VARCHAR(20) := '4658';
	PV_ADDRESS_TYPE VARCHAR(20) := 'HOME';
	PV_COUNTRY_CODE VARCHAR(1) := '1';
	PV_AREA_CODE VARCHAR(3) := '207';
	PV_TELEPHONE_NUMBER VARCHAR(8) := '111-1234';
	PV_TELEPHONE_TYPE VARCHAR(10) := 'HOME;'
	PV_USER_NAME VARCHAR(20) := 'DBA 2';


--member, contact, address, and telephone
BEGIN
	SAVEPOINT savepoint1;

	--MEMBER_ID MEMBER_TYPE ACCOUNT_NU CREDIT_CARD_NUMBER  CREDIT_CARD_TYPE CREATED_BY CREATION_DATE  LAST_UPDATED_BY LAST_UPDATE_DATE
	INSERT INTO member VALUES
	(member_s1.nextval
	, (SELECT common_lookup_type FROM Common_lookup WHERE common_lookup_type = PV_CONTACT_TYPE)
	, PV_ACCOUNT_NUMBER
	, PV_CREDIT_CARD_NUMBER
	, (SELECT common_lookup_type FROM Common_lookup WHERE common_lookup_type = PV_CREDIT_CARD_TYPE)
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE);

	--CONTACT_ID  MEMBER_ID CONTACT_TYPE FIRST_NAME		MIDDLE_NAME	     LAST_NAME		  CREATED_BY CREATION_DATE	LAST_UPDATED_BY LAST_UPDATE_DATE

	INSERT INTO contact VALUES
	(contact_s1.nextval
	, (SELECT member_id FROM member WHERE account_number = PV_ACCOUNT_NUMBER)
	, (SELECT common_lookup_ID FROM common_lookup WHERE common_lookup_type = PV_MEMBER_TYPE)
	, PV_FIRST_NAME 
	, PV_MIDDLE_NAME 
	, PV_LAST_NAME 
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE);

	--ADDRESS_ID CONTACT_ID ADDRESS_TYPE CITY 			  STATE_PROVINCE		 POSTAL_CODE	      CREATED_BY CREATION_DATE	    LAST_UPDATED_BY LAST_UPDATE_DATE

	INSERT INTO address VALUES
	(address_s1.nextval
	, (SELECT contact_id FROM contact WHERE member_id = (SELECT member_id FROM member WHERE account_number = PV_ACCOUNT_NUMBER))
	, (SELECT common_lookup_ID FROM common_lookup WHERE common_lookup_type = PV_ADDRESS_TYPE)
	, PV_CITY 
	, PV_STATE_PROVINCE 
	, PV_POSTAL_CODE 
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE);

	--TELEPHONE_ID CONTACT_ID ADDRESS_ID TELEPHONE_TYPE COU AREA_C TELEPHONE_ CREATED_BY CREATION_DATE      LAST_UPDATED_BY LAST_UPDATE_DATE

	INSERT INTO telephone VALUES
	(telephone_s1.nextval
	, (SELECT contact_id FROM contact WHERE member_id = (SELECT member_id FROM member WHERE account_number = PV_ACCOUNT_NUMBER))
	, (SELECT common_lookup_ID FROM common_lookup WHERE common_lookup_type = PV_TELEPHONE_TYPE)
	, PV_COUNTRY_CODE 
	, PV_AREA_CODE 
	, PV_TELEPHONE_NUMBER 
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE
	, (SELECT system_user_id FROM system_user WHERE SYSTEM_USER_NAME = PV_USER_NAME)
	, SYSDATE);


EXCEPTION
	WHEN OTHERS THEN Rollback TO savepoint1;

/*
[5 points] Modify the insert_contact definer rights procedure into an autonomous insert_contact invoker rights procedure. You need to add a precompiled instruction, or PRAGMA, to your procedure to make it an autonomous transaction (refer to page 374 in the Oracle Database 12c PL/SQL Programming textbook for an autonomous transaction precompiled instruction example). The change between a definer rights to invoker rights program will have no impact on running the procedure because you’re working in a single database schema. Like the prior insert_contact procedure, this procedure requires you to use transaction control language (TCL).
*/

--What does definer/invoker rights have to do with anything here? This is the same operation again with different data? 

/*

    [5 points] Modify the insert_contact invoker rights procedure into an autonomous insert_contact definer rights function that returns a number. The insert_contact function should return a zero when successful and a 1 when unsuccessful. The change between a procedure and a function means you now return a value from calling the function.
*/

/*
    [5 points] This step requires that you create a get_contact object table function, which requires a contact_obj SQL object type and a contact_tab SQL collection type (page 318). After you define the SQL object type and collection type, you can create the get_contact object table function (like the get_full_titles example on pages 318-319). 
*/

SPOOL OFF
