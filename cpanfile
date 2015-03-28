requires "Carp" => "0";
requires "HTML::Entities" => "0";
requires "MRO::Compat" => "0";
requires "Scalar::Util" => "0";
requires "Template::Exception" => "0";
requires "Template::Plugin" => "0";
requires "parent" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "Data::Page" => "0";
  requires "File::Find" => "0";
  requires "File::Temp" => "0";
  requires "Template" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0.94";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Test::CPAN::Changes" => "0.19";
  requires "version" => "0.9901";
};
