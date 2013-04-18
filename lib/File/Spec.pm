class File::Spec;
my $module;
my %module = (
	<MacOS Mac>                             »=>» 'Mac',
	<MSWin32 os2 dos NetWare symbian Win32> »=>» 'Win32',
	<cygwin Cygwin>                         »=>» 'Cygwin',
	'VMS'     => 'VMS'
);

$module = "File::Spec::" ~ (%module{$*OS} // 'Unix');
require ::($module);
my $CLASS = ::($module);

method MODULE handles
	<canonpath curdir updir rootdir devnull tmpdir
	 file-name-is-absolute no-parent-or-current-test
	 path split join splitpath catpath catfile
	 splitdir catdir abs2rel rel2abs NYI>
		 { $CLASS }

method os (Str $OS = $*OS ) {
	my $module = "File::Spec::" ~ (%module{$OS} // 'Unix');
	require ::($module);
	::($module);
}

=begin pod

#| MODULE - for module introspection
method MODULE                            { $module; }  # for introspection

#| Returns a copy of the module for the given OS string
#| e.g. File::Spec.os('Win32') returns File::Spec::Win32


# class methods
method canonpath( $path )                   { ::($module).canonpath( $path )                   }
method catdir( *@parts )                    { ::($module).catdir( @parts )                     }
method catfile( *@parts )                   { ::($module).catfile( @parts )                    }
method curdir                               { ::($module).curdir()                             }
method devnull                              { ::($module).devnull()                            }
method rootdir                              { ::($module).rootdir()                            }
method tmpdir                               { ::($module).tmpdir()                             }
method updir                                { ::($module).updir()                              }
method no-parent-or-current-test            { ::($module).no-parent-or-current-test            }
method file-name-is-absolute( $file )       { ::($module).file-name-is-absolute( $file )       }
method path                                 { ::($module).path()                               }
method splitpath( $path, $no_file = False ) { ::($module).splitpath( $path, $no_file )         }
method splitdir( $path )                    { ::($module).splitdir( $path )                    }
method catpath( $volume, $directory, $file) { ::($module).catpath( $volume, $directory, $file) }
method abs2rel( |c )                        { ::($module).abs2rel( |c )                        }
method rel2abs( |c )                        { ::($module).rel2abs( |c )                        }

method split ( $path )                       { ::($module).split( $path )                      }
method join ( $volume, $directory, $file )   { ::($module).join( $volume, $directory, $file )  }

=end pod
