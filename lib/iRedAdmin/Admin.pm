package iRedAdmin::Admin;

use Moo;

has 'ref' => (is => 'ro');

sub Add {
    my ($self, %data) = @_;
    
    if (Email::Valid->address($data{email})) {
        $self->ref->mech->get($self->ref->_address . '/create/admin');
        $self->ref->mech->submit_form(
            form_number => 1,
            fields => {
                mail => $data{email},
                newpw => $data{password},
                confirmpw => $data{password},
                cn => $data{name},
                preferredLanguage => $self->ref->_lang($data{lang})
            }
        );
        
        my $success = $self->ref->_success;
        $self->Add(%data) if $success == 2;
        return $success ? 1 : 0;
    }else{
        $self->ref->set_error('Email is invalid!');
        return 0;
    }
}

sub Edit {
    my ($self, %data) = @_;
    
    if (Email::Valid->address($data{email})) {
        $self->ref->mech->get($self->ref->_address . '/profile/admin/general/' . $data{email});
        
        my %form;
        $form{cn} = $data{name} if exists $data{name};
        $form{preferredLanguage} = $self->ref->_lang($data{lang}) if $data{lang};
        if (exists $data{enable}) {
            $form{accountStatus} = 'active' if $data{enable};
            $self->ref->mech->untick('accountStatus', 'active') unless $data{enable};
        }
        $self->ref->mech->submit_form(
            form_number => 1,
            fields => \%form
        );
        
        my $success = $self->ref->_success;
        $self->Edit(%data) if $success == 2;
        return $success ? 1 : 0;
    }else{
        $self->ref->set_error('Email is invalid!');
        return 0;
    }
}

sub Password {
    my ($self, %data) = @_;
    
    if (Email::Valid->address($data{email})) {
        $self->ref->mech->get($self->ref->_address . '/profile/admin/general/' . $data{email});
        
        $self->ref->mech->submit_form(
            form_number => 2,
            fields => {
                newpw => $data{password},
                confirmpw => $data{password}
            }
        );
        
        my $success = $self->ref->_success;
        $self->Password(%data) if $success == 2;
        return $success ? 1 : 0;
    }else{
        $self->ref->set_error('Email is invalid!');
        return 0;
    }
}

sub Enable {
    my ($self, @email) = @_;
    
    $self->_apply('enable', [@email]);
}

sub Disable {
    my ($self, @email) = @_;
    
    $self->_apply('disable', [@email]);
}

sub Delete {
    my ($self, @email) = @_;
    
    $self->_apply('delete', [@email]);
}

sub _apply {
    my ($self, $type, @email) = @_;
    
    $self->ref->mech->get($self->ref->_address . '/admins');

    my %form;
    $form{action} = $type;
    $form{mail} = \@email;
    $self->ref->mech->submit_form(
        form_number => 1,
        fields => \%form
    );
    
    my $success = $self->ref->_success;
    $self->_apply($type, @email) if $success == 2;
    return $success ? 1 : 0;

}

1;

__END__

=encoding utf8
 
=head1 NAME

iRedAdmin::Admin - API for add, edit, delete, enable and disable User Admin

=cut

=head1 VERSION
 
Version 0.03
 
=cut
 
=head1 SYNOPSIS
 
    use iRedAdmin;
     
    my $iredadmin = iRedAdmin->new(
        url => 'https://hostname.mydomain.com/iredadmin',
        username => 'postmaster@mydomain.com',
        password => 'your_password',
        cookie => '/home/user/cookie.txt',
        lang => 3
    );
    
    my $admin = $iredadmin->Admin->Add(
        email => 'foo@domain.com',
        password => 'your_password',
        name => 'Foo',
        lang => 3
    );
    
    print $iredadmin->error unless $admin; # print error if $admin is equal 0
    
=cut

=head1 METHODS

=head2 Add

Method to add Admin.

=cut

=head3 Arguments

B<email>

Email of Admin


B<password>

Password of Admin

B<name>

Display Name of Admin (Optional)

B<lang>

Language default of Admin, default English.
See more about L<lang|iRedAdmin#lang>

=head2 Edit

Method to edit Admin.

=cut

=head3 Arguments

B<email>

Email of Admin

B<name>

Change Display Name of Admin

B<lang>

Change language default of Admin

B<enable>

1 to enable, 0 to disable, without set not change account

=head2 Password

Method to change password of Admin.

=cut 

=head3 Arguments

B<email>

Email of Admin

B<password>

New password of Admin

=head2 Enable

Method to enable Admins.

B<Example>

    $iredadmin->Admin->Enable(
       'foo@domain.com',
       'bar@domain.com',
       'baz@domain.com'
    );

=head2 Disable

Method to disable Admins.

B<Example>

    $iredadmin->Admin->Disable(
       'foo@domain.com',
       'bar@domain.com',
       'baz@domain.com'
    );

=head2 Delete

Method to delete Admins.

B<Example>

    $iredadmin->Admin->Delete(
       'foo@domain.com',
       'bar@domain.com',
       'baz@domain.com'
    );

=head1 AUTHOR

Lucas Tiago de Moraes, C<< <lucastiagodemoraes@gmail.com> >>

=cut

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may have available.

=cut