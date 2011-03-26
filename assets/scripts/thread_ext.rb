class Thread
  def self.with_large_stack(stack_size_kb = 128, &block)
    r = proc do
      begin
        block.call
      rescue
        java.lang.System.out.println $!.message
        java.lang.System.out.println $!.backtrace.join("\n")
        raise $!
      end
    end
    t = java.lang.Thread.new(nil, r, "runWithLargeStack", stack_size_kb * 1024)
    t.start
    t
  rescue
    java.lang.System.out.println $!.message
    java.lang.System.out.println $!.backtrace.join("\n")
    raise $!
  end
end
