package MooseX::Role::Data::Verifier;
use strict;
use warnings;

# ABSTRACT: Moose role for generating Data::Verifier profiles from Moose objects.

use Moose::Role;

=head1 SYNOPSIS

    package TestClass;
    use Moose;
  
    with 'MooseX::Role::Data::Verifier';

    has 'name' => (
        is => 'rw',
        isa => 'Str',
        required => 1
    );
  
    # ... elsewhere
  
    my $tc = TestClass->new;
  
    my $dv = Data::Verifier->new(
        profile => $tc->get_verifier_profile
    );
  
    $dv->verify(...); # Verify!
  
=head1 DESCRIPTION

MooseX::Role::Data::Verifier provides a simple C<get_verifier_profile> method
that generates a profile suitable for Data::Verifier from a Moose object.

=head1 NOTES

This module ignores anonymous type-constraints.  There's also no way to infer
from the attribute that filters need to be used.  If you want to add filters,
they can be applied globally or added afterward to the hashref returned by
C<get_verifier_profile>.
  
=cut

sub get_verifier_profile {
    my ($self) = @_;

    my @attributes = $self->meta->get_all_attributes;

    my %profile;
    foreach my $attr (@attributes) {
        my $name = $attr->name;

        my $field = {};
        $field->{required} = $attr->is_required ? 1 : 0;

        my $tc = $attr->type_constraint;
        if(defined($tc) && $tc->name ne '__ANON__') {
            $field->{type} = $tc->name;
        }

        $profile{$name} = $field;
    }

    return \%profile;
}

1;