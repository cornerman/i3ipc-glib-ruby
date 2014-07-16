require 'ffi-gobject_introspection'

module I3ipc
  module Introspected
    def self.included(mod)
      name = mod.name.split(/::/).last
      infos = get_method_introspections('i3ipc', name)
      override_list_methods(mod, infos)
      override_closure_methods(mod, infos)
    end

    private

    def self.list_method?(f)
        [:gslist, :glist].include? f.return_type.tag
    end

    def self.override_list_methods(mod, infos)
      get_methods(mod, infos.select(&method(:list_method?))).each do |f|
        mod.send(:define_method, f.name) do |*args|
          (f.bind(self).call(*args) || []).to_a
        end
      end
    end

    def self.closure_method?(f)
        args = f.args.map { |a| a.argument_type.interface }
        args.last && (args.last.name == 'Closure')
    end

    def self.override_closure_methods(mod, infos)
      get_methods(mod, infos.select(&method(:closure_method?))).each do |f|
        mod.send(:define_method, f.name) do |*args, &block|
          f.bind(self).call(*args, GObject::RubyClosure.new(&block))
        end
      end
    end

    def self.get_methods(mod, infos)
      infos.map do |f|
        mod.setup_instance_method(f.name)
        mod.instance_method(f.name)
      end
    end

    def self.get_method_introspections(namespace, name)
      gir = GObjectIntrospection::IRepository.default
      gir.require(namespace, nil)
      members = gir.find_by_name(namespace, name)
      members.get_methods
    end
  end
end
