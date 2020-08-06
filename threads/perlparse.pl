#!/usr/bin/env perl
my ($file) = @ARGV;

open my $in, '<', $file || die;

my $max = 0;
my $record;
while (my $line = readline($in) ) {
  my @fields = split / /, $line;
  if ($fields[0] eq 'en' and $fields[2] > $max) {
	$max = $fields[2];
	$record = \@fields;
  }
}
print join("\t", @{$record});
