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
        my $self = $class->SUPER::new(@_);
        my $params = $class->BUILDARGS(@_);
        my $moose_self = Class::MOP::Class->initialize($class)->new_object(
            __INSTANCE__ => $self,
            %$params,
        );
        $moose_self->BUILDALL($params);
        return $moose_self;
    });
}

1;
