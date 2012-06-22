use common::sense;
use App::bk::BikeStats;
use App::bk::BikeStats::Ride;
use Test::More;
my $test_count = 0;

# Test route validation, distances
{
    my $valid_routes = [qw( N231N W1N E41321W E24E NN nn)];
    my $invalid_routes = [qw( 123N WE3 24EW E41 )];
    my $stats = App::bk::BikeStats->new;
    foreach my $route (@$valid_routes) {
        chomp $route;
        ok $stats->valid_route($route), "$route should be valid";
        $test_count += 1;
    }
    foreach my $route (@$invalid_routes) {
        chomp $route;
        ok !$stats->valid_route($route), "$route should be invalid";
        $test_count += 1;
    }
    my $distances = {
        NN => 1,
        W1N => 3.9,
        N24N => 5,
        E3W => 7.3,
    };
    foreach my $route (keys %$distances) {
        my $expected = $distances->{$route};
        is $stats->route_distance($route), $expected,
        "Distance for $route should be correct";
        $test_count += 1;
    }
}

done_testing($test_count);
