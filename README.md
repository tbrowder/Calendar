[![Actions Status](https://github.com/tbrowder/Calendar/workflows/test/badge.svg)](https://github.com/tbrowder/Calendar/actions)

NAME
====

**Calendar** - Provides class data for producing calendars

TEMPORARY DISCLAIMER
====================

**Calendar** is a Work in Progress (WIP). Please file an issue if there are any features you want added. Bug reports (issues) are always welcome.

SYNOPSIS
========

```raku
use Calendar;
```

DESCRIPTION
===========

**Calendar** Provides class data for producing calendars. It includes a Raku program to provide a personalized calendar: `make-cal`.

In order to create a personalized calendar, you must provide some data:

  * A list of anniversaries, birthdays, and other events the user desires (see table below, also see accompanying Excel spreadsheet)

  * A list of personalized lines for the cover (optional).

  * A list of monthly quotations if the standard set is not wanted. Another option is to forego monthly options.

  * A single name in ASCII text, with no spaces, consisting of only alphanumeric characters or underscores or hyphens.

<table class="pod-table">
<caption>Example event data</caption>
<thead><tr>
<th>Month</th> <th>Day</th> <th>Year</th> <th>Event</th> <th>Name</th> <th>Notes</th>
</tr></thead>
<tbody>
<tr> <td>Apr</td> <td>3</td> <td>1985</td> <td>B</td> <td>Sally L.</td> <td></td> </tr> <tr> <td>Sep</td> <td>29</td> <td>2010</td> <td>A</td> <td>Joe &amp; Sue</td> <td></td> </tr> <tr> <td>Jun</td> <td>14</td> <td>2022</td> <td>Baptism</td> <td>Harold D.</td> <td></td> </tr> <tr> <td>may</td> <td>9</td> <td>1998</td> <td>A</td> <td>Bill/Peggy</td> <td></td> </tr>
</tbody>
</table>

See also related modules by the same author:
============================================

  * [**Astro::Almanac**](https://github.com/tbrowder/Astro-Almanac)

  * [**DateTime::Locations**](https://github.com/tbrowder/DateTime-Location)

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2020-2021 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

