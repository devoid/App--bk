use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::bk',
    license             => 'perl',
    dist_abstract       => "A command for tracking bike ride statistics",
    dist_author         => q{Scott Devoid <sdevoid@gmail.com>},
    dist_version_from   => 'lib/App/bk.pm',
    build_requires => {
        'App::Cmd'                  => 0,
        'common::sense'             => 0,
        'DateTime'                  => 0,
        'DateTime::Format::ISO8601' => 0,
        'DateTime::Format::Natural' => 0,
        'Moose'                     => 0,
        'MooseX::Storage'           => 0,
        'Test::More'                => 0,
        'Text::Table'               => 0,
        'Try::Tiny'                 => 0,
      },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'App-bk-*' ],
    create_makefile_pl => 'traditional',
    script_files => [ 'scripts/bk' ],
);

$builder->create_build_script();
