package App::bk::BikeStats 0.1;
use Moose;
use common::sense;
use DateTime;
use Try::Tiny;
use App::bk::BikeStats::Rides;
use App::bk::BikeStats::Ride;

has rides => (
    is      => 'rw',
    isa     => 'App::bk::BikeStats::Rides',
    builder => '_build_rides',
    lazy    => 1
);
has save_filename => (
    is      => 'rw',
    isa     => 'Str',
    builder => '_build_save_filename',
    lazy    => 1
);

our $states = {
    S => {
        N => 'A',
        W => 'C',
        E => 'B',
    },
    A => {
        N => 'S',
        1 => 'C',
        2 => 'B',
        4 => 'B',
    },
    B => {
        E => 'S',
        4 => 'A',
        2 => 'A',
        3 => 'C',
    },
    C => {
        W => 'S',
        1 => 'A',
        3 => 'B',
    }
};
our $edges  = {
    N => { distance => 0.5 },
    E => { distance => 1.6 },
    W => { distance => 1.3 },
    1 => { distance => 2.1 },
    2 => { distance => 2.5 },
    3 => { distance => 4.4 },
    4 => { distance => 1.5 },
};

sub save {
    my ($self) = @_;
    my $filename = $self->save_filename;
    $self->rides->store($filename);
}

# RIDE Creation / Update
sub start_ride {
    my ($self, $route, $message) = @_;
    $self->valid_route($route);
    my $ride = App::bk::BikeStats::Ride->new(route => $route);
    unshift(@{$self->rides->rides}, $ride);
}

sub end_ride {
    my ($self) = @_;
    my $last = $self->rides->rides->[0];
    $last->stop;
    return $last;
}

sub ride_summary {
    my ($self, $ride) = @_;
    my $distance = $ride->distance($self);
    my ($h, $m, $s) = $ride->total_time;
    map { $_ = sprintf("%02d", $_) } ($h, $m, $s);
    my $mph = $ride->average_mph;
    return <<END;
Biked $distance miles in $h:$m:$s.
Average speed:\t$mph mph
END
}




# ROUTE HANDLING FUNCTIONS
sub parse_route {
    my ($self, $route, $function) = @_;
    my $state_id = 'S';
    my $rtv = undef;
    my $state = $App::bk::BikeStats::states->{$state_id};
    my @parts = split(//, $route);
    map { $_ = uc($_) } @parts;
    while (my $token = shift @parts) {
        my $old_id = $state_id;
        $state_id = $state->{$token};
        die "Invalid Route" unless(defined($state_id));
        $rtv = $function->({
            start => $old_id,
            end => $state_id,
            token => $token,
            rtv => $rtv
        });
        $state = $App::bk::BikeStats::states->{$state_id};
        die "Invalid Route" unless(defined($state));
    }
    die "Invalid Route" unless($state_id eq 'S');
    return $rtv;
}

sub valid_route {
    my ($self, $route) = @_;
    my $fn = sub { return 1; };
    my $s = 1;
    try { $self->parse_route($route, $fn) } catch { $s = 0 };
    return $s;
}

sub route_distance {
    my ($self, $route) = @_;
    my $fn = sub {
        my $args = shift @_;
        my $token = $args->{token};
        my $edge = $App::bk::BikeStats::edges->{$token};
        return $args->{rtv} + $edge->{distance};
    };
    return $self->parse_route($route, $fn);
}

sub random_routes {
    my ($self, $max, $wait) = @_;
    my $routes = {};
    for(my $i=0; $i<$wait; $i++) {
        my $complete = 0;
        my $route = [];
        my $state_id = 'S';
        my ($p_token, $r_token);
        while (1) {
            my $state = $App::bk::BikeStats::states->{$state_id};
            my $tokens = [ keys %$state ];
            while (1) {
                my $r = int(rand(@$tokens-1));
                $r_token = $tokens->[$r];
                last unless(defined($p_token) && $r_token eq $p_token);
            }
            push(@$route, $r_token);
            my $d = $max;
            try {
                $d = $self->route_distance(join("", @$route));
            };
            last if($d > $max);
            $p_token = $r_token;
            $state_id = $state->{$r_token};
            if($state_id eq 'S') {
                $complete = 1;
                last;
            }
        }
        next unless($complete);
        $route = join("", @$route);
        $routes->{$route} = 1;
    }
    return [keys %$routes];
}
## BUILDERS
sub _build_save_filename {
    return $ENV{HOME} . "/.rides";
}
sub _build_rides { 
    my ($self) = @_;
    if( -f $self->save_filename ) {
        return App::bk::BikeStats::Rides->load($self->save_filename);
    } else {
        return App::bk::BikeStats::Rides->new;
    }
}
1;
