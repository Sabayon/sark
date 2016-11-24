package Sark::Engine;
# ABSTRACT: ase class for Sark implementations

use Sark;
use Deeme::Obj -base;
has [qw( name )];

=method prepare

The C<prepare> method is called before the build is started and should be used to acquire any resources necessary to run the build, for example container disk images.

This method should also be used to clear any caches if a clean build is requested.

=cut
sub prepare {
    my $sark = Sark->new();
    $sark->warning("Prepare method not implemented by engine");
}

=method pre_clean()

The C<pre-clean> method is called to do any necessary cleanup before the compile phase begins, such as removing unwanted packages

=cut
sub pre_clean {
    my $sark = Sark->new();
    $sark->warning("Pre_clean method not implemented by engine");
}

=method compile()

The C<compile> method is called to build the package artifacts, using e.g. portage.

This method requires that all new packages are cached in the repository artifacts directory, and must leave the local copy of the repository in a state ready for publishing when it completes.

=cut
sub compile {
    my $sark = Sark->new();
    $sark->warning("Compile method not implemented by engine");
}

=method publish()

The C<publish> method is called to update the repository with new packages.

=cut
sub publish {
    my $sark = Sark->new();
    $sark->warning("Publish method not implemented by engine");
}

=method post_clean()

This C<post-clean> method is called after the publish phase and can be used to do any necessary cleanup, such as removing old package versions.

=cut
sub post_clean {
    my $sark = Sark->new();
    $sark->warning("Post_clean method not implemented by engine");
}


1;

__END__

=head1 DESCRIPTION

Sark is written in a technology-agnostic way so that future technologies can be used as drop in replacements. Each implementation will be written as a subclass of C<Sark::Engine>, and will be invoked by interface methods at the appropriate points during a build.

The build process is split out in separate methods which can be called independently inside different environments, and to aid with development, testing and troubleshooting. These are listed below, and typically called sequentially during a fully automated build, but can be called manually if required.

=cut
