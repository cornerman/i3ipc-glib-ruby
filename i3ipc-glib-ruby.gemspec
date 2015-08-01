Gem::Specification.new do |s|
    s.name         = 'i3ipc-glib-ruby'
    s.version      = '0.0.1'
    s.summary      = 'IPC library for i3'
    s.description  = 'GirFFI based wrapper for i3ipc-glib'
    s.authors      = ['Johannes Karoff']
    s.email        = 'johannes@karoff.net'
    s.homepage     = 'https://github.com/cornerman/i3ipc-glib-ruby'
    s.license      = 'GPL-3'
    s.files        = Dir.glob('lib/**/*')
    s.require_path = 'lib'
    s.add_dependency 'gir_ffi', '~> 0'
end
