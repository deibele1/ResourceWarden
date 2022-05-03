require_relative '../lib/ResourceWarden'
include ResourceWarden
$min_sleep = 0.001
$max_sleep = 0.003

$threads = []

forks = [
  :fork_1,
  :fork_2,
  :fork_3,
  :fork_4,
  :fork_5,
  :fork_6,
  :fork_7,
  :fork_8,
  :fork_9,
]

philosophers = [
  :descartes,
  :leibniz,
  :pascal,
  :hume,
  :aristotle,
  :spinoza,
  :plato,
  :kant,
  :camus
]

class Fork
  def initialize(name)
    @name = name
  end

  def use
    @name
  end
end

class Philosopher
  def initialize(name, resource_warden)
    @name = name
    @resource_warden = resource_warden
    @mutex = Mutex.new
    @retired = false
    start
  end

  def name
    @name
  end

  def eat
    @resource_warden.synchronize do
      resources = @resource_warden.resources
      @mutex.synchronize do
        change_state(:eating)
        print("  ")
        print("#{@name} used #{resources[0].use}")
        resources[1..-2].each { |fork| print " #{fork.use}," } if resources.length > 2
        print(" and #{resources[-1].use}") if resources.length > 1
        print(" to eat \n")
        sleep(rand($min_sleep..$max_sleep))
        puts("    #{@name} has finished eating")
        change_state(nil)
      end
    end
  end

  def think
    @mutex.synchronize do
      change_state(:thinking)
      puts("#{@name} is thinking, tremble!")
      sleep(rand($min_sleep..$max_sleep))
      change_state(nil)
    end
  end

  def change_state(new_state)
    @state = new_state
  end

  def act
    [true, false].sample ? eat : think
  end

  def retire
    @retired = true
    @thread&.join
  end

  private def start
    @thread ||= Thread.new { act until @retired }
  end
end

fork_resources = forks.map { |fork| Warden.create(fork) { Fork.new(fork) } }

fork_sharers = []
philosophers.each_with_index do |name, index|
  fork_sharers << Philosopher.new(name, Warden.new(fork_resources[index], fork_resources[(index + 1) % fork_resources.length]))
end

sleep 0.1

fork_sharers.each(&:retire)
