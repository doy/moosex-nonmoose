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
    # XXX: this doesn't need to be installed for every class, just for the
    # classes directly below ones with custom constructors... how can we do
    # this?
    $caller_meta->add_method(new => sub {
        my $class = shift;
        my $meta = Class::MOP::Class->initialize($class);

        # we need to get the non-moose constructor from the superclass
        # of the class where this method actually exists
        my $super_new = $caller_meta->find_next_method_by_name('new');
        # but we need to call it as a method on the class we're actually
        # trying to instantiate
        my $self = $super_new->execute($class, @_);

        my $params = $class->BUILDARGS(@_);
        my $moose_self = $meta->new_object(
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
        for_class                 => $options{for_class},
        metaclass_roles => ['MooseX::NonMoose::Meta::Role::Class'],
    );
    return $options{for_class}->meta;
}

1;
