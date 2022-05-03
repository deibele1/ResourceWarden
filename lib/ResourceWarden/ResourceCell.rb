require_relative './Key'
# wraps a resource to ensure only a keyholder can execute code
module ResourceWarden
  class ResourceCell
    class JailbreakException < Exception; end
    class Unlock; end
    private_constant :Unlock

    def initialize(resource)
      @mutex = Mutex.new
      @registration = Mutex.new
      @heir = nil
      @resource = resource
      @registry = []
    end

    # changes the heir to the caller and builds a connector proc to wait on the current thread
    def get_key
      heir = nil
      @registration.synchronize do
        heir = @heir
        @heir = Thread.current
      end
      Key.new do
        heir&.join
        chown(Thread.current)
        Unlock.new
      end
    end

    private def owner
      @owner
    end

    private def chown(thread)
      @mutex.synchronize do
        @owner = thread
      end
    end

    private def method_missing(method_name, *args)
      return @resource.send(method_name, *args) if Thread.current == owner
      throw JailbreakException.new("A thread must first use a resource key before accessing a resource")
    end

    def respond_to_missing?(method_name, include_private = false)
      super || Thread.current == @owner && @resource.respond_to?(method_name, include_private)
    end
  end
end