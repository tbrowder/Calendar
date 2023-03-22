[![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions) [![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions) [![Actions Status](https://github.com/tbrowder/Calendar/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/Calendar/actions)

NAME
====

**Calendar** - Provides class data for producing calendars

**Calendar** is a Work in Progress (WIP). Please file an issue if there are any features you want added. Bug reports (issues) are always welcome.

Useful features now working:

  * Produce text calendar output to stdout, **in one of 13 languages**, identical to the `cal` program found on Linux hosts.

  * Calendar output can be for months less than one year.

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

See the **docs/WIP.rakudoc** for more information on planned features.

Program `make-cal`
------------------

Execute the program, without arguments, to see details of its current capabilities.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2020-2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

