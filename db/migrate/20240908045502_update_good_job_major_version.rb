class UpdateGoodJobMajorVersion < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :good_jobs, :locked_by_id, :uuid
    add_column :good_jobs, :locked_at, :datetime

    add_column :good_job_executions, :error_backtrace, :text
    add_column :good_job_executions, :process_id, :uuid
    add_column :good_job_executions, :duration, :interval

    add_column :good_job_processes, :lock_type, :integer

    add_index :good_jobs, [:priority, :scheduled_at], order: { priority: "ASC NULLS LAST", scheduled_at: :asc },
      where: "finished_at IS NULL AND locked_by_id IS NULL", name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked,
      algorithm: :concurrently
    add_index :good_jobs, :locked_by_id,
      where: "locked_by_id IS NOT NULL", name: "index_good_jobs_on_locked_by_id", algorithm: :concurrently
    add_index :good_job_executions, [:process_id, :created_at], name: :index_good_job_executions_on_process_id_and_created_at,
      algorithm: :concurrently
  end
end
