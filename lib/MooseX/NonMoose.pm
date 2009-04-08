package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => ['extends_nonmoose'],
);

sub extends_nonmoose {
    my $caller = shift;
    my @superclasses = (@_, 'Moose::Object');
    Moose::extends($caller, @superclasses);
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

1;
