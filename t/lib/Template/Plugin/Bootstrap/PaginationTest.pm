package Template::Plugin::Bootstrap::PaginationTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Test::More;
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


sub compress_expected {
	my ($self, $expected) = @_;
	$expected =~ s{(?:\n|^\s*)}{}gxms;
	return $expected;
}

1;
