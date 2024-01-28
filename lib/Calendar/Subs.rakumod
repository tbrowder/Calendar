unit module Calendar::Subs;

use Date::Names;
use Date::Utils;

sub weeks-of-month(
    Date $d where { $_.day == 1 }, 
    :$cal-first-dow = 7,
    :$debug
    --> Hash
) is export {

    my $wim = weeks-in-month $d, :$cal-first-dow;
    # the DoW indices for a calendar week
    my DoW @dow = days-of-week $cal-first-dow;
    # get all the days in the month
    my $dim = $d.days-in-month;

    # need days in first week which requires:
    #    weekday of first day in the month
    my $dow1 = $d.day-of-week;
    #    calendar first day of the week
    #    sub input: $cal-first-dow
    #    yields: number of days in first calendar week
    #   
    my %h;
    my $wnum = 1;
    my $week1days = days-in-week1 $dow1, :$cal-first-dow;; 
    my @days = 1..$dim;

    if $debug {
        print "DEBUG: \@days: "; print " $_" for @days; 
        say(); 
        exit;
    }

    my @week;
    for 1..$week1days {
        my $day = @days.shift;
        @week.push: $day;
    }

    %h{$wnum} = [|@week];
    @week = [];
    ++$wnum;
    while 1 { # @days.elems {
        for 1..7 {
            if @days.elems {
                my $day = @days.shift;
                @week.push: $day;
            }
            else {
                # a partial last week
                # we're done
                %h{$wnum} = [|@week];
                last;
            }
        }
        # a full week
        %h{$wnum} = [|@week];
        @week = [];
        if not @days.elems {
            last;
        }
        else {
            ++$wnum;
        }
    }
    
    # now fill in the partial weeks 

    # first week
    my @w1 = %h<1>.Array;
    if @w1.elems < 7 {
        # add leading zeroes
        while @w1.elems < 7 {
            @w1.unshift: 0;
        }
        %h<1> = [|@w1];
    }

    # last week
    my @wL = %h{$wim}.Array;
    if @wL.elems < 7 {
        # add trailing zeroes
        while @wL.elems < 7 {
            @wL.push: 0;
        }
        %h{$wim} = [|@wL];
    }

    %h;
}

sub show-events-file(:$debug) is export {
    # lists resources CSV file contents to stdout
    my @lines1 = %?RESOURCES<Notes.txt>.lines;
    my @lines2 = %?RESOURCES<calendar-events.csv>.lines;
    .say for @lines1;
    .say for @lines2;
}

sub info-page(:$pdf!, :$debug) {
    # Either a blank page or data associated
    # with a month.
}

sub month-page(:$pdf!, :$month!, :$debug) {
    # Create a single page, landscape, with grid for a six-week month.
    # This page is on the bottom with either a blank or information
    # page on the top. At the print shop use the "pamphlet" format
    # and start with a cover page.

    # always print this page, even if it's blank
    info-page :$pdf, :$debug;

    my $page = $pdf.add-page;

}

=begin comment
sub create-cal(:$year!, :$debug) { # is export {
    # Create a 12-month PDF landscape calendar.
    #my @months = Calendar.new: $year;
    my @months = self.new: :$year;
    my $pdf  = PDF::Lite.new;

    cover-page :$pdf;
    for @months -> $month {
        month-page :$pdf, :$month;
    }
}
=end comment

sub caldata(@months? is copy, :$lang is copy, :$year is copy, :$debug) is export {
    # Produces output for all months or the specified
    # months identically to the Linux program 'cal'.
    if not $year {
        $year = DateTime.now.year + 1;
    }
    if not $lang {
        $lang = 'en'
    }

    my $dn = Date::Names.new: :$lang, :dset<dow2>;
    my @p;
    if @months.defined and (0 < @months[*] < 13) {
        @months .= sort({$^a <=> $^b});
        @p = @months;
    }
    else {
        #@p = @!pages[0..14];
        @p = 1..12;
    } 
    my $end = @p.end;

    for @p.kv -> $i, $p {
        my $mnum = $p;
        # the standard cal header spans
        # 7x2 + 6 = 20 characters
        # month and year are centered
        my $mname = $dn.mon($mnum);
        my $hdr = "$mname {$year}";
        my $leading = ' ' x ((22 - $hdr.chars) div 2) - 1;
        #note "DEBUG: \$leading = |$leading|";
        say $leading ~ $hdr;
        for <7 1 2 3 4 5 6> {
            my $dow = $dn.dow($_);
            if $_ != 6 {
                print "$dow ";
                next;
            }
            say "$dow";
        }

        # add one line of days of the week: 4, 5, or 6 weeks
        # note our calendars are sun..sat, thus 7, 1..6
        #my $dow = $p.dow1;  # day of the week for the first day of the month
        my $Fdim = Date.new: :$year, :month($mnum), :day(1);
        my $dow = $Fdim.day-of-week;
        #my $dim = $p.ndays; # days in the month
        my $dim = $Fdim.days-in-month; # days in the month

        # TODO refactor the common code if possible:
        if $dow == 7 {
            say " 1  2  3  4  5  6  7";
            my $next = 8;
            my $dremain = $dim - 7;

            # TODO BEGIN common code block
            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
            # TODO END common code block
        }
        elsif $dow == 1 {
            say "    1  2  3  4  5  6";
            my $next = 7;
            my $dremain = $dim - 6;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 2 {
            say "       1  2  3  4  5";
            my $next = 6;
            my $dremain = $dim - 5;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 3 {
            say "          1  2  3  4";
            my $next = 5;
            my $dremain = $dim - 4;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 4 {
            say "             1  2  3";
            my $next = 4;
            my $dremain = $dim - 3;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }
        elsif $dow == 5 {
            say "                1  2";
            my $next = 3;
            my $dremain = $dim - 2;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;;
        }
        elsif $dow == 6 {
            say "                   1";
            my $next = 2;
            my $dremain = $dim - 1;

            my $idx = 0;
            while $dremain {
                printf '%2d', $next;
                print " ";
                $next++;
                $dremain--;
                ++$idx;
                next if $idx < 7;
                $idx = 0;
                say();
            }
            say() unless not $idx;
        }

        # add a blank line after each month
        # except the last
        say() unless $i == $end;
    }
}
