import os
import glob
import ycm_core

flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-std=c++14',
    '-x', 'c++',
    '-I', '/usr/include',
    '-I', '.'
    ]
compilation_database_folder = None
if os.environ.has_key('YCM_BLD_DIR'):
  compilation_database_folder = os.environ['YCM_BLD_DIR']
elif os.path.exists(os.path.join(os.getcwd(), 'compile_commands.json')):
  compilation_database_folder = os.getcwd()
else:
  current_source = os.getcwd()
  builds = [ current_source + '/build/', current_source + '/bin/', os.path.abspath(current_source + '../build/') ]
  for build in builds:
    first_build = build
    if os.path.exists(os.path.join(build, 'compile_commands.json')):
      compilation_database_folder = build
      break

if compilation_database_folder:
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )

def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

def FindCorrespondingSourceFile( filename ):
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        return replacement_file
      src_file = replacement_file.replace("inc", "src")
      if os.path.exists( src_file ):
        return src_file
      src_file = replacement_file.replace("include", "src")
      if os.path.exists( src_file ):
        return src_file

  return filename

def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )

  return new_flags


def FlagsForFile( filename ):
  filename = FindCorrespondingSourceFile( filename )
  if database:
    compilation_info = database.GetCompilationInfoForFile( filename )
    final_flags = MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_ )
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return {
        'flags': final_flags,
        'do_cache': True,
        'override_filename': filename
        }
