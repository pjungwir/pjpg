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

blank_to_null(str text)




    

