package App::bk::Command::ride;
use base 'App::Cmd::Command';
use App::bk::BikeStats;

sub abstract { return "Start a ride" }
sub usage_desc { return "bk ride [route] [message]" }
sub execute {
    my ($self, $opts, $args) = @_;
    my $stats = App::bk::BikeStats->new();
    my $route = shift @$args;
    $self->usage_error("Must supply a route!") unless(defined($route));
    my $message = shift @$args;
    $message  //= "Out for a ride";
    $stats->start_ride($route, $message);
    $stats->save();
    $SIG{INT} = sub {
        my $ride = $stats->end_ride;
        $stats->save;
        print "\n" . $stats->ride_summary($ride); 
        exit;
    };
    while (1) {
        sleep 1;
    }
}

# Add Handler for DateTime Format
1;
