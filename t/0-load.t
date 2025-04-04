use Test;

my @modules = <
   Calendar
   Calendar::Seasons
   Calendar::Subs
   Calendar::UserEvents
   Calendar::Vars
   Calendar::PageProcs
   Calendar::Roles
   Calendar::Sprogs
>;

plan @modules.elems;

for @modules {
    use-ok "$_", "Module $_ can be used";
}
