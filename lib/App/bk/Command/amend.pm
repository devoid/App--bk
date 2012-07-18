package App::bk::Command::amend;
use base 'App::Cmd::Command';
use App::bk::BikeStats;

sub _parseTime {
    my ($self, $str) = @_;
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($str);
    if (   $parser->success
        && defined($dt->hour)
        && defined($dt->minute)
        && defined($dt->second) )
    {
        return $dt;
    }
    $self->usage_error("Unable to parse time: $str");
}

our $amendRules = {
    route => 1,
    start => \&_parseTime,
    end   => \&_parseTime,
    crashes => 1,
    notes => 1,
};

sub abstract { return "Edit a ride in the ride history"; }
sub usage_desc { return "bk amend [id] [--key value]"; }
sub opt_spec {
    my $self = shift @_;
    my @base_opts = (
        ['delete', "Delete a ride completely"],
    );
    foreach my $rule (keys %$amendRules) {
        push(@base_opts, ["$rule:s", "Update $rule with new value"]);
    }
    return @base_opts;
}
sub execute {
    my ($self, $opts, $args) = @_;
    my $id = shift @$args;
    $self->usage_error("Must supply an id") unless(defined($id));
    my $stats = App::bk::BikeStats->new;
    my $rides = $stats->rides->rides;
    my $size = scalar(@$rides);
    $self->usage_error("Invalid id") unless($id > 0 && $id <= $size);
    my $ride = $rides->[$size - $id];
    if(defined($opts->{delete})) {
        splice(@$rides, ($size - $id), 1);
        $stats->save; 
        exit;
    }
    foreach my $rule (keys %$amendRules) {
        my $value = $amendRules->{$rule};
        if(defined($opts->{$rule})) {
            if(ref($value) eq 'CODE') {
                $ride->$rule($value->($opts->{$rule}));
            } else {
                $ride->$rule($opts->{$rule});
            }
        }
    }
    $stats->save;
}

