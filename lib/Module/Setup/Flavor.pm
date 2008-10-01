package Module::Setup::Flavor;
use strict;
use warnings;

use Carp ();
use YAML ();

sub load_data {
    my $class = shift;

    local $/;
    my $data = eval "package $class; <DATA>";
    Carp::croak "flavor template class is invalid: $class" unless $data;

    my @template = YAML::Load(join '', $data);
    @template;
}

sub merge_template {
    my($class, $base_class) = @_;

    eval "require $base_class";
    Carp::croak $@ if $@;

    my @base_template  = $base_class->load_data;
    my @local_template = load_data($class);

    my %template_index;
    for my $tmpl (@local_template) {
        $template_index{$tmpl->{file}} = $tmpl;
    }

    my @template;
    for my $tmpl (@base_template) {
        push @template, ($template_index{$tmpl->{file}} || $tmpl);
    }
    @template;
}

1;
