# $Id: RobotUA.pm,v 1.1 2003/05/01 14:13:49 aa Exp $

package LWP::RobotUA;

require LWP::UserAgent;
@ISA = qw(LWP::UserAgent);
$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

require WWW::RobotRules;
require HTTP::Request;
require HTTP::Response;

use Carp ();
use LWP::Debug ();
use HTTP::Status ();
use HTTP::Date qw(time2str);
use strict;

=head1 NAME

LWP::RobotUA - a class for well-behaved Web robots

=head1 SYNOPSIS

  use LWP::RobotUA;
  my $ua = LWP::RobotUA->new( 'my-robot/0.1', 'me@foo.com' );
  $ua->delay(10);  # be very nice -- max one hit every ten minutes!
  ...

  # Then just use it just like a normal LWP::UserAgent:
  my $response = $ua->get('http://whatever.int/...');
  ...

=head1 DESCRIPTION

This class implements a user agent that is suitable for robot
applications.  Robots should be nice to the servers they visit.  They
should consult the F</robots.txt> file to ensure that they are welcomed
and they should not make requests too frequently.

But before you consider writing a robot, take a look at
<URL:http://www.robotstxt.org/>.

When you use a I<LWP::RobotUA> object as your user agent, then you do not
really have to think about these things yourself; C<robots.txt> files
are automatically consulted and obeyed, the server isn't queried
too rapidly, and so on.  Just send requests
as you do when you are using a normal I<LWP::UserAgent>
object (using C<< $ua->get(...) >>, C<< $ua->head(...) >>,
C<< $ua->request(...) >>, etc.), and this
special agent will make sure you are nice.

=head1 METHODS

The LWP::RobotUA is a sub-class of LWP::UserAgent and implements the
same methods. In addition the following methods are provided:

=over 4

=cut


#
# Additional attributes in addition to those found in LWP::UserAgent:
#
# $self->{'delay'}    Required delay between request to the same
#                     server in minutes.
#
# $self->{'rules'}     A WWW::RobotRules object
#


=item $ua = LWP::RobotUA->new($agent_name, $from, [$rules])

Your robot's name and the mail address of the human responsible for
the robot (i.e. you) are required by the constructor.

Optionally it allows you to specify the I<WWW::RobotRules> object to
use.  If you don't provide one, then this user agent will make its own
internal database of F<robots.txt> rules as needed.

=cut

sub new
{
    my($class,$name,$from,$rules) = @_;

    Carp::croak('LWP::RobotUA name required') unless $name;
    Carp::croak('LWP::RobotUA from address required') unless $from
     and $from =~ m/\@/;

    my $self = new LWP::UserAgent;
    $self = bless $self, $class;

    $self->{'delay'} = 1;   # minutes
    $self->{'agent'} = $name;
    $self->{'from'}  = $from;
    $self->{'use_sleep'} = 1;

    if ($rules) {
	$rules->agent($name);
	$self->{'rules'} = $rules;
    } else {
	$self->{'rules'} = new WWW::RobotRules $name;
    }

    $self;
}


=item $ua->delay([$minutes])

Set the minimum delay between requests to the same server,
in I<minutes>.  The
default is 1 minute.  Note that this number doesn't have to be an integer;
for example, this sets the delay to 10 seconds:

    $ua->delay(10/60);

=item $ua->use_sleep([$boolean])

Get/set a value indicating whether the UA should sleep() if requests
arrive too fast (before $ua->delay minutes has passed).  The default is
TRUE.  If this value is FALSE then an internal SERVICE_UNAVAILABLE
response will be generated.  It will have an Retry-After header that
indicates when it is OK to send another request to this server.

=cut

sub delay     { shift->_elem('delay',     @_); }
sub use_sleep { shift->_elem('use_sleep', @_); }

sub agent
{
    my $self = shift;
    my $old = $self->SUPER::agent(@_);
    if (@_) {
	# Changing our name means to start fresh
	$self->{'rules'}->agent($self->{'agent'}); 
    }
    $old;
}


=item $ua->rules([$rules])

Set/get which I<WWW::RobotRules> object to use. 

=cut

sub rules {
    my $self = shift;
    my $old = $self->_elem('rules', @_);
    $self->{'rules'}->agent($self->{'agent'}) if @_;
    $old;
}

=item $ua->no_visits($netloc)

Returns the number of documents fetched from this server host. Yes I
know, this method should probably have been named num_visits() or
something like that. :-(

=cut

sub no_visits
{
    my($self, $netloc) = @_;
    $self->{'rules'}->no_visits($netloc) || 0;
}

*host_count = \&no_visits;  # backwards compatibility with LWP-5.02


=item $ua->host_wait($netloc)

Returns the number of I<seconds> (from now) you must wait before you can
make a new request to this host.

=cut

sub host_wait
{
    my($self, $netloc) = @_;
    return undef unless defined $netloc;
    my $last = $self->{'rules'}->last_visit($netloc);
    if ($last) {
	my $wait = int($self->{'delay'} * 60 - (time - $last));
	$wait = 0 if $wait < 0;
	return $wait;
    }
    return 0;
}


sub simple_request
{
    my($self, $request, $arg, $size) = @_;

    LWP::Debug::trace('()');

    # Do we try to access a new server?
    my $allowed = $self->{'rules'}->allowed($request->url);

    if ($allowed < 0) {
	LWP::Debug::debug("Host is not visited before, or robots.txt expired.");
	# fetch "robots.txt"
	my $robot_url = $request->url->clone;
	$robot_url->path("robots.txt");
	$robot_url->query(undef);
	LWP::Debug::debug("Requesting $robot_url");

	# make access to robot.txt legal since this will be a recursive call
	$self->{'rules'}->parse($robot_url, ""); 

	my $robot_req = new HTTP::Request 'GET', $robot_url;
	my $robot_res = $self->request($robot_req);
	my $fresh_until = $robot_res->fresh_until;
	if ($robot_res->is_success) {
	    my $c = $robot_res->content;
	    if ($robot_res->content_type =~ m,^text/, && $c =~ /Disallow/) {
		LWP::Debug::debug("Parsing robot rules");
		$self->{'rules'}->parse($robot_url, $c, $fresh_until);
	    }
	    else {
		LWP::Debug::debug("Ignoring robots.txt");
		$self->{'rules'}->parse($robot_url, "", $fresh_until);
	    }

	} else {
	    LWP::Debug::debug("No robots.txt file found");
	    $self->{'rules'}->parse($robot_url, "", $fresh_until);
	}

	# recalculate allowed...
	$allowed = $self->{'rules'}->allowed($request->url);
    }

    # Check rules
    unless ($allowed) {
	my $res = new HTTP::Response
	  &HTTP::Status::RC_FORBIDDEN, 'Forbidden by robots.txt';
	$res->request( $request ); # bind it to that request
	return $res;
    }

    my $netloc = eval { local $SIG{__DIE__}; $request->url->host_port; };
    my $wait = $self->host_wait($netloc);

    if ($wait) {
	LWP::Debug::debug("Must wait $wait seconds");
	if ($self->{'use_sleep'}) {
	    sleep($wait)
	} else {
	    my $res = new HTTP::Response
	      &HTTP::Status::RC_SERVICE_UNAVAILABLE, 'Please, slow down';
	    $res->header('Retry-After', time2str(time + $wait));
	    $res->request( $request ); # bind it to that request
	    return $res;
	}
    }

    # Perform the request
    my $res = $self->SUPER::simple_request($request, $arg, $size);

    $self->{'rules'}->visit($netloc);

    $res;
}


=item $ua->as_string

Returns a string that describes the state of the UA.
Mainly useful for debugging.

=cut

sub as_string
{
    my $self = shift;
    my @s;
    push(@s, "Robot: $self->{'agent'} operated by $self->{'from'}  [$self]");
    push(@s, "    Minimum delay: " . int($self->{'delay'}*60) . "s");
    push(@s, "    Will sleep if too early") if $self->{'use_sleep'};
    push(@s, "    Rules = $self->{'rules'}");
    join("\n", @s, '');
}

1;

=back

=head1 SEE ALSO

L<LWP::UserAgent>, L<WWW::RobotRules>

=head1 COPYRIGHT

Copyright 1996-2002 Gisle Aas.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
