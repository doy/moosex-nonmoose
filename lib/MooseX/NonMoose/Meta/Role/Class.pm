package MooseX::NonMoose::Meta::Role::Class;
use Moose::Role;

around _make_immutable_transformer => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(inline_constructor => 0, @_);
};

no Moose::Role;

1;
