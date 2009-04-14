package MooseX::NonMoose::Meta::Role::Constructor;
use Moose::Role;

around can_be_inlined => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = $self->associated_metaclass;
    my $super_new = $meta->find_method_by_name($self->name);
    if (!$super_new->associated_metaclass->isa($self->_expected_constructor_class)) {
        # XXX: in the future, hopefully we'll be able to inline this?
        #return $self->should_be_inlined;
        return 1;
    }

    return $self->$orig(@_);
};

sub _initialize_body {
    my $self = shift;
    # TODO:
    # the %options should also include a both
    # a call 'initializer' and call 'SUPER::'
    # options, which should cover approx 90%
    # of the possible use cases (even if it
    # requires some adaption on the part of
    # the author, after all, nothing is free)
    my $source = 'sub {';
    $source .= "\n" . 'my $class = shift;';

    $source .= "\n" . 'return $class->Moose::Object::new(@_)';
    $source .= "\n    if \$class ne '" . $self->associated_metaclass->name
            .  "';\n";

    $source .= $self->_generate_params('$params', '$class');
    $source .= $self->_generate_instance('$instance', '$class');
    $source .= $self->_generate_slot_initializers;

    $source .= $self->_generate_triggers();
    $source .= ";\n" . $self->_generate_BUILDALL();

    $source .= ";\nreturn \$instance";
    $source .= ";\n" . '}';
    warn $source if $self->options->{debug};

    # We need to check if the attribute ->can('type_constraint')
    # since we may be trying to immutabilize a Moose meta class,
    # which in turn has attributes which are Class::MOP::Attribute
    # objects, rather than Moose::Meta::Attribute. And
    # Class::MOP::Attribute attributes have no type constraints.
    # However we need to make sure we leave an undef value there
    # because the inlined code is using the index of the attributes
    # to determine where to find the type constraint

    my $attrs = $self->_attributes;

    my @type_constraints = map {
        $_->can('type_constraint') ? $_->type_constraint : undef
    } @$attrs;

    my @type_constraint_bodies = map {
        defined $_ ? $_->_compiled_type_constraint : undef;
    } @type_constraints;

    my $super_new = $self->associated_metaclass->find_next_method_by_name('new');
    my $code = $self->_compile_code(
        code => $source,
        environment => {
            '$meta'  => \$self,
            '$attrs' => \$attrs,
            '@type_constraints' => \@type_constraints,
            '@type_constraint_bodies' => \@type_constraint_bodies,
            '$super_new' => \$super_new,
        },
    ) or $self->throw_error("Could not eval the constructor :\n\n$source\n\nbecause :\n\n$@", error => $@, data => $source );

    $self->{'body'} = $code;
}

sub _generate_instance {
    my $self = shift;
    my ($var, $class_var) = @_;
    "my $var = \$super_new->execute($class_var, \@_);\n";
}

no Moose::Role;

1;
