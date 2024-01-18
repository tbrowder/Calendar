unit module Roles;

role CalPart is export {
    # for other than class Calendar
    has $.lang is required;
    has $.year; # is required;
    has $.number is required;
    has Date $.date; #  is required;
}

# these are defined in a class' TWEAK
# for a Day and a Month
role Named does CalPart is export {
    use Date::Names;
    has $.name;
    has $.abbrev;
}
