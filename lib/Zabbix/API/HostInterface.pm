package Zabbix::API::HostInterface;

use strict;
use warnings;
use 5.010;
use Carp;

use parent qw/Zabbix::API::CRUDE/;

use constant {
  IF_TYPE_AGENT => 1,
  IF_TYPE_SNMP => 2,
  IF_TYPE_IPMI => 3,
  IF_TYPE_JMX => 4
};

our @EXPORT_OK = qw/
IF_TYPE_AGENT
IF_TYPE_SNMP
IF_TYPE_IPMI
IF_TYPE_JMX
/;

our %EXPORT_TAGS = (
    if_types => [
    qw/
      IF_TYPE_AGENT
      IF_TYPE_SNMP
      IF_TYPE_IPMI
      IF_TYPE_JMX
      /
    ]
);

sub id {

    ## mutator for id

    my ($self, $value) = @_;

    if (defined $value) {

        $self->data->{interfaceid} = $value;
        return $self->data->{interfaceid};

    } else {

        return $self->data->{interfaceid};

    }

}

sub prefix {

    my (undef, $suffix) = @_;

    if ($suffix and $suffix =~ m/ids?/) {

        return 'interface'.$suffix;

    } elsif ($suffix) {

        return 'hostinterface'.$suffix;

    } else {

        return 'hostinterface';

    }

}

sub extension {

    return ( output => 'extend' );

}

sub collides {

    my $self = shift;

    return @{$self->{root}->query(method => $self->prefix('.get'),
                                  params => { hostids => [$self->data->{hostid}], 
                                              filter => { type => $self->data->{type} } ,
                                              $self->extension })};
}

1;
__END__
=pod

=head1 NAME

Zabbix::API::HostInterface -- Zabbix 2.0 host interface objects

=head1 SYNOPSIS

  use Zabbix::API::HostInterface;

  my $interface = $zabbix->fetch('HostInterface', params => 
    { hostids => [42], output => "extend"});
  $interface->{data}->{useip} = 0;
  $interface->push();
  
  $interface->delete();

=head1 DESCRIPTION

Handles CRUD for Zabbix interface objects introduced in version 2.0.

This is a very simple subclass of C<Zabbix::API::CRUDE>.  Only the required
methods are implemented (and in a very simple fashion on top of that). As of
this writing, the documentation for the "hostinterface" API call is incomplete
though it supports ".get", ".create", ".update" and ".delete" the way
other objects do. 

This class should be used for creating new interfaces assigned to a specific host.
Each interface has a unique ID and is associated with a single host ID. To 
create a new interface for a host you would call:

my $if = Zabbix::API::HostInterface->new ( root => $zabbix );
$if->{data} = {
    type => 1,
    main => 1,
    useip => 0,
    ip => "192.168.1.1",
    dns => "host.site.com",
    port => 10050,
    hostid => 42
  };
$if->push();

The types are:
1 = Zabbix agent interface
2 = SNMP
3 = IPMI
4 = JMX

Each type assigned to a host must have one interface assigned as "main". 
The interface where 'main => 1' will be monitored for that check type and others
will be ignored.

When creating a new host, you can provide an array of interface objects such as:

$host->{data}->{interfaces} = [
  {
    type => 1,
    main => 1,
    useip => 0,
    ip => "192.168.1.1",
    dns => "host.site.com",
    port => 10050
  },
  {
    type => 2,
    main => 1,
    useip => 0,
    ip => "192.168.1.1",
    dns => "host.site.com",
    port => 161
  }
];
# set other host fields here
$host->push();

WARNING ---------------
If you fetch a host with interface data (by setting 'selectInterfaces => "extend"'), then
add, delete or modify an interface, then push() the host data, you will lose any interface
changes you may have made. If you update interface data via the host object, make sure to
push, then pull again before adding a new interface.

=head1 SEE ALSO

L<Zabbix::API::CRUDE>.

=head1 AUTHOR

Chris Larsen <clarsen@llnw.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 SFR

This library is free software; you can redistribute it and/or modify it under
the terms of the GPLv3.

=cut
