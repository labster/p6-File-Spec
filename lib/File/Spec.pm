class File::Spec;
my %module = (
	<MacOS Mac>                             »=>» 'Mac',
	<MSWin32 os2 dos NetWare symbian Win32> »=>» 'Win32',
	<cygwin Cygwin>                         »=>» 'Cygwin',
	'VMS'     => 'VMS'
);

my $module = "File::Spec::" ~ (%module{$*OS} // 'Unix');
require ::($module);
my $CLASS := ::($module);

#| Dispatches methods to the appropriate class for the current $*OS
method MODULE handles
	<canonpath curdir updir rootdir devnull tmpdir
	 file-name-is-absolute no-parent-or-current-test
	 path split join splitpath catpath catfile
	 splitdir catdir abs2rel rel2abs>
		{ $CLASS }

#| Returns a copy of the module for the given OS string
#| e.g. File::Spec.os('Win32') returns File::Spec::Win32
method os (Str $OS = $*OS ) {
	my $module = "File::Spec::" ~ (%module{$OS} // 'Unix');
	require ::($module);
	::($module);
}
