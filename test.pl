package Foo;

use Gtk;
use POE;
use POE::Session::GladeXML;


sub on_delete {
   print "exiting\n";
}

sub on_button1_clicked {
   print "click\n";
}
sub new {
   my ($class) = @_;

   my $self = {};
   bless $self, $class;
   my $s = POE::Session::GladeXML->create (
	       glade_object => $self,
	       glade_file => 'test.glade',
	    );
   $self->{'session'} = $s;
   return $self;
}

package main;

Gtk::GladeXML->gnome_init;
my $foo = Foo->new;
POE::Kernel->run;
