package Sark::Plugin;

# ABSTRACT: ase class for Sark implementations

use Sark;
use Deeme::Obj -base;
has [qw( name )];
use Log::Log4perl;

1;

__END__

=head1 DESCRIPTION

Sark is written in a technology-agnostic way so that future technologies can be used as drop in replacements. Each implementation will be written as a subclass of C<Sark::Plugin>, and will be invoked by interface methods at the appropriate points during a build.
=cut
