project(
  'luar',
  version: run_command('cat', meson.project_source_root() / 'version').stdout().strip(),
)

domain = 'ggez.tokyob0t.luar'
resource = '/ggez/tokyob0t/luar'
ignore_requires = 'lgi'

name = meson.project_name()
version = meson.project_version()

root = meson.current_source_dir()
prefix = get_option('prefix')
libdir = prefix / get_option('libdir')
datadir = prefix / get_option('datadir')
bindir = prefix / get_option('bindir')
pkgdatadir = datadir / name

lua_dirs = run_command(
  'find',
  root / 'src',
  '-type', 'f',
  '-name', '*.lua',
  '-exec', 'dirname',
  '{}',
  ';',
).stdout().strip().split('\n')

project_paths = ''

foreach d : lua_dirs
  project_paths += d + '/?.lua;' + d + '/?/init.lua;'
endforeach

lua = find_program('luajit')
luarocks = find_program('luarocks')
luarocks_path = run_command(luarocks, '--lua-version=5.1', 'path').stdout()

lua_path = ''

foreach line : luarocks_path.split('\n')
  if line.startswith('export LUA_PATH=')
    lua_path = line.split('=')[1].strip('\'')
  endif
endforeach

custom_target(
  input: configure_file(
    input: 'src/init.in.lua',
    output: 'init.lua',
    configuration: {
      'lua': lua.full_path(),
      'name': name,
      'resource': resource,
      'domain': domain,
      'version': version,
      'gresourcePath': datadir / domain / domain + '.gresource',
    },
  ),
  command: [
    lua,
    root / 'scripts/lua/bundle.lua',
    '@INPUT@',
    '-o', '@OUTPUT@',
    '-i', lua_path + ';' + project_paths,
    '-g', ignore_requires,
    # '--minify',
    '--verbose',
    '--no-animals',
  ],
  output: name,
  install: true,
  install_dir: bindir,
  install_mode: 'rwxr-xr-x',
)

configure_file(
  input: 'src/styles.scss',
  output: 'styles.css',
  command: [
    find_program('sass'),
    '@INPUT@',
    '@OUTPUT@',
    '--no-source-map',
    '--style=expanded',
  ],
)

custom_target(
  input: configure_file(
    input: 'data/gresource.in.xml',
    output: domain + '.gresource.xml',
    configuration: {
      'resource': resource,
    },
  ),
  output: domain + '.gresource',
  command: [
    find_program('glib-compile-resources'),
    '@INPUT@',
    '--target=@OUTPUT@',
  ],
  install: true,
  install_dir: datadir / domain,
)

configure_file(
  input: 'data/gschema.in.xml',
  output: domain + '.gschema.xml',
  configuration: {'resource': resource, 'domain': domain},
  install: true,
  install_dir: datadir / 'glib-2.0' / 'schemas',
)

install_data(
  'data/lua.portal',
  install_dir: datadir / 'xdg-desktop-portal' / 'portals',
)

test(
  'validate-gschema',
  find_program('glib-compile-schemas'),
  args: [
    '--strict',
    '--dry-run', meson.current_source_dir(),
  ],
)

test(
  'validate-gresource',
  find_program('glib-compile-resources'),
  args: [
    '--strict',
    '--dry-run', meson.current_source_dir(),
  ],
)

import('gnome').post_install(
  # gtk_update_icon_cache: true,
  glib_compile_schemas: true,
  # update_desktop_database: true,
)
