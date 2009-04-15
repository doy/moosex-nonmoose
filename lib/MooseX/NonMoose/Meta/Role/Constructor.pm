package MooseX::NonMoose::Meta::Role::Constructor;
use Moose::Role;

around can_be_inlined => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = $self->associated_metaclass;
    my $super_new = $meta->find_method_by_name($self->name);
    my $super_meta = $super_new->associated_metaclass;
    if ($super_meta->can('does_role')
     && $super_meta->does_role('MooseX::NonMoose::Meta::Role::Class')) {
        return 1;
    }

    return $self->$orig(@_);
};

sub _generate_instance {
    my $self = shift;
    my ($var, $class_var) = @_;
    my $new = $self->name;
    my $super_new_class = $self->associated_metaclass->find_next_method_by_name($new)->package_name;
    # XXX: this should probably be taking something from the meta-instance api,
    # rather than calling bless directly, but all it can do at the moment is
    # generate fresh instances
    "my $var = bless $super_new_class->$new(\@_), $class_var;\n";
}

no Moose::Role;

1;
