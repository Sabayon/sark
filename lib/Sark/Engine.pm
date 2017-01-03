package Sark::Engine;

# ABSTRACT: ase class for Sark implementations

use Sark;
use Deeme::Obj 'Sark::Plugin';
has [qw( interface )];

=method register

The C<register> method binds building events emitted by Sark::Build to specific methods of the loaded Engine.

=cut

sub register {
    my ( $self, $sark ) = @_;

    $sark->emit( join( ".", "engine", $self->name, "register" ) );
    $sark->on(
        "build.prepare" => sub {

# First make sure engine has been explictly selected inside the build configuration.
# This avoids that all loaded engines are enabled for all builds(allowing parallel execution)
            return
                unless ( $_[1]->has_engine( $self->name ) )
                ;    #$_[1] is the Sark::Build in this case

            my $class = shift;
            $sark->emit(
                join( ".", "engine", $self->name, "build", "prepare" ),
                $self, @_ );
            $self->prepare(@_);

        }
    );
    $sark->on(
        "build.pre_clean" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );

            my $class = shift;
            $sark->emit(
                join( ".", "engine", $self->name, "build", "pre_clean" ),
                $self, @_ );
            $self->pre_clean(@_);
        }
    );
    $sark->on(
        "build.compile" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );
            my $class = shift;

            $sark->emit(
                join( ".", "engine", $self->name, "build", "compile" ),
                $self, @_ );
            $self->compile(@_);
        }
    );
    $sark->on(
        "build.start" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );
            my $class = shift;

            $sark->emit( join( ".", "engine", $self->name, "build", "start" ),
                $self, @_ );
            $self->start(@_);
        }
    );
    $sark->on(
        "build.failed" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );
            my $class = shift;

            $sark->emit(
                join( ".", "engine", $self->name, "build", "failed" ),
                $self, @_ );
            $self->failed(@_) unless !$self->can("failed");
        }
    );
    $sark->on(
        "build.publish" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );
            my $class = shift;
            $sark->emit(
                join( ".", "engine", $self->name, "build", "publish" ),
                $self, @_ );
            $self->publish(@_);
        }
    );
    $sark->on(
        "build.post_clean" => sub {
            return unless ( $_[1]->has_engine( $self->name ) );
            my $class = shift;

            $sark->emit(
                join( ".", "engine", $self->name, "build", "post_clean" ),
                $self, @_ );
            $self->post_clean(@_);
        }
    );
}

=method prepare

The C<prepare> method is called before the build is started and should be used to acquire any resources necessary to run the build, for example container disk images.

This method should also be used to clear any caches if a clean build is requested.

=cut

sub prepare {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Prepare method not implemented by engine");
}

=method pre_clean()

The C<pre-clean> method is called to do any necessary cleanup before the compile phase begins, such as removing unwanted packages

=cut

sub pre_clean {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Pre_clean method not implemented by engine");
}

=method compile()

The C<compile> method is called to build the package artifacts, using e.g. portage.

This method requires that all new packages are cached in the repository artifacts directory, and must leave the local copy of the repository in a state ready for publishing when it completes.

=cut

sub compile {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Compile method not implemented by engine");
}

=method start()

The C<start> method is called to start the building process, using e.g. docker.

=cut

sub start {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Start method not implemented by engine");
}

=method publish()

The C<publish> method is called to update the repository with new packages.

=cut

sub publish {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Publish method not implemented by engine");
}

=method post_clean()

This C<post-clean> method is called after the publish phase and can be used to do any necessary cleanup, such as removing old package versions.

=cut

sub post_clean {
    my $sark   = Sark->new();
    my $logger = Log::Log4perl->get_logger('Sark::Engine');
    $logger->warn("Post_clean method not implemented by engine");
}

1;

__END__

=head1 DESCRIPTION

Sark is written in a technology-agnostic way so that future technologies can be used as drop in replacements. Each implementation will be written as a subclass of C<Sark::Engine>, and will be invoked by interface methods at the appropriate points during a build.

The build process is split out in separate methods which can be called independently inside different environments, and to aid with development, testing and troubleshooting. These are listed below, and typically called sequentially during a fully automated build, but can be called manually if required.

=cut
