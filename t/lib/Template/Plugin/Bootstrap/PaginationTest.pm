package Template::Plugin::Bootstrap::PaginationTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Template;
use Template::Plugin::Bootstrap::Pagination;
use Data::Page;

my $pagination_template_string = <<"EOTEMPLATE";
[%- USE Bootstrap.Pagination -%]
[%- Bootstrap.Pagination.pagination(pager = pager, uri = uri) -%]
EOTEMPLATE

my $pager_template_string = <<"EOTEMPLATE";
[%- USE Bootstrap.Pagination -%]
[%- Bootstrap.Pagination.pager(pager = pager, uri = uri) -%]
EOTEMPLATE

sub pagination_in_template_test : Test(1) {
	my ($self) = @_;

	my $template = Template->new(STRICT => 1);
	my $output;
	my $result = $template->process(\$pagination_template_string, {
		pager => Data::Page->new(42, 10, 2),
		uri   => 'http://www.example.com/blog/__PAGE__.html'
	}, \$output) or die $template->error();

	my $expected = $self->compress_expected(<<EOEXPECTED
<div class="pagination">
	<ul>
		<li><a href="http://www.example.com/blog/1.html">&laquo;</a></li>
		<li><a href="http://www.example.com/blog/1.html">1</a></li>
		<li class="active"><span>2</span></li>
		<li><a href="http://www.example.com/blog/3.html">3</a></li>
		<li><a href="http://www.example.com/blog/4.html">4</a></li>
		<li><a href="http://www.example.com/blog/5.html">5</a></li>
		<li><a href="http://www.example.com/blog/3.html">&raquo;</a></li>
	</ul>
</div>
EOEXPECTED
	);
	is($output, $expected, 'output ok');
}


sub pagination_test : Test(3) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new(undef, {
		pager => Data::Page->new(12, 10, 2),
		uri   => 'http://www.example.com/blog/__PAGE__.html',
		prev_text => 'Previous',
		next_text => 'Next',
	});

	# Basic case
	my $expected = $self->compress_expected(<<EOEXPECTED
<div class="pagination">
	<ul>
		<li><a href="http://www.example.com/blog/1.html">Previous</a></li>
		<li><a href="http://www.example.com/blog/1.html">1</a></li>
		<li class="active"><span>2</span></li>
		<li class="disabled"><span>Next</span></li>
	</ul>
</div>
EOEXPECTED
	);
	is($plugin->pagination(), $expected, 'output ok');

	# Center pagination
	$expected = $self->compress_expected(<<EOEXPECTED
<div class="pagination pagination-centered">
	<ul>
		<li class="disabled"><span>Previous</span></li>
		<li class="disabled"><span>Next</span></li>
	</ul>
</div>
EOEXPECTED
	);
	is($plugin->pagination({
		pager    => Data::Page->new(2, 10, 2),
		centered => 1,
	}), $expected, 'output ok');

	# Right align pagination
	$expected = $self->compress_expected(<<EOEXPECTED
<div class="pagination pagination-right">
	<ul>
		<li class="disabled"><span>Previous</span></li>
		<li class="disabled"><span>Next</span></li>
	</ul>
</div>
EOEXPECTED
	);
	is($plugin->pagination({
		pager => Data::Page->new(2, 10, 2),
		right => 1,
	}), $expected, 'output ok');
}


sub pager_in_template_test : Test(1) {
	my ($self) = @_;

	my $template = Template->new(STRICT => 1);
	my $output;
	my $result = $template->process(\$pager_template_string, {
		pager => Data::Page->new(42, 10, 2),
		uri   => 'http://www.example.com/blog/__PAGE__.html'
	}, \$output) or die $template->error();

	my $expected = $self->compress_expected(<<EOEXPECTED
<ul class="pager">
	<li><a href="http://www.example.com/blog/1.html">&laquo;</a></li>
	<li><a href="http://www.example.com/blog/3.html">&raquo;</a></li>
</ul>
EOEXPECTED
	);
	is($output, $expected, 'output ok');
}


sub pager_test : Test(2) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new(undef, {
		align => 1,
		pager => Data::Page->new(42, 10, 2),
		uri   => 'http://www.example.com/blog/__PAGE__.html',
		prev_text => 'Previous',
		next_text => 'Next',
	});
	my $expected = $self->compress_expected(<<EOEXPECTED
<ul class="pager">
	<li class="previous"><a href="http://www.example.com/blog/1.html">Previous</a></li>
	<li class="next"><a href="http://www.example.com/blog/3.html">Next</a></li>
</ul>
EOEXPECTED
	);
	is($plugin->pager(), $expected, 'output ok');

	$expected = $self->compress_expected(<<EOEXPECTED
<ul class="pager">
	<li class="previous"><a href="http://www.example.com/blog/1.html">foo</a></li>
	<li class="next"><a href="http://www.example.com/blog/3.html">bar</a></li>
</ul>
EOEXPECTED
	);
	is($plugin->pager({
		prev_text => 'foo',
		next_text => 'bar',
	}), $expected, 'output ok');
}


sub pager_item_test : Test(4) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new();

	my $item = $plugin->_pager_item('/1.html', 'foo');
	is($item, '<li><a href="/1.html">foo</a></li>');

	$item = $plugin->_pager_item('/1.html', 'foo', 'previous');
	is($item, '<li class="previous"><a href="/1.html">foo</a></li>');

	$item = $plugin->_pager_item('/1.html', 'foo', 'previous', 'bar');
	is($item, '<li class="previous bar"><a href="/1.html">foo</a></li>');

	$item = $plugin->_pager_item(undef, 'foo', 'previous');
	is($item, '<li class="previous disabled"><span>foo</span></li>');
}


sub prev_next_uri_test : Test(8) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new();
	my @cases = (
		[Data::Page->new(42, 10, 2), 'http://www.example.com/blog/1.html', 'http://www.example.com/blog/3.html'],
		[Data::Page->new(42, 10, 1), undef, 'http://www.example.com/blog/2.html'],
		[Data::Page->new(42, 10, 5), 'http://www.example.com/blog/4.html', undef],
		[Data::Page->new(1, 10, 1), undef, undef],
	);

	for my $case (@cases) {
		my ($prev, $next) = $plugin->_prev_next_uri({
			factor => 1,
			offset => 0,
			pager  => $case->[0],
			uri    => 'http://www.example.com/blog/__PAGE__.html',
		});
		is($prev, $case->[1], 'prev uri ok');
		is($next, $case->[2], 'next uri ok');
	}
}


sub uri_for_page_test : Test(6) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new();
	my @cases = (
		[1, 1, 0, 'http://www.example.com/blog/1.html'],
		[2, 1, 0, 'http://www.example.com/blog/2.html'],
		[1, 1, -1, 'http://www.example.com/blog/0.html'],
		[2, 1, -1, 'http://www.example.com/blog/1.html'],
		[1, 10, -1, 'http://www.example.com/blog/0.html'],
		[2, 10, -1, 'http://www.example.com/blog/10.html'],
	);

	for my $case (@cases) {
		my ($prev, $next) = $plugin->_uri_for_page($case->[0], {
			factor => $case->[1],
			offset => $case->[2],
			uri    => 'http://www.example.com/blog/__PAGE__.html',
		});
		is($prev, $case->[3], 'prev uri ok');
	}
}


sub exceptions_test : Test(4) {
	my ($self) = @_;

	my $plugin = Template::Plugin::Bootstrap::Pagination->new();

	throws_ok(sub {
		$plugin->pager(),
	}, qr{Required 'pager' parameter not passed or not a 'Data::Page' instance}, 'pager required');
	throws_ok(sub {
		$plugin->pagination(),
	}, qr{Required 'pager' parameter not passed or not a 'Data::Page' instance}, 'pager required');

	throws_ok(sub {
		$plugin->pager({
			pager => Data::Page->new(42, 10, 1),
		}),
	}, qr{Required 'uri' parameter not passed}, 'pager required');
	throws_ok(sub {
		$plugin->pagination({
			pager => Data::Page->new(42, 10, 1),
		}),
	}, qr{Required 'uri' parameter not passed}, 'pager required');
}


sub compress_expected {
	my ($self, $expected) = @_;
	$expected =~ s{(?:\n|^\s*)}{}gxms;
	return $expected;
}

1;
