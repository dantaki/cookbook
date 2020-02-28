#!/usr/bin/perl
use strict; use warnings;
use Time::localtime qw(localtime);
sub timestamp {
  my $t = localtime;
  return sprintf( "%04d%02d%02d",
                  $t->year + 1900, $t->mon + 1, $t->mday);                 
}

print '[' . timestamp() . ']: Custom Time Format'. "\n";
