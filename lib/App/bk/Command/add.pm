package App::bk::Command::add;
use base 'App::Cmd::Command';
use App::bk::BikeStats;
use App::bk::BikeStats::Ride;
use DateTime::Format::Natural;

sub _parseTime {
    my ($self, $str) = @_;
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($str);
    if (   $parser->success
        && defined($dt->hour)
        && defined($dt->minute)
        && defined($dt->second) )
    {
        return { hour => $dt->hour, minute => $dt->minute, second => $dt->second };
    }
    $self->usage_error("Unable to parse time: $str");
}

sub _parseDate {
    my ($self, $str) = @_;
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($str);
    if (   $parser->success
        && defined($dt->day)
        && defined($dt->month)
        && defined($dt->year) )
    {
        return { day => $dt->day, month => $dt->month, year => $dt->year };
    }
    $self->usage_error("Unable to parse date: $str");

}

our $amendRules = {
    route => 1,
    date => \&_parseDate,
    start_time => \&_parseTime,
    end_time   => \&_parseTime,
    crashes => 1,
    notes => 1,
};

sub abstract { return "Add a ride in the ride history"; }
sub usage_desc { return "bk add [--key value]"; }
sub opt_spec {
    my $self = shift @_;
    my @base_opts = (
        ['--delete', "Delete a ride completely"],
    );
    foreach my $rule (keys %$amendRules) {
        push(@base_opts, ["$rule:s", "Set the value of $rule"]);
    }
    return @base_opts;
}
sub execute {
    my ($self, $opts, $args) = @_;
    my $stats = App::bk::BikeStats->new;
    my $rides = $stats->rides->rides;
    my $hash  = {};
    foreach my $rule (keys %$amendRules) {
        my $value = $amendRules->{$rule};
        if(defined($opts->{$rule})) {
            if(ref($value) eq 'CODE') {
                $hash->{$rule} = $value->($self, $opts->{$rule});
            } else {
                $hash->{$rule} = $opts->{$rule};
            }
        }
    }
    my $year = $hash->{date}->{year};
    my $month = $hash->{date}->{month};
    my $day = $hash->{date}->{day};
    delete $hash->{date};
    if(defined($hash->{start_time})) {
        $hash->{start_time} = DateTime->new(
            year => $year || 2012,
            month => $month,
            day => $day,
            hour => $hash->{start_time}->{hour},
            minute => $hash->{start_time}->{minute},
            second => $hash->{start_time}->{second},
        );
    }
    if(defined($hash->{end_time})) {
        $hash->{end_time} = DateTime->new(
            year => $year || 2012,
            month => $month,
            day => $day,
            hour => $hash->{end_time}->{hour},
            minute => $hash->{end_time}->{minute},
            second => $hash->{end_time}->{second},
        );
    }
    my $ride = App::bk::BikeStats::Ride->new($hash); 
    unshift(@$rides, $ride); 
    $stats->save;
}

