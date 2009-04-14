package MooseX::NonMoose::Meta::Role::Class;
use Moose::Role;

has replace_constructor => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

around _make_immutable_transformer => sub {
    my $orig = shift;
    my $self = shift;
    my @args = @_;
    unshift @args, replace_constructor => 1 if $self->replace_constructor;
    $self->$orig(@args);
};

no Moose::Role;

1;
