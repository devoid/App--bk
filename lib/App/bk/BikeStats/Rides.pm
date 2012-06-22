package App::bk::BikeStats::Rides;
use common::sense;
use Moose;
use App::bk::BikeStats;
use App::bk::BikeStats::Ride;
use MooseX::Storage;
our $VERSION = $BikeStats::VERSION;
with Storage(format => 'JSON', io => 'File');
has rides => (
    is      => 'rw',
    isa     => 'ArrayRef[App::bk::BikeStats::Ride]',
    default => sub { []; }
);
1;
