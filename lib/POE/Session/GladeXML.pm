package POE::Session::GladeXML;
use strict;
use warnings;


#TODO - this should be in POE::Session
sub SE_DATA () { 3 }

our $VERSION = '0.1.3';
use base qw(POE::Session);
=head1 NAME

POE::Session::GladeXML -- emit POE events for Gtk callbacks

=head1 SYNOPSIS

   package test;

   use POE::Session::GladeXML;

   sub on_button1_clicked {
      print STDERR "button clicked\n";
   }

   sub new {
      [... object creation ...]
      my $session = POE::Session::GladeXML->create (
	  glade_object => $self,
	  glade_file => 'test.glade',
	  [... POE Session params ...]
	);

      return $self;
   }

   Gtk::GladeXML->init;
   my $foo = test->new;
   $poe_kernel->run();

=head1 DESCRIPTION

A simple helper module that lets you connect callback names from
your .glade file with methods of an object. These methods are called
as POE postback methods.

=cut

use Carp;
use Gtk;
use POE;
use Gtk::GladeXML;

sub _session_autoconnect_helper {
  my ($handler_name, $object, $signal_name, $signal_data, 
      $connect_object, $after, $myobject) = @_;

  $poe_kernel->state ($handler_name, $myobject);
  my $session = $poe_kernel->get_active_session;
  my $handler = $session->postback ($handler_name);

  if ($connect_object) {
    my ($func) = $after? "signal_connect_object_after" : "signal_connect_object";
    $object->$func ($signal_name, $connect_object, $handler, $signal_data);
  } else {
    my ($func) = $after? "signal_connect_after" : "signal_connect";
    $object->$func ($signal_name, $handler, $signal_data);
  }
}

=head1 FUNCTIONS

=head2 create (OBJECT, [STATES], @GLADEXML_ARGUMENTS)

creates a POE::Session that connects the callbacks named in the STATES
list to the corresponding method of OBJECT. @GLADEXML_ARGUMENTS is
the list of arguments passed to C<Gtk::GladeXML>->new. Usually this is
just the filename of the .glade file to use. See C<Gtk::GladeXML> for
more information.

=cut

sub create {
  my ($class, %args) = @_;

  my $object = delete $args{'glade_object'};
  my $file = delete $args{'glade_file'};
  my $args = delete $args{'glade_args'};
  $args ||= [];
  #TODO: check for _start elsewhere
  if (defined $args{'inline_states'}) {
    if (defined $args{'inline_states'}->{'_start'}) {
      croak "a _start state is already defined by ", __PACKAGE__;
    }
    $args{'inline_states'}->{'_start'} = \&_start;
  } else {
    $args{'inline_states'} = {_start => \&_start};
  }

  if (defined $args{'args'}) {
    unshift (@{$args{'args'}}, $object, $file, @$args);
  } else {
    $args{'args'} = [$object, $file, @$args];
  }
  my $self = $class->SUPER::create (%args);

  $self->[SE_DATA] = () unless defined ($self->[SE_DATA]);
  return $self;
}

sub _start {
  my ($self, $object, $file, @args) = @_[SESSION, ARG0..$#_];

  my $t = Gtk::GladeXML->new ($file, @args);
  croak "Couldn't create Gtk::GladeXML" unless (defined $t);

  $self->[SE_DATA]->{__PACKAGE__} = $t;
  $t->signal_autoconnect_full (\&_session_autoconnect_helper, $object);
}

=head2 gladexml ()

Returns the Gtk::GladeXML object.

=cut

sub gladexml {
  my ($self) = @_;

  return $self->[SE_DATA]->{__PACKAGE__}
}

=head1 SEE ALSO

C<POE::Session> and C<Gtk::GladeXML>

=head1 COPYRIGHT

This module is Copyright 2002-2003 Martijn van Beers. It is free
software; you may reproduce and/or modify it under the terms of
the GPL licence v2.0. See the file COPYING in the source tarball
for more information

=cut

1;
