#!/usr/bin/env perl

##
## Author......: See docs/credits.txt
## License.....: MIT
##

use strict;
use warnings;

use Text::Iconv;

sub module_constraints { [[1, 8], [-1, -1], [-1, -1], [-1, -1], [-1, -1]] }

sub module_generate_hash
{
  my $word = shift;

  my $converter = Text::Iconv->new ("utf-8", "shift-jis");

  $word = $converter->convert ($word);

  my $salt = substr ($word . '..', 1, 2);

  $salt =~ s/[^\.-z]/\./go;

  $salt =~ tr/:;<=>?@[\\]^_`/A-Ga-f/;

  my $digest = crypt ($word, $salt);

  $digest = substr ($digest, -10);

  my $hash = sprintf ("%s", $digest);

  return $hash;
}

sub module_verify_hash
{
  my $line = shift;

  my ($hash, $word) = split (':', $line);

  return unless defined $hash;
  return unless defined $word;

  my $word_packed = pack_if_HEX_notation ($word);

  my $new_hash = module_generate_hash ($word_packed);

  return ($new_hash, $word);
}

1;
