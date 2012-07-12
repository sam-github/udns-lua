# Copyright (c) 2010 WorkWare Systems http://www.workware.net.au/
# All rights reserved

# @synopsis:
#
# The 'cc-shared' module provides support for shared libraries and shared objects.
# It defines the following variables:
#
## SH_CFLAGS         Flags to use compiling sources destined for a shared library
## SH_LDFLAGS        Flags to use linking (creating) a shared library
## SH_SOPREFIX       Prefix to use to set the soname when creating a shared library
## SH_SOEXT          Extension for shared libs
## SH_SOEXTVER       Format for versioned shared libs - %s = version
## SHOBJ_CFLAGS      Flags to use compiling sources destined for a shared object
## SHOBJ_LDFLAGS     Flags to use linking a shared object, undefined symbols allowed
## SHOBJ_LDFLAGS_R   - as above, but all symbols must be resolved
## SH_LINKFLAGS      Flags to use linking an executable which will load shared objects
## LD_LIBRARY_PATH   Environment variable which specifies path to shared libraries

module-options {}

foreach i {SH_LINKFLAGS SH_CFLAGS SH_LDFLAGS SH_SONAME SHOBJ_CFLAGS SHOBJ_LDFLAGS} {
	define $i ""
}

# Some common defaults
define LD_LIBRARY_PATH LD_LIBRARY_PATH
define SH_SOEXT .so
define SH_SOEXTVER .so.%s

switch -glob -- [get-define host] {
	*-*-darwin* {
		define SH_CFLAGS -dynamic
		define SH_LDFLAGS "-dynamiclib"
		define SHOBJ_CFLAGS "-dynamic -fno-common"
		define SHOBJ_LDFLAGS "-bundle -undefined dynamic_lookup"
		define SHOBJ_LDFLAGS_R "-bundle"
		define SH_SOPREFIX "-Wl,-install_name,"
		define SH_SOEXT ".dylib"
		define SH_SOEXTVER ".%s.dylib"
		define LD_LIBRARY_PATH DYLD_LIBRARY_PATH
	}
	*-*-ming* - *-*-cygwin - *-*-msys {
		define LD_LIBRARY_PATH PATH
		define SH_LDFLAGS -shared
		define SHOBJ_LDFLAGS -shared
		define SHOBJ_LDFLAGS_R -shared
		define SH_SOEXT ".dll"
		define SH_SOEXTVER .dll
	}
	sparc* {
		# gcc on sparc
		# sparc has a very small GOT table limit, so use -fPIC
		define SH_LINKFLAGS -rdynamic
		define SH_CFLAGS -fPIC
		define SH_LDFLAGS -shared
		define SHOBJ_CFLAGS -fPIC
		define SHOBJ_LDFLAGS -shared
	}
	*-*-solaris* {
		# XXX: These haven't been fully tested. 
		#define SH_LINKFLAGS -Wl,-export-dynamic
		define SH_CFLAGS -Kpic
		define SHOBJ_CFLAGS -Kpic
		define SHOBJ_LDFLAGS "-G"
	}
	*-*-hpux {
		# XXX: These haven't been tested
		define SH_LINKFLAGS -Wl,+s
		define SH_CFLAGS +z
		define SHOBJ_CFLAGS "+O3 +z"
		define SHOBJ_LDFLAGS -b
		define LD_LIBRARY_PATH SHLIB_PATH
	}
	* {
		# Generic Unix settings
		define SH_LINKFLAGS -rdynamic
		define SH_CFLAGS -fpic
		define SH_LDFLAGS -shared
		define SH_SOPREFIX "-Wl,-soname,"
		define SHOBJ_CFLAGS -fpic
		define SHOBJ_LDFLAGS -shared
	}
}

if {![is-defined SHOBJ_LDFLAGS_R]} {
	define SHOBJ_LDFLAGS_R [get-define SHOBJ_LDFLAGS]
}
