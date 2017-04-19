pjpg
====

This is a Postgres extension for a bunch of general-purpose functions I find useful,
especially around time zones, but some other stuff too.


Installing
----------

This package installs like any Postgres extension. First say:

    make && sudo make install

You will need to have `pg_config` in your path,
but normally that is already the case.
You can check with `which pg_config`.

Then in the database of your choice say:

    CREATE EXTENSION pjpg;


Usage
-----

Once you've installed the extension,
you can use these functions:

### text blank\_to\_null(str text)

Converts "blank" strings to `NULL`,
where blank is any string that is empty or contains nothing but whitespace.
It is the same meaning as the [`blank?` method in Rails](https://apidock.com/rails/Object/blank%3F)
or the [ActiveRecord `presence` validation](http://guides.rubyonrails.org/active_record_validations.html#presence),
when used on strings.
This function is intended to use in triggers to keep null-like data out of not-null columns.

### timestamp without time zone in\_tz(t timestamp without time zone, from\_tz text, to\_tz text)

Converts `t` from the timezone `from_tz` to the timezone `to_z`.
The `*_tz` parameters should be strings that match entries in `pg_catalog.pg_timezone_names.name`,
e.g. `America/Los_Angeles`.
This method does not change the *instant* of `t`,
but tells you the same instant in a different place.
It is useful as an input to `date_trunc`,
so that you can slice the timeline into days using the right timezone.

### timestamp without time zone beginning\_of\_day(t timestamp without time zone, tz text)

Given a time `t` and its timezone `tz`, finds the first moment of the day.

### timestamp without time zone beginning\_of\_week\_usa(t timestamp without time zone, tz text)

Given a time `t` and its timezone `tz`, finds the first moment of the week.
This function follows USA conventions, where the week begins on Sunday.
(This is different than the built-in `date_trunc('week', ...)` function.)

### timestamp without time zone beginning\_of\_week\_iso(t timestamp without time zone, tz text)

Given a time `t` and its timezone `tz`, finds the first moment of the week.
This function follows ISO conventions, where the week begins on Monday.
(This is the same as than the built-in `date_trunc('week', ...)` function,
except this function uses the specified time zone.)

### timestamp without time zone beginning\_of\_week(t timestamp without time zone, tz text)

Alias for `beginning_of_week_usa`.

### tsrange day\_range(t timestamp without time zone, tz text, width integer)

Returns a `[)` range spanning `width` days and beginning at midnight
on the same day as time `t` in timezone `tz`.

### tsrange weekusa\_range(t timestamp without time zone, tz text, width integer)

Returns a `[)` range spanning `width` weeks and beginning at midnight Sunday
on the same week as time `t` in timezone `tz`.

### tsrange weekiso\_range(t timestamp without time zone, tz text, width integer)

Returns a `[)` range spanning `width` weeks and beginning at midnight Monday
on the same week as time `t` in timezone `tz`.

### tsrange week\_range(t timestamp without time zone, tz text, width integer)

Alias for `weekusa_range`.


