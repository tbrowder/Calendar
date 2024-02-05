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

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2020-2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

