use inc::Module::Install;
  
# Define metadata
name           'Net-GitHub-Markdown';
all_from       'lib/Net/GitHub/Markdown.pm';
license        'bsd';

# Specific dependencies
requires       'WWW::Mechanize';
requires       'HTML::TreeBuilder';

test_requires  'Test::More' => '0.42';

WriteAll;
