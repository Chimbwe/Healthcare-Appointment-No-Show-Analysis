/* =======================================
   HEALTHCARE APPOINTMENT NO-SHOW ANALYSIS
=========================================*/

/* Create and select database */

CREATE DATABASE IF NOT EXISTS healthcare_appointment_analysis;
USE healthcare_appointment_analysis;

/* ALTER TABLE appointments
	MODIFY appointment_registration_date DATE,
    MODIFY appointment_date DATE; */
    
/* ======================================
   DATA VALIDATION
======================================= */

/* Review table structure */

DESCRIBE appointments;

/* Preview records */

SELECT *
FROM appointments
LIMIT 10;

/* Record count */

SELECT
	COUNT(*) AS total_records
FROM appointments;

/* Check data range */

SELECT
	MIN(appointment_date) AS first_appointment,
	MAX(appointment_date) AS last_appointment
FROM appointments;

/* Check waiting days */

SELECT
	MIN(waiting_days) AS min_wait,
	MAX(waiting_days) AS max_wait,
	ROUND(AVG(waiting_days), 2) AS avg_wait
FROM appointments;

/* Check age */

SELECT
	MIN(age) AS min_age,
	MAX(age) AS max_age,
	ROUND(AVG(age), 2) AS avg_age
FROM appointments;

/* Verify appointment status values */

SELECT
	appointment_status,
    COUNT(*) AS appointments
FROM appointments
GROUP BY appointment_status;

/* Verify weekdays */

SELECT 
	day_of_week,
    COUNT(*) AS appointments
FROM appointments
GROUP BY day_of_week
ORDER BY FIELD(
	day_of_week,
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
    );
    
/* Verify SMS reminder values */

SELECT 
	sms_reminder,
    COUNT(*) AS appointments
FROM appointments
GROUP BY sms_reminder
ORDER BY sms_reminder;

/* ======================================
   EXECUTIVE KPIs
======================================= */

SELECT 
	COUNT(*) AS total_appointments,
    ROUND(AVG(age), 2) AS avg_age,
    ROUND(AVG(waiting_days), 2) AS avg_waiting_days,
	SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
    SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
    ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments;

/* ======================================
   WAITING TIME ANALYSIS
======================================= */

/* Does a longer waiting period correspond to a higher no-show rate? */
/* Which waiting time category has the highest no-show rate? */

SELECT
	CASE
		WHEN waiting_days <= 7 THEN 'within 1 week'
        WHEN waiting_days BETWEEN 8 AND 14 THEN '1-2 weeks'
        WHEN waiting_days BETWEEN 15 AND 30 THEN '2-4 weeks'
        WHEN waiting_days BETWEEN 31 AND 60 THEN '1-2 months'
        WHEN waiting_days BETWEEN 61 AND 90 THEN '2-3 months'
        ELSE 'over 3 months'
	END AS waiting_period,
    COUNT(*) AS total_appointments,
    ROUND(AVG(waiting_days), 2) AS avg_waiting_days,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
    SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
    ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY waiting_period
ORDER BY
	CASE waiting_period
		WHEN 'within 1 week' THEN 1
        WHEN '1-2 weeks' THEN 2
        WHEN '2-4 weeks' THEN 3
        WHEN '1-2 months' THEN 4
        WHEN '2-3 months' THEN 5
        WHEN 'over 3 months' THEN 6
    END;

/* What is the average waiting time for attended vs. missed appointments? */

SELECT
	appointment_status,
    COUNT(*) AS total_appointments,
    ROUND(AVG(waiting_days), 2) AS avg_waiting_days
FROM appointments
GROUP BY appointment_status;

/* ======================================
   APPOINTMENT TRENDS
======================================= */

/* Which weekday has the highest no-show rate? */
/* Which weekday has the highest appointment volume? */
/* Which weekday has the highest attendance rate? */

SELECT 
	day_of_week,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
    ROUND(
		SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS attendance_rate_pct,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY day_of_week
ORDER BY 
	CASE day_of_week
		WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
	END;

/* ======================================
   PATIENT DEMOGRAPHICS
======================================= */

/* Which age groups have the highest no-show rate? */

SELECT 
	CASE 
		WHEN age <= 17 THEN 'pediatric (0-17)'
        WHEN age BETWEEN 18 AND 34 THEN 'young adult (18-34)'
        WHEN age BETWEEN 35 AND 49 THEN 'adult (35-49)'
        WHEN age BETWEEN 50 AND 64 THEN 'middle age (50-64)'
        ELSE 'senior (65+)'
	END AS age_group,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY age_group
ORDER BY 
	CASE age_group
		WHEN 'pediatric (0-17)' THEN 1
        WHEN 'young adult (18-34)' THEN 2
        WHEN 'adult (35-49)' THEN 3
        WHEN 'middle age (50-64)' THEN 4
        WHEN 'senior (65+)' THEN 5
	END;

/* Does attendance differ by gender? */

SELECT 
	gender,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY gender;
    
/* ======================================
   CLINICAL FACTORS
======================================= */

/* How do no-show rates vary by the number of reported health factors? */

SELECT 
	CASE 
		WHEN (diabetes + alcoholism + hypertension + handicap + smoker + tuberculosis) = 0 
        THEN 'no reported health factors'
		WHEN (diabetes + alcoholism + hypertension + handicap + smoker + tuberculosis) = 1
		THEN 'one health factor'
        ELSE 'multiple health factors'
	END AS health_factor_group,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY health_factor_group;

/* Do patients with hypertension have different no-show rates*/

SELECT
	CASE 
		WHEN hypertension = 1 THEN 'hypertension present'
        ELSE 'hypertension not present'
	END AS hypertension_status,
    COUNT(*) AS total_appointments,
    ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY hypertension_status;

/* Does scholarship status relate to no-show rates? */

SELECT 
	scholarship,
    COUNT(*) AS total_appointments,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
GROUP BY scholarship;

/* ======================================
   SMS REMINDER EFFECTIVENESS
======================================= */

/* How do no-show rates differ with and without SMS reminders? */
/* What is the attendance rate with vs. without reminders? */

SELECT 
	CASE 
		WHEN sms_reminder = 1 THEN 'SMS sent'
        ELSE 'no SMS'
	END AS sms_status,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) AS attended_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'Show_Up' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS attendance_rate_pct,
	SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) AS missed_appointments,
	ROUND(
		SUM(CASE WHEN appointment_status = 'No_Show' THEN 1 ELSE 0 END) * 100.00
        / COUNT(*), 2) AS no_show_rate_pct
FROM appointments
WHERE sms_reminder IN (0, 1)
GROUP BY sms_status
ORDER BY 
	CASE sms_status
		WHEN 'SMS sent' THEN 1
        WHEN 'no SMS' THEN 2
	END;

/* ======================================
   KEY FINDINGS
======================================= */

/*

1. Appointments scheduled 1-2 months in advance had the highest no-show 
   rate (36.14%). While no-show rate generally increased with longer 
   waiting periods up to two months, appointments scheduled beyond two 
   months represented substantially fewer observations, limiting conclusions 
   about longer scheduling intervals.
2. Patients who missed appointments waited an average of 15.57 days, compared 
   to 13.52 days for patients who attended appointments.
3. Wednesday had the highest appointment volume, while Saturday experienced 
   the highest no-show rate. 
4. Young adults (18-34) had the highest no-show rate among all age groups.
5. Female patients accounted for the highest appointment volume and had a 
   lower no-show rate compared to male patients.
6. Patients with no reported health factors had the highest no-show rate
   among the three health-factor groups.
7. Patients with hypertension had a lower no-show rate than patients with\
   hypertension.
8. Patients receiving scholarship assistance had a higher no-show rate than
   patients without scholarship assistance.
9. Appointments with SMS reminders had a lower no-show rate than appointments 
   without reminders, suggesting reminders may be associated with improved 
   attendance.

/*

/* ======================================
   END OF ANALYSIS
======================================= */
