
use strict;
use warnings;

use AnyEvent;
use AnyEvent::Twitter::Stream;
use Getopt::Long;
use YAML::XS qw( LoadFile Dump );

my $conf_file = undef;

GetOptions(
    'conf=s'   => \$conf_file,
);

die "--conf conf_file\n" unless $conf_file;

my $conf = LoadFile( $conf_file );

my $done = AE::cv;

my $listener = AnyEvent::Twitter::Stream->new(
    username => $conf->{ twitter }->{ user },
    password => $conf->{ twitter }->{ pswd },
    method   => "filter",  # "firehose" for everything, "sample" for sample timeline
    track    => join( ',', @{ $conf->{ twitter }->{ track } } ),
    on_tweet => sub {
        my $tweet = shift;
        warn Dump $tweet;
    },
    on_keepalive => sub {
        warn "ping\n";
    },
    on_delete => sub {
    },
    timeout => 45,
);

$done->recv;
