requires 'feature';
requires 'Deeme';
requires 'Locale::TextDomain';
requires 'Locale::Messages';

requires 'perl', '5.008_005';

on configure => sub {
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::More';
};
