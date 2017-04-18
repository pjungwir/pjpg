/* pjpg--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pjpg" to load this file. \quit


-- If str is blank, converts it to NULL,
-- otherwise leaves it alone.
CREATE OR REPLACE FUNCTION blank_to_null(str text)
RETURNS text
AS
$$
  SELECT CASE WHEN str ~ '^\s*$' THEN NULL ELSE str END;
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Given a timestamp and its timezone,
-- converts it the same instant but expressed in a different time zone.
-- This is useful before doing things like `date_trunc('day', ...)`,
-- where the time zone will determine where to "cut".
-- Ruby on Rails projects especially can use this function
-- since they store everything as TIMESTAMP WITHOUT TIME ZONE by default.
CREATE OR REPLACE FUNCTION in_tz(t timestamp without time zone, from_tz text, to_tz text)
RETURNS timestamp without time zone
AS
$$
  SELECT t AT TIME ZONE from_tz AT TIME ZONE to_tz;
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Given a timestamp t (assumed to be in UTC),
-- returns the first instant in t's day
-- in the timezone tz,
-- and converts it back to UTC.
-- This is the same as `date_trunc('day', ...)`,
-- except we cut based on when days start in tz.
CREATE OR REPLACE FUNCTION beginning_of_day(t timestamp without time zone, tz text)
RETURNS timestamp without time zone
AS
$$
  SELECT in_tz(
           date_trunc('day', in_tz(t, 'UTC', tz)),
           tz,
           'UTC');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Returns the first moment of the week containing t, in timezone tz,
-- converted back to UTC.
-- Follows the USA convention where weeks start on Sunday
-- (which is NOT how `date_trunc('week', ...)` works.
CREATE OR REPLACE FUNCTION beginning_of_week_usa(t timestamp without time zone, tz text)
RETURNS timestamp without time zone
AS
$$
  SELECT in_tz(
           date_trunc('week', in_tz(t, 'UTC', tz) + INTERVAL '1 day') - INTERVAL '1 day',
           tz,
           'UTC');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Returns the first moment of the week containing t, in timezone tz,
-- converted back to UTC.
-- Follows the ISO convention where weeks start on Monday
-- (which is also how `date_trunc('week', ...)` works.
CREATE OR REPLACE FUNCTION beginning_of_week_iso(t timestamp without time zone, tz text)
RETURNS timestamp without time zone
AS
$$
  SELECT in_tz(
           date_trunc('week', in_tz(t, 'UTC', tz)),
           tz,
           'UTC');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Alias for beginning_of_week_usa.
CREATE OR REPLACE FUNCTION beginning_of_week(t timestamp without time zone, tz text)
RETURNS timestamp without time zone
AS
$$
  SELECT beginning_of_week_usa(t, tz);
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Returns a tsrange based on a start time and a number of days.
CREATE OR REPLACE FUNCTION day_range(t timestamp without time zone, tz text, width integer)
RETURNS tsrange
AS
$$
  SELECT tsrange(beginning_of_day(t, tz), beginning_of_day(t, tz) + concat(width, ' days')::interval, '[)');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Returns a tsrange based on a start time and a number of weeks.
CREATE OR REPLACE FUNCTION weekusa_range(t timestamp without time zone, tz text, width integer)
RETURNS tsrange
AS
$$
  SELECT tsrange(beginning_of_week_usa(t, tz), beginning_of_week_usa(t, tz) + concat(width, ' weeks')::interval, '[)');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Returns a tsrange based on a start time and a number of weeks.
CREATE OR REPLACE FUNCTION weekiso_range(t timestamp without time zone, tz text, width integer)
RETURNS tsrange
AS
$$
  SELECT tsrange(beginning_of_week_iso(t, tz), beginning_of_week_iso(t, tz) + concat(width, ' weeks')::interval, '[)');
$$
LANGUAGE sql STRICT IMMUTABLE
;

-- Alias for weekusa_range.
CREATE OR REPLACE FUNCTION week_range(t timestamp without time zone, tz text, width integer)
RETURNS tsrange
AS
$$
  SELECT weekusa_range(t, tz, width);
$$
LANGUAGE sql STRICT IMMUTABLE
;


