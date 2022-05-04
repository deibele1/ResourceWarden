##
# A class encapsulating a single use Proc to change the owner of a resource to the thread that request a resource key
class Key
  class ReuseException < Exception; end
  def initialize(&block)
    @proc = Proc.new(&block)
  end

  ##
  # Calls the Proc created by the resource cell which switches the owner of the resource to the thread that requested the key
  # This is the only intended way to obtain ownership of a resource
  def use
    throw ReuseException.new("A key can only be used once") unless @proc.is_a?(Proc)

    @proc.call
    @proc = nil
  end
end
