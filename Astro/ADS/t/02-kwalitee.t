#
# Catch all the little errors that affect the Kwalitee of the module
#
use Test::More;

subtest 'meta.yml' => sub {
    plan skip_all => "Problems parsing META.yml";
    eval "use Test::CPAN::Meta";
    plan skip_all => "Test::CPAN::Meta required for testing META.yml" if $@;
    meta_yaml_ok();
};

subtest 'pod' => sub {
    eval "use Test::Pod 1.00";
    plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
    all_pod_files_ok();
};

done_testing();
