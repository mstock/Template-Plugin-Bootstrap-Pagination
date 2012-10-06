package Template::Plugin::Bootstrap::Pagination;
use parent qw(Template::Plugin);

# ABSTRACT: Produce HTML suitable for the Bootstrap pagination component

use strict;
use warnings;

use Carp;
use MRO::Compat;
use HTML::Entities;
use Scalar::Util qw(blessed);


sub new {
	my ($class, $context, $arg_ref) = @_;

	my $self = $class->next::method($context, $arg_ref);

	if (defined $arg_ref && ref $arg_ref ne 'HASH') {
		croak('Hash reference required');
	}
	$arg_ref ||= {};
	$self->{default} = {
		prev_text => '&laquo;',
		next_text => '&raquo;',
		centered  => 1,
		right     => 0,
		siblings  => 3,
		offset    => 0,
		factor    => 1,
		%{$arg_ref},
	};

	return $self;
}


sub pagination {
	my ($self, $arg_ref) = @_;

	$arg_ref = {
		%{$self->{default}},
		%{$arg_ref || {}},
	};

	my $pager = $arg_ref->{pager};
	unless (blessed $pager && $pager->isa('Data::Page')) {
		croak("Required 'pager' parameter not passed or not a 'Data::Page' instance");
	}

	my ($prev_uri, $next_uri) = $self->_prev_next_uri($arg_ref);
	my $prev_page = $prev_uri
		? '<li><a href="'.$prev_uri.'">'.$arg_ref->{prev_text}.'</a></li>'
		: '<li class="disabled"><span>'.$arg_ref->{prev_text}.'</span></li>';
	my $next_page = $next_uri
		? '<li><a href="'.$next_uri.'">'.$arg_ref->{next_text}.'</a></li>'
		: '<li class="disabled"><span>'.$arg_ref->{next_text}.'</span></li>';

	my $pagination = '';
	if ($pager->total_entries() > $pager->entries_per_page()) {
		for my $page ($pager->first_page() .. $pager->last_page()) {
			if ($pager->current_page == $page) {
				$pagination .= '<li class="active">'
					. '<span>'.$page.'</span>'
				. '</li>';
			}
			else {
				if ($page == $pager->first_page() || $page == $pager->last_page()
						|| abs($page - $pager->current_page()) <= ($arg_ref->{siblings})
							|| $pager->last_page() <= (2 * $arg_ref->{siblings} + 1)) {
					$pagination .= '<li>'
						. '<a href="'.$self->_uri_for_page($page, $arg_ref).'">'.$page.'</a>'
					. '</li>';
				}
				elsif ($pager->first_page() + 1 == $page || $pager->last_page() - 1 == $page) {
					$pagination .= '<li class="disabled">'
						. '<span>&hellip;</span>'
					. '</li>';
				}
			}
		}
	}

	my $alignment = $arg_ref->{centered}
		? ' pagination-centered'
		: ($arg_ref->{right} ? ' pagination-right' : '');
	return '<div class="pagination'.$alignment.'">'
		. '<ul>'
			. $prev_page
			. $pagination
			. $next_page
		. '</ul>'
	. '</div>';
}


sub _prev_next_uri {
	my ($self, $arg_ref) = @_;

	my $pager = $arg_ref->{pager};
	return map {
		$_ ? $self->_uri_for_page($_, $arg_ref) : undef;
	} ($pager->previous_page(), $pager->next_page());
}


sub _uri_for_page {
	my ($self, $page, $arg_ref) = @_;

	my $uri = $arg_ref->{uri};
	unless (defined $uri && $uri ne '') {
		croak("Required 'uri' parameter not passed");
	}
	$uri =~ s/__PAGE__/( $page + $arg_ref->{offset} ) * $arg_ref->{factor}/eg;
	return encode_entities($uri);
}


1;
