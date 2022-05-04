##
# Resource Exclusion module
# A block is passed which will then be encapsulated in a thread immediately joined by the current thread.
# This allows requests for multiple resources and guarantees a lock on all resources will be granted
# as soon as all prior virtual threads with a claim on a resource terminate.
# The warden calls the cell which generates a key which will join the prior resource claimant and change ownership
# of the resource when used. Attempting to use a resource without ownership will result in an exception.
# Auto joining in this way ensures no resource starvation, no deadlocks, no live-locks and true concurrency.
# Tasks should be kept small when using this model and all tasks must eventually terminate.
# This model can solve a generalized dining philosophers problem with any resource exclusion structure.
require_relative('./ResourceCell')
module ResourceWarden
  class Warden
    @mutex = Mutex.new
    @registration = Mutex.new

    ##
    # takes a list of resources which constitute a block of resources that must be obtained as a group
    def initialize(*resources)
      @cell_block = resources || []
      @block_mutex = Mutex.new
    end

    ##
    # adds a resource to the exclusive resource block
    # @param resource [ResourceWarden::ResourceCell]
    def add(resource)
      @block_mutex.synchronize { @cell_block << resource }
    end

    ##
    # @return [Array<ResourceWarden::ResourceCell>]
    def resources
      @cell_block
    end

    ##
    # Runs a block of code with exclusive access to all resources in the block
    def synchronize(&block)
      @block_mutex.synchronize { Warden.synchronize(*@cell_block, &block) }
    end

    ##
    # Runs a block of code with exclusive access to a list of resources
    # @param resources [ResourceWarden::ResourceCell]
    def self.synchronize(*resources, &block)
      keys = []
      # creating a virtual thread to guarantee the owning thread is joinable
      Thread.new do
        @registration.synchronize { keys = resources.map(&:get_key) }
        keys.each(&:use)
        block.call
      end.join
    end


    ##
    # Takes a object or block and creates a resource from the object or output of the block respectively
    def self.create(object = nil)
      @registration.synchronize do
        item = block_given? ? yield : object
        ResourceCell.new(item)
      end
    end
  end
end