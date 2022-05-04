require_relative './Key'
##
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

    ##
    # changes the heir to the caller and builds a connector proc to wait on the current thread
    def get_key
      heir = nil
      thread = Thread.current
      @registration.synchronize do
        heir = @heir
        @heir = Thread.current
      end
      Key.new do
        heir&.join
        chown(thread)
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

    ##
    # Responds only to public methods of the resource cell until the calling thread owns the resource then responds
    # resource methods as well
    def respond_to_missing?(method_name, include_private = false)
      super || Thread.current == @owner && @resource.respond_to?(method_name, include_private)
    end
  end
end