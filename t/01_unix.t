use v6;
use lib 'lib';
use Test;
use File::Spec;
use File::Spec::Unix;

plan 109;

my $Unix := File::Spec::Unix;

my %canonpath = (
	'///../../..//./././a//b/.././c/././' => '/a/b/../c',
	'a/../../b/c'                         => 'a/../../b/c',
	'/.'                                  => '/',
	'/./'                                 => '/',
	'/a/./'                               => '/a',
	'/a/.'                                => '/a',
	'/../../'                             => '/',
	'/../..'                              => '/',
	'/..'                                 => '/',
);
for %canonpath.kv -> $get, $want {
	is $Unix.canonpath( $get ), $want, "canonpath: '$get' -> '$want'";
}
is $Unix.canonpath(''), '', "canonpath: empty string";

is $Unix.catdir( ),                      '',          "catdir: no arg -> ''";
is $Unix.catdir( '' ),                   '/',         "catdir: '' -> '/'";
is $Unix.catdir( '/' ),                  '/',         "catdir: '/' -> '/'";
is $Unix.catdir( '','d1','d2','d3','' ), '/d1/d2/d3', "catdir: ('','d1','d2','d3','') -> '/d1/d2/d3'";
is $Unix.catdir( 'd1','d2','d3','' ),    'd1/d2/d3',  "catdir: ('d1','d2','d3','') -> 'd1/d2/d3'";
is $Unix.catdir( '','d1','d2','d3' ),    '/d1/d2/d3', "catdir: ('','d1','d2','d3') -> '/d1/d2/d3'";
is $Unix.catdir( 'd1','d2','d3' ),       'd1/d2/d3',  "catdir: ('d1','d2','d3') -> 'd1/d2/d3'";
is $Unix.catdir( '/','d2/d3' ),          '/d2/d3',    "catdir: ('/','d2/d3') -> '/d2/d3'";

is $Unix.catfile('a','b','c'),   'a/b/c', "catfile: ('a','b','c') -> 'a/b/c'";
is $Unix.catfile('a','b','./c'), 'a/b/c', "catfile: ('a','b','./c') -> 'a/b/c'";
is $Unix.catfile('./a','b','c'), 'a/b/c', "catfile: ('./a','b','c') -> 'a/b/c'";
is $Unix.catfile('c'),           'c',     "catfile: 'c' -> 'c'";
is $Unix.catfile('./c'),         'c',     "catfile: './c' -> 'c'";

is $Unix.curdir,  '.',         'curdir is "."';
is $Unix.devnull, '/dev/null', 'devnull is /dev/null';
is $Unix.rootdir, '/',         'rootdir is "/"';

is $Unix.updir,   '..',        'updir is ".."';

isnt '.',    $Unix.no-parent-or-current-test,   "no-parent-or-current-test: '.'";
isnt '..',   $Unix.no-parent-or-current-test,   "no-parent-or-current-test: '..'";
is   '.git', $Unix.no-parent-or-current-test,   "no-parent-or-current-test: '.git'";
is   'file', $Unix.no-parent-or-current-test,   "no-parent-or-current-test: 'file'";

ok  $Unix.file-name-is-absolute( '/abcd' ), 'file-name-is-absolute: ok "/abcd"';
nok $Unix.file-name-is-absolute( 'abcd' ),  'file-name-is-absolute: nok "abcd"';

my $path = %*ENV{'PATH'};
%*ENV{'PATH'} = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:';
my @want         = </usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games .>;
is_deeply $Unix.path, @want, 'path';
%*ENV{'PATH'} = $path;

my %splitpath = (
	'file'            => ('', '',             'file'),
	'/d1/d2/d3/'      => ('', '/d1/d2/d3/',   ''),
	'd1/d2/d3/'       => ('', 'd1/d2/d3/',    ''),
	'/d1/d2/d3/.'     => ('', '/d1/d2/d3/.',  ''),
	'/d1/d2/d3/..'    => ('', '/d1/d2/d3/..', ''),
	'/d1/d2/d3/.file' => ('', '/d1/d2/d3/',   '.file'),
	'd1/d2/d3/file'   => ('', 'd1/d2/d3/',    'file'),
	'/../../d1/'      => ('', '/../../d1/',   ''),
	'/././d1/'        => ('', '/././d1/',     ''),
);
for %splitpath.kv -> $get, $want {
	is $Unix.splitpath( $get ), $want, "splitpath: '$get' -> '$want'";
}

my %split = (
	'/'               => ('', '/',             '/'),
	'.'               => ('', '.',             '.'),
	'file'            => ('', '.',          'file'),
        'dir/'            => ('', '.',           'dir'),
        '/dir/'           => ('', '/',           'dir'),
	'/d1/d2/d3/'      => ('', '/d1/d2',       'd3'),
	'd1/d2/d3/'       => ('', 'd1/d2',       'd3'),
	'/d1/d2/d3/.'     => ('', '/d1/d2/d3',     '.'),
	'/d1/d2/d3/..'    => ('', '/d1/d2/d3',    '..'),
	'/d1/d2/d3/.file' => ('', '/d1/d2/d3', '.file'),
	'd1/d2/d3/file'   => ('', 'd1/d2/d3',   'file'),
	'/../../d1/'      => ('', '/../..',       'd1'),
	'/././d1/'        => ('', '/./.',         'd1'),
);
for %split.kv -> $get, $want {
	is $Unix.split( $get ), $want, "split: '$get' -> '$want'";
}

my @join = (
	$('','.','.'),              '.',
	$('','/','/'),              '/',
        $('','.','file'),           'file',
	$('','','file'),            'file',
        $('','dir','.'),            'dir/.',
	$('','/d1/d2/d3/',''),      '/d1/d2/d3/',
	$('','d1/d2/d3/',''),       'd1/d2/d3/',
	$('','/d1/d2/d3/.',''),     '/d1/d2/d3/.',
	$('','/d1/d2/d3/..',''),    '/d1/d2/d3/..',
	$('','/d1/d2/d3/','.file'), '/d1/d2/d3/.file',
	$('','d1/d2/d3/','file'),   'd1/d2/d3/file',
	$('','/../../d1/',''),      '/../../d1/',
	$('','/././d1/',''),        '/././d1/',
	$('d1','d2/d3/',''),        'd2/d3/',
	$('d1','d2','d3/'),         'd2/d3/'
);
for @join -> $get, $want {
	is $Unix.join( |$get ), $want, "join: '$get' -> '$want'";
}


my %splitdir = (
	''           => '',
	'/d1/d2/d3/' => ('', 'd1', 'd2', 'd3', ''),
	'd1/d2/d3/'  => ('d1', 'd2', 'd3', ''),
	'/d1/d2/d3'  => ('', 'd1', 'd2', 'd3'),
	'd1/d2/d3'   => ('d1', 'd2', 'd3'),
);
for %splitdir.kv -> $get, $want {
	is $Unix.splitdir( $get ), $want, "splitdir: '$get' -> '$want'";
}

is $Unix.catpath('','','file'),            'file',            "catpath: ('','','file') -> 'file'";
is $Unix.catpath('','/d1/d2/d3/',''),      '/d1/d2/d3/',      "catpath: ('','/d1/d2/d3/','') -> '/d1/d2/d3/'";
is $Unix.catpath('','d1/d2/d3/',''),       'd1/d2/d3/',       "catpath: ('','d1/d2/d3/','') -> 'd1/d2/d3/'";
is $Unix.catpath('','/d1/d2/d3/.',''),     '/d1/d2/d3/.',     "catpath: ('','/d1/d2/d3/.','') -> '/d1/d2/d3/.'";
is $Unix.catpath('','/d1/d2/d3/..',''),    '/d1/d2/d3/..',    "catpath: ('','/d1/d2/d3/..','') -> '/d1/d2/d3/..'";
is $Unix.catpath('','/d1/d2/d3/','.file'), '/d1/d2/d3/.file', "catpath: ('','/d1/d2/d3/','.file') -> '/d1/d2/d3/.file'";
is $Unix.catpath('','d1/d2/d3/','file'),   'd1/d2/d3/file',   "catpath: ('','d1/d2/d3/','file') -> 'd1/d2/d3/file'";
is $Unix.catpath('','/../../d1/',''),      '/../../d1/',      "catpath: ('','/../../d1/','') -> '/../../d1/'";
is $Unix.catpath('','/././d1/',''),        '/././d1/',        "catpath: ('','/././d1/','') -> '/././d1/'";
is $Unix.catpath('d1','d2/d3/',''),        'd2/d3/',          "catpath: ('d1','d2/d3/','') -> 'd2/d3/'";
is $Unix.catpath('d1','d2','d3/'),         'd2/d3/',          "catpath: ('d1','d2','d3/') -> 'd2/d3/'";

is $Unix.abs2rel('/t1/t2/t3','/t1/t2/t3'),    '.',                  "abs2rel: ('/t1/t2/t3','/t1/t2/t3') -> '.'";
is $Unix.abs2rel('/t1/t2/t4','/t1/t2/t3'),    '../t4',              "abs2rel: ('/t1/t2/t4','/t1/t2/t3') -> '../t4'";
is $Unix.abs2rel('/t1/t2','/t1/t2/t3'),       '..',                 "abs2rel: ('/t1/t2','/t1/t2/t3') -> '..'";
is $Unix.abs2rel('/t1/t2/t3/t4','/t1/t2/t3'), 't4',                 "abs2rel: ('/t1/t2/t3/t4','/t1/t2/t3') -> 't4'";
is $Unix.abs2rel('/t4/t5/t6','/t1/t2/t3'),    '../../../t4/t5/t6',  "abs2rel: ('/t4/t5/t6','/t1/t2/t3') -> '../../../t4/t5/t6'";
is $Unix.abs2rel('/','/t1/t2/t3'),            '../../..',           "abs2rel: ('/','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('///','/t1/t2/t3'),          '../../..',           "abs2rel: ('///','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('/.','/t1/t2/t3'),           '../../..',           "abs2rel: ('/.','/t1/t2/t3') -> '../../..'";
is $Unix.abs2rel('/./','/t1/t2/t3'),          '../../..',           "abs2rel: ('/./','/t1/t2/t3') -> '../../..'";
#[ "Unix->abs2rel('../t4','/t1/t2/t3'),             '../t4',              "abs2rel: ('../t4','/t1/t2/t3') -> '../t4'";
is $Unix.abs2rel('/t1/t2/t3', '/'),           't1/t2/t3',           "abs2rel: ('/t1/t2/t3', '/') -> 't1/t2/t3'";
is $Unix.abs2rel('/t1/t2/t3', '/t1'),         't2/t3',              "abs2rel: ('/t1/t2/t3', '/t1') -> 't2/t3'";
is $Unix.abs2rel('t1/t2/t3', 't1'),           't2/t3',              "abs2rel: ('t1/t2/t3', 't1') -> 't2/t3'";
is $Unix.abs2rel('t1/t2/t3', 't4'),           '../t1/t2/t3',        "abs2rel: ('t1/t2/t3', 't4') -> '../t1/t2/t3'";

is $Unix.rel2abs('t4','/t1/t2/t3'),           '/t1/t2/t3/t4',    "rel2abs: ('t4','/t1/t2/t3') -> '/t1/t2/t3/t4'";
is $Unix.rel2abs('t4/t5','/t1/t2/t3'),        '/t1/t2/t3/t4/t5', "rel2abs: ('t4/t5','/t1/t2/t3') -> '/t1/t2/t3/t4/t5'";
is $Unix.rel2abs('.','/t1/t2/t3'),            '/t1/t2/t3',       "rel2abs: ('.','/t1/t2/t3') -> '/t1/t2/t3'";
is $Unix.rel2abs('..','/t1/t2/t3'),           '/t1/t2/t3/..',    "rel2abs: ('..','/t1/t2/t3') -> '/t1/t2/t3/..'";
is $Unix.rel2abs('../t4','/t1/t2/t3'),        '/t1/t2/t3/../t4', "rel2abs: ('../t4','/t1/t2/t3') -> '/t1/t2/t3/../t4'";
is $Unix.rel2abs('/t1','/t1/t2/t3'),          '/t1',             "rel2abs: ('/t1','/t1/t2/t3') -> '/t1'";

if $*OS ~~ any(<MacOS MSWin32 os2 VMS epoc NetWare symbian dos cygwin>) {
	skip_rest 'Unix on-platform tests'
}
else {
	isa_ok File::Spec.MODULE, File::Spec::Unix, "unix: loads correct module";
	is File::Spec.rel2abs( File::Spec.curdir ), $*CWD, "rel2abs: \$*CWD test";
	ok {.IO.d && .IO.w}.(File::Spec.tmpdir), "tmpdir: {File::Spec.tmpdir} is a writable directory";
}

done;
