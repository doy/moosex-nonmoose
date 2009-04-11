package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => ['extends'],
);

sub extends {
    my $caller = shift;
    my @superclasses = @_;

    push @superclasses, 'Moose::Object'
        unless grep { $_->isa('Moose::Object') } @superclasses;

    Moose::extends($caller, @superclasses);

    my $caller_meta = Class::MOP::Class->initialize($caller);
    # we need to get the non-moose constructor from the superclass
    # of the class where this method actually exists
    my $super_new = $caller_meta->find_next_method_by_name('new');

    if ($super_new->associated_metaclass->can('constructor_class')) {
        my $constructor_class_meta = Class::MOP::Class->initialize(
            $super_new->associated_metaclass->constructor_class
        );

        return if $constructor_class_meta->can('does_role')
               && $constructor_class_meta->does_role('MooseX::NonMoose::Meta::Role::Constructor');
    }

    $caller_meta->add_method(new => sub {
        my $class = shift;

        my $self = $super_new->execute($class, @_);

        my $params = $class->BUILDARGS(@_);
        my $moose_self = Class::MOP::Class->initialize($class)->new_object(
            __INSTANCE__ => $self,
            %$params,
        );
        $moose_self->BUILDALL($params);
        return $moose_self;
    });
}

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
    return $options{for_class}->meta;
}

1;
