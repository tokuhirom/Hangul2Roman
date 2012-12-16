use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use Lingua::KO::Romanize::Hangul;

our $VERSION = '0.01';

sub load_config {
    +{ }
}

get '/' => sub {
    my $c = shift;
    return $c->render('index.tt');
};

get '/hangul2katakana' => sub {
    my $c = shift;
    my $src = $c->req->param('src');
    my $conv = Lingua::KO::Romanize::Hangul->new();
    return $c->render_json( { result => [ $conv->string($src) ] } );
};

# load plugins
__PACKAGE__->load_plugin('Web::JSON');

__PACKAGE__->to_app(handle_static => 1);

__DATA__

@@ index.tt
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Romanize Hangul</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
    <script type="text/javascript" src="[% uri_for('/static/js/main.js') %]"></script>
    <link rel="stylesheet" href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css">
    <link rel="stylesheet" href="[% uri_for('/static/css/main.css') %]">
</head>
<body>
    <div class="container">
        <header><h1>Romanize Hangul</h1></header>
        <div class="row">
            <div class="span6"><textarea id="src"></textarea></div>
            <div class="span6" id="dst"></div>
        </div>
    </div>
</body>
</html>

@@ /static/js/main.js
$(function () {
    $('#src').keyup(function () {
        var src = $(this).val();
        $.ajax({
            url: '/hangul2katakana',
            data: { src: src }
        }).success(function (d) {
            var dst = $('#dst').empty();
            $.each(d.result, function (i, e) {
                if (e.length == 2) {
                    var ruby = $('<ruby>');
                    ruby.append(
                        $('<rb>').text(e[0]),
                        $('<rt>').text(e[1])
                    );
                    dst.append(ruby);
                } else {
                    dst.append($('<span>').text(e[0]));
                }
                console.log(e);
            });
        }).error(function () {
            alert('error');
        });
    });
});

@@ /static/css/main.css
footer {
    text-align: right;
}

#src {
    min-height: 300px;
}
#dst {
    min-height: 300px;
}
