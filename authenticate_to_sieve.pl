#!/usr/bin/perl -w

use strict;
use warnings FATAL => qw(uninitialized);

use Getopt::Long qw(:config no_auto_abbrev require_order);
use IO::Socket;
use IO::Socket::INET;
use IO::Select;
use MIME::Base64;

my %long_opts = (remote => "imap", port => "sieve");
GetOptions("remote=s" => \$long_opts{remote},
	   "login=s" => \$long_opts{login},
	   "pw=s" => \$long_opts{pw},
    ) or die "bad options";

&usage unless defined($long_opts{login}) && defined($long_opts{pw});

sub usage
{
    printf "usage: %s [-remote=imap.domain.tld] [-port=sieve] -login=postmaster\@domain.tld -pw=password\n", $0;
    exit 1;
}

my $s = IO::Socket::INET->new(PeerAddr => $long_opts{remote}, PeerPort => $long_opts{port}) or die;
while (<$s>)
{
    chomp;

    printf "<- %s\n", $_;
    last if $_ =~ m/^OK /o;
}

my $credentials = sprintf("AUTHENTICATE \"PLAIN\" \"%s\"", encode_base64("\0".$long_opts{login}."\0".$long_opts{pw}, ""));
printf "-> %s\n", $credentials;
printf $s "%s\n", $credentials;

while (<$s>)
{
    chomp;

    printf "<- %s\n", $_;
    last if $_ =~ m/^OK /o;
}

print "-> Listscripts\n";
print $s "Listscripts\n";

while (<$s>)
{
    chomp;

    printf "<- %s\n", $_;
    last if $_ =~ m/^OK /o;
}
