package Mac::FSEvents;

use 5.008008;
use strict;
use base 'Exporter';

use Mac::FSEvents::Event;

our $VERSION = '0.09';

our @EXPORT_OK   = qw(NONE WATCH_ROOT);
our %EXPORT_TAGS = ( flags => \@EXPORT_OK );

my @maybe_export_ok = qw(IGNORE_SELF FILE_EVENTS);

require XSLoader;
XSLoader::load('Mac::FSEvents', $VERSION);

# generate subs for each constant
foreach my $constant ( @EXPORT_OK ) {
    my ( undef, $value ) = constant($constant);

    no strict 'refs';
    *$constant = sub {
        return $value;
    };
}

# check that these flags are defined
foreach my $constant ( @maybe_export_ok ) {
    my ( undef, $value ) = constant($constant);

    if ( defined($value) ) {
        no strict 'refs';
        *$constant = sub {
            return $value;
        };
        push @EXPORT_OK, $constant;
    }
}

sub DESTROY {
    my $self = shift;
    
    # Make sure thread has stopped
    $self->stop;
    
    # C cleanup
    $self->_DESTROY();
}

1;
__END__

=head1 NAME

Mac::FSEvents - Monitor a directory structure for changes

=head1 SYNOPSIS

  use Mac::FSEvents;
  # or use Mac::FSEvents qw(:flags);

  my $fs = Mac::FSEvents->new( {
      path    => '/',       # required, the path to watch
      latency => 2.0,       # optional, time to delay before returning events
      since   => 451349510, # optional, return events from this eventId
      flags   => NONE,      # optional, set stream creation flags
  } );

  my $fh = $fs->watch;

  # Select on this filehandle, or use an event loop:
  my $sel = IO::Select->new($fh);
  while ( $sel->can_read ) {
      my @events = $fs->read_events;
      for my $event ( @events ) {
          printf "Directory %s changed\n", $event->path;
      }
  }

  # or use blocking polling:
  while ( my @events = $fs->read_events ) {
      ...
  }

  # stop watching
  $fs->stop;

=head1 DESCRIPTION

This module implements the FSEvents API present in Mac OSX 10.5 and later.
It enables you to watch a large directory tree and receive events when any
changes are made to directories or files within the tree.

Event monitoring occurs in a separate C thread from the rest of your application.

=head1 METHODS

=over 4

=item B<new> ( { ARGUMENTS } )

Create a new watcher.  A hash reference containing arguments is required:

=over 8

=item path

Required.  The full path to the directory to watch.  All subdirectories beneath
this directory are watched.

=item latency

Optional.  The number of seconds the FSEvents service should wait after hearing
about an event from the kernel before passing it along.  Specifying a larger value
may result in fewer callbacks and greater efficiency on a busy filesystem.  Fractional
seconds are allowed.

Default: 2.0

=item since

Optional.  A previously obtained event ID may be passed as the since argument.  A
notification will be sent for every event that has happened since that ID.  This can
be useful for seeing what has changed while your program was not running.

=item flags

Optional.  Sets the flags provided to L<FSEventStreamCreate>.  In order to
import the flag constants, you must provide C<:flags> to C<use Mac::FSEvents>.
The following flags are supported:

=over 8

=item NONE

=item WATCH_ROOT

=item IGNORE_SELF (Only available on OS X 10.6 or greater)

=item FILE_EVENTS (Only available on OS X 10.7 or greater)

=back

Consult the FSEvents documentation for what these flags do.

Default: NONE

=back

=item B<watch>

Begin watching.  Returns a filehandle that may be used with select() or the event loop
of your choice.

=item B<read_events>

Returns an array of pending events.  If using an event loop, this method should be
called when the filehandle becomes ready for reading.  If not using an event loop,
this method will block until an event is available.

Events are returned as L<Mac::FSEvents::Event> objects.

=item B<stop>

Stop watching.

=back

=head1 SEE ALSO

http://developer.apple.com/documentation/Darwin/Conceptual/FSEvents_ProgGuide

=head1 AUTHOR

Andy Grundman, E<lt>andy@hybridized.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Andy Grundman

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
