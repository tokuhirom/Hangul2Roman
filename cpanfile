requires('Amon2'                           => '3.66');
requires('Amon2::Lite'                     => '0.09');
requires('Text::Xslate'                    => '1.5006');
requires('Plack::Session'                  => '0.14');
requires('Lingua::KO::Romanize::Hangul'    => 0);
requires('JSON' => 2);

# current version of Module::CPANfile does not supports 'osname'
if ($^O eq 'darwin') {
    requires('Mac::FSEvents');
}

