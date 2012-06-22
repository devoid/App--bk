package App::bk::Command::history;
use base 'App::Cmd::Command';
use App::bk::BikeStats;
use Text::Table;

sub execute {
    my ($self, $opts, $args) = @_;
    my $stats = App::bk::BikeStats->new;
    my $rides = $stats->rides->rides;
    my @rows = ();
    my $index = scalar(@$rides);
    foreach my $ride (@$rides) {
        my $duration = sprintf("%02d:%02d:%02d", $ride->total_time); 

        push(
            @rows,
            [
                $index,                 $ride->route,
                $ride->distance,        $ride->start_time->ymd,
                _format_time($ride->start_time),
                _format_time($ride->end_time),
                $duration, $ride->average_mph    
            ]
        );
        $index -= 1;
    }
    my $tbl = Text::Table->new(
        "ID", "Route", "Distance (mi)", "Date", "Start", "Stop", "Total Time", "Average m/h"
    );
    $tbl->load(@rows);
    if(@rows) {
        print $tbl;
    }
}

sub _format_time {
    my $time = shift @_;
    my $hour = $time->hour;
    my $minute = $time->minute;
    my $ampm = "am";
    if ($hour > 12) {
        $ampm = "pm";
        $hour -= 12;
    }
    return "$hour:$minute$ampm";
}

1;
