[![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/linux-perl.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions) [![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions) [![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions)

NAME
====

**Calendar** - Provides class data for producing calendars

**Calendar** is a Work in Progress (WIP). Please file an issue if there are any features you want added. Bug reports (issues) are always welcome.

Program `make-cal`
------------------

Execute the program, without arguments, to see details of its current capabilities.

SYNOPSIS
========

```raku
use Calendar;
#... use bin program 'make-cal'
```

DESCRIPTION
===========

**Calendar** Provides class data for producing calendars. It includes a Raku program to provide a personalized calendar: `make-cal`. Note that calendars may be printed in languages other than English. Through use of the author's public module **Date::Names**, the user can select the ISO two-letter language code and enter it in the `make-cal` program. Those codes are repeated here for reference:

### Table 1. Language ISO codes (lower-case)

<table class="pod-table">
<thead><tr>
<th>Language</th> <th>ISO code</th>
</tr></thead>
<tbody>
<tr> <td>Dutch</td> <td>nl</td> </tr> <tr> <td>English</td> <td>en</td> </tr> <tr> <td>French</td> <td>fr</td> </tr> <tr> <td>German</td> <td>de</td> </tr> <tr> <td>Indonesian</td> <td>id</td> </tr> <tr> <td>Italian</td> <td>it</td> </tr> <tr> <td>Norwegian (Bokmål)</td> <td>nb</td> </tr> <tr> <td>Norwegian (Nynorsk)</td> <td>nn</td> </tr> <tr> <td>Polish</td> <td>pl</td> </tr> <tr> <td>Romanian</td> <td>ro</td> </tr> <tr> <td>Russian</td> <td>ru</td> </tr> <tr> <td>Spanish</td> <td>es</td> </tr> <tr> <td>Ukranian</td> <td>uk</td> </tr>
</tbody>
</table>

Features
--------

### Event inputs

Use a CSV formatted file to define events to be loaded. An example file is written by executing `make-cal files`.

The file is handled by this author's module 'CSV-Autoclass' whose default CSV field separator character is the comma. That must be changed if you want to use commas in this CSV file. You may change it to 'semicolon' or 'pipe' by one of these methods:

1. setting it in one `$HOME/.CSV-Autoclass/config.yml` or `$HOME/.Calendar/config.yml` file with this entry:

    csv-autoclass-sepchar: pipe

2. setting environment variables `CSV_AUTOCLASS_SEPCHAR` or `CALENDAR_AUTOCLASS_SEPCHAR` to the desired character:

    CSV_AUTOCLASS_SEPCHAR=pipe
    CALENDAR_CSV_AUTOCLASS_SEPCHAR=pipe

Those settings are checked in this order, with the first one found being used:

  * CALENDAR_CSV_AUTOCLASS_SEPCHAR=pipe

  * `$HOME/.Calendar/config.yml`

  * CSV_AUTOCLASS_SEPCHAR=pipe

  * `$HOME/.CSV-Autoclass/config.yml`

### CSV format notes

Fields (header line): Month, Day, Year, Event, Name(s), Notes Field and contents:

  * Month

    need at least the first three letters of its name (in English, not case sensitive)

  * Day

    numerical day of the month

  * Year

    the four digits of a one-time event (if known)

  * Event - [code]

      * A

        wedding anniversary

      * B

        birthday

      * O

        some other notable event, or you may use a short set of chars to remind you (see 'Baptism' example in the example CSV file)

  * Name(s)

    short set of characters; use spaces to enable wrapping to fit a day square, otherwise they may be chopped off

  * Notes

    not printed on the calendar, but useful for reminders such as: Joe was 32 in 2022 so his birth year was 1990

Customization
-------------

Features and options may be set in the user's configuration file at `$HOME/.Calendar/config.yml`. The author's file looks like this (with some exeptions):

    # key: value
    lang: en

    # for the Calendar events CSV file
    # use a 'pipe' for SEPCHAR
    csv-autoclass-sepchar: '|'
    # the CSV event file location (example)
    calendar-event-file: "$HOME/.Calendar/calendar-events.csv"

    # location: City Hall, Gulf Breeze, Florida, US
    lat: 30.486092
    lon: -86.43761
    seasons: yes
    dst: yes
    holidays-us: yes
    holidays-misc: yes
    sunrise-set: no
    moon-phase: no

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2020-2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

