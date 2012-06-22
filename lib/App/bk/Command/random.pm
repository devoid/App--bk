package App::bk::Command::random;
use base 'App::Cmd::Command';
use App::bk::BikeStats;

sub abstract { return "Suggest a random route" }
sub usage_desc { return "bk random" }
sub execute {
    my ($self, $opts, $args) = @_;
    my $stats = App::bk::BikeStats->new;
    my $routes = $stats->random_routes(12, 10000);
    print join("\n", @$routes) . "\n";
}
1;
