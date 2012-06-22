package App::bk::BikeStats::Ride 0.1;
use Moose;
use MooseX::Storage;
use MooseX::Storage::Engine;
use DateTime;
use DateTime::Format::ISO8601;
MooseX::Storage::Engine->add_custom_type_handler(
    'DateTime' => (
        expand => sub { DateTime::Format::ISO8601->parse_datetime(shift) },
        collapse => sub { (shift)->iso8601 }
    )
);
with Storage(format => 'JSON', io => 'File');
has route => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has start_time => (
    is       => 'ro',
    isa      => 'DateTime',
    builder  => '_build_start_time',
);
has end_time => (
    is       => 'rw',
    isa      => 'DateTime',
);
has notes => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

sub total_time {
    my ($self) = @_;
    my $d = $self->end_time->subtract_datetime(
        $self->start_time
    );
    return $d->in_units('hours','minutes','seconds');
}

sub average_mph {
    my ($self) = @_;
    my $d  = $self->distance;
    my ($h, $m, $s) = $self->total_time;
    my $t = $h + ($m/60) + ($s/3600);
    return sprintf("%0.2f", $d / $t);
}

sub stop {
    my ($self) = @_;
    $self->end_time(DateTime->now(time_zone => 'local'));
}

sub _build_start_time {
    return DateTime->now(time_zone => 'local');
}

sub distance {
    my ($self, $stat) = @_;
    $stat //= App::bk::BikeStats->new;
    return $stat->route_distance($self->route);
}

1;
