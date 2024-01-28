#!/usr/bin/env raku

use Date::Names;
use Date::Utils;
use Test;

my $dn = Date::Names.new;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | YYYY

    Demonstrates use of Date::Utils subs to create a list
      of weeks in a month.
    HERE
    exit
}

my $year = 2024;
my $arg = @*ARGS.head;
if $arg ~~ /(\d**4)/ {
    $year = ~$0;
}

my $cal-first-dow = 7;

my $last = 2;
for 1..$last -> $mnum {
    my $mnam = $dn.mon($mnum);
    my $d1 = Date.new: :$year, :month($mnum);
    my $d  = $d1;

    my $yr  = $d.year;
    my $mon = $d.month;
    my $day = $d.day;
    my $dom = $d.day-of-month; # alias of .day
    my $diy = $d.days-in-year;

    my $is-leap = $d.is-leap-year;

    my $first-dom = $d1.day-of-week;
    my $dnam = $dn.dow($first-dom);
    my $first-doy = $d1.day-of-year;
    my $dim       = $d1.days-in-month;
    my $wdom      = $d.weekday-of-month; # 1..5 number of times this dow has occurred
                                         #      in the month

    # week data, based on ISO definition first week contains Jan 4
    my ($wyear, $woy) = $d1.week;
    my $wn            = $d1.week-number;
    my $wy            = $d1.week-year;
    my $dcal-dow1 = $dn.dow($cal-first-dow);

    print qq:to/HERE/;
    === Working month $mnum ($mnam) $year
        Your calendar week starts on $cal-first-dow ($dcal-dow1)
        Days in the month: $dim
        First dow:    $first-dom ($dnam)
        Week of year: $wn
    
        The days by calendar week (starting on $dnam):
    HERE 
    my %w = weeks-of-month $d1, :$cal-first-dow, :debug;
    #dd %w; exit;

    for %w.keys.sort({ $^a <=> $^b }) -> $wnum {
        my @days = @(%w{$wnum});
        print "       	week $wnum:";
        print(sprintf(" %2d", $_)) for @days;
        say()
    }
}

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

    # print "DEBUG: \@days: "; print " $_" for @days; say(); exit;
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
    #dd %h; exit;
}

