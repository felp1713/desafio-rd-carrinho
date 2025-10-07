class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform(*args)
    Cart.to_be_abandoned.update_all(status: 'abandoned')

    Cart.to_be_deleted.destroy_all
  end
end
