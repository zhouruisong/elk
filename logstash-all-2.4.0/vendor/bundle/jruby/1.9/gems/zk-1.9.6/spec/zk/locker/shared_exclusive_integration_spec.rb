require 'spec_helper'

shared_examples_for :shared_exclusive_integration do
  before do
    @sh_lock = ZK::Locker.shared_locker(zk, path)
    @ex_lock = ZK::Locker.exclusive_locker(zk2, path)
  end

  describe 'shared lock acquired first' do
    it %[should block exclusive locks from acquiring until released] do
      @sh_lock.lock.should be_true
      @ex_lock.lock.should be_false

      mutex = Monitor.new
      cond = mutex.new_cond
      
      th = Thread.new do
        logger.debug { "@ex_lock trying to acquire acquire lock" }
        @ex_lock.with_lock do
          th[:got_lock] = @ex_lock.locked?
          logger.debug { "@ex_lock.locked? #{@ex_lock.locked?}" }

          mutex.synchronize do
            cond.broadcast
          end
        end
      end

      mutex.synchronize do
        logger.debug { "unlocking the shared lock" }
        @sh_lock.unlock.should be_true
        cond.wait_until { th[:got_lock] }   # make sure they actually received the lock (avoid race)
        th[:got_lock].should be_true
        logger.debug { "ok, they got the lock" }
      end

      th.join(5).should == th

      logger.debug { "thread joined, exclusive lock should be releasd" }

      @ex_lock.should_not be_locked
    end
  end

  describe 'multiple shared locks acquired first' do
    before do
      zk3.should_not be_nil
      @sh_lock2 = ZK::Locker.shared_locker(zk3, path) 
    end
    it %[should not aquire a lock when highest-numbered released but others remain] do
      @sh_lock.lock.should be_true
      @sh_lock2.lock.should be_true
      @ex_lock.lock.should be_false

      mutex = Monitor.new
      cond = mutex.new_cond

      th = Thread.new do
        logger.debug { "@ex_lock trying to acquire acquire lock" }
        begin
          @ex_lock.with_lock(:wait=>0.1) do
            th[:got_lock] = @ex_lock.locked?
            logger.debug { "@ex_lock.locked? #{@ex_lock.locked?}" }
          end
        rescue ZK::Exceptions::LockWaitTimeoutError
          logger.debug { "@ex_lock timed out trying to acquire acquire lock" }
          th[:got_lock] = false
        rescue
          logger.debug { "@ex_lock raised unexpected error: #{$!.inspext}" }
          th[:got_lock] = {:error_raised => $!}
        end
        mutex.synchronize { cond.broadcast }
      end

      mutex.synchronize do
        @ex_lock.wait_until_blocked(1)
        logger.debug { "unlocking the highest shared lock" }
        @sh_lock2.unlock.should be_true
        cond.wait_until { (!th[:got_lock].nil?) }   # make sure they actually received the lock (avoid race)
        th[:got_lock].should be_false
        logger.debug { "they didn't get the lock." }
      end

      th.join(5).should == th

      logger.debug { "thread joined, exclusive lock should be releasd" }
      @sh_lock.unlock.should be_true
      @ex_lock.should_not be_locked
    end
  end

  describe 'exclusive lock acquired first' do
    it %[should block shared lock from acquiring until released] do
      @ex_lock.lock.should be_true
      @sh_lock.lock.should be_false

      mutex = Monitor.new
      cond = mutex.new_cond
      
      th = Thread.new do
        logger.debug { "@ex_lock trying to acquire acquire lock" }
        @sh_lock.with_lock do
          th[:got_lock] = @sh_lock.locked?
          logger.debug { "@sh_lock.locked? #{@sh_lock.locked?}" }

          mutex.synchronize do
            cond.broadcast
          end
        end
      end

      mutex.synchronize do
        logger.debug { "unlocking the shared lock" }
        @ex_lock.unlock.should be_true
        cond.wait_until { th[:got_lock] }   # make sure they actually received the lock (avoid race)
        th[:got_lock].should be_true
        logger.debug { "ok, they got the lock" }
      end

      th.join(5).should == th

      logger.debug { "thread joined, exclusive lock should be releasd" }

      @sh_lock.should_not be_locked
    end
  end

  describe 'shared-exclusive-shared' do
    before do
      zk3.should_not be_nil
      @sh_lock2 = ZK::Locker.shared_locker(zk3, path) 
    end

    it %[should act something like a queue] do
      @array = []

      @sh_lock.lock.should be_true
      @sh_lock.should be_locked

      ex_th = Thread.new do
        begin
          @ex_lock.lock(true)  # blocking lock
          @ex_lock.assert!
          @array << :ex_lock
        ensure
          @ex_lock.unlock
        end
      end

      logger.debug { "about to wait for @ex_lock to be blocked" }

      @ex_lock.wait_until_blocked(5)
      @ex_lock.should be_waiting

      logger.debug { "@ex_lock is waiting" }

      @ex_lock.should_not be_locked

      # this is the important one, does the second shared lock get blocked by
      # the exclusive lock
      @sh_lock2.lock.should_not be_true

      sh2_th = Thread.new do
        begin
          @sh_lock2.lock(true)
          @sh_lock2.assert!
          @array << :sh_lock2
        ensure
          @sh_lock2.unlock
        end
      end

      logger.debug { "about to wait for @sh_lock2 to be blocked" }

      @sh_lock2.wait_until_blocked(5)
      @sh_lock2.should be_waiting

      logger.debug { "@sh_lock2 is waiting" }

      # ok, now unlock the first in the chain
      @sh_lock.assert!
      @sh_lock.unlock.should be_true

      ex_th.join(5).should == ex_th
      sh2_th.join(5).should == sh2_th

      @array.length.should == 2
      @array.should == [:ex_lock, :sh_lock2]
    end
  end
end # shared_exclusive_integration

describe do
  include_context 'locker non-chrooted'

  it_should_behave_like :shared_exclusive_integration
end

describe :chrooted => true do
  include_context 'locker chrooted'

  it_should_behave_like :shared_exclusive_integration
end

