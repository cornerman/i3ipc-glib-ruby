require 'ffi-gobject_introspection'

module I3ipc
  module Introspected
    def self.included(mod)
      name = mod.name.split(/::/).last
      infos = method_infos('i3ipc', name)
      [ListWrapper.new, ClosureWrapper.new].each do |wrapper|
        wrap_methods(mod, infos, wrapper);
      end
    end

    private

    def self.wrap_methods(mod, infos, wrapper)
      methods = infos.select(&wrapper.method(:applicable?)).map do |info|
        mod.setup_instance_method(info.name)
        mod.instance_method(info.name)
      end

      methods.each do |f|
        mod.send(:define_method, f.name, wrapper.wrap_method(f))
      end
    end

    def self.method_infos(namespace, name)
      gir = GObjectIntrospection::IRepository.default
      gir.require(namespace, nil)
      members = gir.find_by_name(namespace, name)

      methods = members.get_methods.map do |m|
        MethodInfo.new(m.name, m.return_type, m.args)
      end

      properties = members.properties.map do |p|
        MethodInfo.new(p.getter_name, p.property_type, [])
      end

      methods + properties
    end

    class MethodInfo < Struct.new(:name, :type, :args)
    end

    class ListWrapper
      def applicable?(f)
        [:gslist, :glist].include? f.type.tag
      end

      def wrap_method(f)
        lambda do |*args|
          (f.bind(self).call(*args) || []).to_a
        end
      end
    end

    class ClosureWrapper
      def applicable?(f)
        args = f.args.map { |a| a.argument_type.interface }
        args.last && (args.last.name == 'Closure')
      end

      def wrap_method(f)
        lambda do |*args, &block|
          f.bind(self).call(*args, GObject::RubyClosure.new(&block))
        end
      end
    end
  end
end
