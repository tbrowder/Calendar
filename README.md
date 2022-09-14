[![Actions Status](https://github.com/tbrowder/Calendar/workflows/test/badge.svg)](https://github.com/tbrowder/Calendar/actions)

NAME
====

**Calendar** - Provides class data for producing calendars

**Calendar** is a Work in Progress (WIP). Please file an issue if there are any features you want added. Bug reports (issues) are always welcome.

Useful features now working:

  * Produce text calendar output to stdout, **in one of 13 languages**, identical to the `cal` program found on Linux hosts.

  * Show an example events CSV file for upcoming personalization of PDF wall calendars.

SYNOPSIS
========

```raku
use Calendar;
```

DESCRIPTION
===========

**Calendar** Provides class data for producing calendars. It includes a Raku program to provide a personalized calendar: `make-cal`. Note that calendars may be printed in other languages than English. Through use of the author's public module **Date::Names**, the user can select the ISO two-letter language code and enter it in the `make-cal` program. Those codes are repeated here for reference:

### Table 1. Language ISO codes (lower-case)

<table class="pod-table">
<thead><tr>
<th>Language</th> <th>ISO code</th>
</tr></thead>
<tbody>
<tr> <td>Dutch</td> <td>nl</td> </tr> <tr> <td>English</td> <td>en</td> </tr> <tr> <td>French</td> <td>fr</td> </tr> <tr> <td>German</td> <td>de</td> </tr> <tr> <td>Indonesian</td> <td>id</td> </tr> <tr> <td>Italian</td> <td>it</td> </tr> <tr> <td>Norwegian (Bokmål)</td> <td>nb</td> </tr> <tr> <td>Norwegian (Nynorsk)</td> <td>nn</td> </tr> <tr> <td>Polish</td> <td>pl</td> </tr> <tr> <td>Romanian</td> <td>ro</td> </tr> <tr> <td>Russian</td> <td>ru</td> </tr> <tr> <td>Spanish</td> <td>es</td> </tr> <tr> <td>Ukranian</td> <td>uk</td> </tr>
</tbody>
</table>

In order to create a personalized calendar, you must provide some data:

  * A single name in ASCII text, with no spaces, consisting of only alphanumeric characters or underscores or hyphens. That name is used to uniquely identify your calendar and its data.

  * A list of anniversaries, birthdays, and other events the user desires (see table below, also see the accompanying Excel spreadsheet). The sample spreadsheet is also available by running program `make-cal` with the `files` mode..

  * A list of personalized lines for the cover (optional).

  * A list of monthly quotations if the standard set is not wanted. Another option is to forego monthly options.

Example event data
------------------

The following table is available as an Excel spreadsheet or a printed form. There are five data fields used to create the calendar, and a sixth field, **Notes**, that is for your use as needed.

  * **Month**

    At least the first three letters of its name (not case-sensitive).

  * **Day**

    The numerical day of the month.

  * **Year**

    All four digits of the year of a one-time event (if known).

  * **Event**

      * A (wedding anniversary)

      * B (birthday

      * O (some other notable event, or you may use a short set of chars to remind you; see 'Baptism' example.

  * **Name(s)**

    A short set of characters; spaces or separator characters (`,`, `/`, `.`, `&`) enable wrapping to fit a day square, otherwise some characters they may be chopped off.

  * **Notes**

    Not printed on the calendar, but useful for reminders such as: 'Joe was 32 in 2022 so his birth year was 1990'.

The following table shows examples of each data field:

### Table 2. Example event entries

<table class="pod-table">
<thead><tr>
<th>Month</th> <th>Day</th> <th>Year</th> <th>Event</th> <th>Name</th> <th>Notes</th>
</tr></thead>
<tbody>
<tr> <td>Apr</td> <td>3</td> <td>1985</td> <td>B</td> <td>Sally L.</td> <td></td> </tr> <tr> <td>Sep</td> <td>29</td> <td>2010</td> <td>A</td> <td>Joe &amp; Sue</td> <td></td> </tr> <tr> <td>Jun</td> <td>14</td> <td>2022</td> <td>Baptism</td> <td>Harold D.</td> <td></td> </tr> <tr> <td>may</td> <td>9</td> <td>1998</td> <td>A</td> <td>Bill/Peggy</td> <td></td> </tr>
</tbody>
</table>

Program `make-cal`
------------------

Execute the program, without arguments, to see details of its current capabilities.

    Usage: make-cal <mode> [options...]

    Modes:
        files  - Creates a sample CSV file for personalization
        caldat - Runs the Linux 'cal' program and prints results to stdout
        help   - Extended help, including language ISO codes

    Options:
        lang=X - ISO language code, the default is 'en' (English)
        y=YYYY - The default is the next calendar year. Note years prior to
                 2019 cannot be created correctly due to lack of data.
        m=M    - The month for option 'caldat' only (1..12).
        debug  - Developer use

HOLIDAY API
-----------

An optional feature to be added is a list of standard holidays, or user-selected ones, provided either the user's input file or sslected automatically by country.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2020-2022 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

