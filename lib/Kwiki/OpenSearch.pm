package Kwiki::OpenSearch;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';

use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';

our $VERSION = '0.01';

const class_id    => 'opensearch';
const class_title => 'A9 OpenSearch';
const css_file    => 'opensearch.css';

field error => '';

sub register {
    my $registry = shift;
    $registry->add( wafl => "opensearch"  => 'Kwiki::OpenSearch::Wafl' );
}

sub do_search {
    my $url   = shift;
    my $query = shift;

    eval {
	require WWW::OpenSearch;
	my $opensearch = WWW::OpenSearch->new($url);
	my $feed = $opensearch->search($query);
	return $opensearch, $feed;
    };
    $self->error($@) if $@;
}

package Kwiki::OpenSearch::Wafl;
use Spoon::Formatter ();
use base 'Spoon::Formatter::WaflPhrase';

sub html {
    my $args = $self->arguments;
    my $key  = $self->method;
    my($url, $query) = split /\s+/, $args, 2;
    my($engine, $feed) = $self->hub->opensearch->do_search($url, $query);

    my $error = $self->hub->opensearch->error || '';
    $self->hub->template->process(
	'opensearch.html',
	engine => $engine,
	feed => $feed,
	query => $query,
        error => $error,
    );
}

package Kwiki::OpenSearch;

1;
__DATA__

=head1 NAME

Kwiki::OpenSearch - OpenSearch plugin for Kwiki

=head1 SYNOPSIS

  use Kwiki::OpenSearch;
  # I don't know how to use it. But it should work.

=head1 BUGS

It's not tested as I don't have a testable Kwiki instance.

=head1 DESCRIPTION

Kwiki::OpenSearch is a plugin to search A9's OpenSearch compatible search engines from inside Kwiki using Wafl.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This module was written during Ingy's Kwiki talk at YAPC::Taipei 2005.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Kwiki::Yahoo>

=cut

__template/tt2/opensearch.html__
<!-- BEGIN opensearch.html -->
<div class="opensearchResults">
<div class="opensearchTitlebox">
[% IF error %]
Error: [% error %]
[% END %]
[% engine.LongName %] search for [% query %]
</div>

[% FOREACH item = feed.items %]
<div class="opensearchItem">
<div class="opensearchItemTitle">
<a href="[% item.link %]">[% item.title | html %]</a></div>
<div class="opensearchItemDescription">
[% item.description | html %]</div>
</div>
[% END %]
</div>
<!-- END opensearch.html -->
__css/opensearch.css__
/* I'm lazy. Edit as you like! */
.opensearchResults { }
.opensearchTitlebox { }
.opensearchItem { }
.opensearchItemTitle { }
.opensearchItemDescription { }

