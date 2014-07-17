module I3ipc
  load_class :Connection

  class Connection
    include Introspected

    method(:new).tap do |f|
      define_singleton_method :new do |socket = nil|
        f.call(socket)
      end
    end
  end
end
