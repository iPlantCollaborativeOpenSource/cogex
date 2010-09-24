
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'CoGeX',
    VERSION_FROM => 'lib/CoGeX.pm',                    # finds \$VERSION
    AUTHOR       => ' (elyons@nature.berkeley.edu)',
    ABSTRACT     => 'CoGeX',
    PREREQ_PM    => {
        'Benchmark'                     => 0,
        'Carp'                          => 0,
        'Class::Accessor'               => 0,
        'CoGe::Accessory::Annotation'   => 0,
        'CoGe::Accessory::genetic_code' => 0,
        'DBIx::Class'                   => 0.08,
        'DBIx::Class::Core'             => 0,
        'DBIx::Class::ResultSet'        => 0,
        'DBIx::Class::Schema'           => 0,
        'Data::Dumper'                  => 0,
        'File::Spec::Functions'         => 0,
        'LWP::Simple'                   => 0,
        'POSIX'                         => 0,
        'Test::Simple'                  => 0.44,
        'Text::Wrap'                    => 0,
        'Time::HiRes'                   => 0,
    },
);
