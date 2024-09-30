#!/usr/bin/env perl

##
## Author......: See docs/credits.txt
## License.....: MIT
##

use strict;
use warnings;

use Digest::SHA1 qw (sha1_hex);
use Encode;

sub module_constraints { [[0, 256], [0, 256], [0, 27], [0, 27], [0, 27]] }

sub module_generate_hash
{
  my $word = shift;
  my $salt = shift;

  my $digest = sha1_hex ($salt . encode ("UTF-16LE", $word));

  my $hash = sprintf ("%s:%s", $digest, $salt);

  return $hash;
}

sub module_verify_hash
{
  my $line = shift;

  my ($hash, $salt, $word) = split (':', $line);

  return unless defined $hash;
  return unless defined $salt;
  return unless defined $word;

  $word = pack_if_HEX_notation ($word);

  my $new_hash = module_generate_hash ($word, $salt);

  return ($new_hash, $word);
}

1;
