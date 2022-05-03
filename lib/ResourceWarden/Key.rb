class Key
  class ReuseException < Exception; end
  def initialize(&block)
    @proc = Proc.new(&block)
  end

  def use
    throw ReuseException.new("A key can only be used once") unless @proc.is_a?(Proc)

    @proc.call
    @proc = nil
  end
end
