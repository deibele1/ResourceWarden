require './Key'
# wraps a resource to ensure only a keyholder can execute code
class ResourceCell
  class JailbreakException < Exception; end
  # safe_methods = [:send, :__send__, :public_send, :object_id]
  # safe_methods = []
  # (instance_methods - safe_methods).each do |method|
  #   eval("undef #{method}")
  # end

  def initialize(resource)
    @mutex = Mutex.new
    @registration = Mutex.new
    @heir = nil
    @resource = resource
    @registry = []
  end

  # changes the heir to the caller and builds a connector proc to wait on the current thread
  def resource_key
    heir = nil
    @registration.synchronize do
      heir = @heir
      @heir = Thread.current
    end
    Key.new do
      heir&.join
      chown(Thread.current)
    end
  end

  def inmate_id
    @resource.object_id
  end

  private def owner
    @owner
  end

  private def chown(thread)
    @mutex.synchronize do
      @owner = thread
    end
  end

  private def method_missing(symbol, *args)
    return @resource.send(symbol, *args) if Thread.current == owner
    throw JailbreakException.new("A thread must first use a resource key before accessing a resource")
  end
end
