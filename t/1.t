# vim:ft=perl
use Email::MIME::Encodings;
use Test::More 'no_plan';
use_ok("Email::MIME");
open IN, "t/Mail/mail-1" or die $!;
undef $/;
my $string = <IN>;
my $obj = Email::MIME->new($string);
isa_ok($obj, "Email::MIME");
my ($part) = $obj->parts;
isa_ok($part, "Email::MIME");
my $body = $part->body;

is(
  $body,
  Email::MIME::Encodings::decode(base64 => $obj->body_raw),
  "Internally consistent"
);

open(GIF, "t/Mail/att-1.gif") or die $!;
my $gif = <GIF>;
is($body, $gif, "Externally consistent");
is($obj->filename, "1.gif", "Filename is correct");

my $header  = $obj->header('X-MultiHeader');
my @headers = $obj->header('X-MultiHeader');

ok $header, 'got back a header in scalar context';
ok !ref($header), 'header in scalar context is not ref';

is scalar(@headers), 3, 'got all three back in list context';

# This test would be stupider if it hadn't broken in a release.
# There are to many reliances on Email::Simple guts, at this point.
#   -- rjbs, 2006-10-15
eval { $obj->as_string };
ok(!$@, "we can stringify");
