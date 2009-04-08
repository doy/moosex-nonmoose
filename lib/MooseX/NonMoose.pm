package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => ['extends_nonmoose'],
);

sub extends_nonmoose {
    my $caller = shift;

    my @moose_classes = grep { $_->isa('Moose::Object') } @_;
    Moose->throw_error(
        'extends_nonmoose can only be used on non-Moose classes; '
      . join(', ', @moose_classes)
      . (@moose_classes == 1 ? ' is a Moose class' : ' are Moose classes')
    ) if @moose_classes;

    Moose::extends($caller, @_, 'Moose::Object');

    Class::MOP::Class->initialize($caller)->add_method(new => sub {
        my $class = shift;
        my $meta = Class::MOP::Class->initialize($class);
        my $super_new = $meta->find_next_method_by_name('new');
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
