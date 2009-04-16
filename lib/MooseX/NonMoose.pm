package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods;

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class               => $options{for_class},
        metaclass_roles         => ['MooseX::NonMoose::Meta::Role::Class'],
        constructor_class_roles =>
            ['MooseX::NonMoose::Meta::Role::Constructor'],
    );
    return Class::MOP::class_of($options{for_class});
}

1;
