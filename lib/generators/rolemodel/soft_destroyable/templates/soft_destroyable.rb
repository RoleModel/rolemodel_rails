# frozen_string_literal: true

module SoftDestroyable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(deleted_at: nil) }
    scope :only_deleted, -> { where.not(deleted_at: nil) }
    define_model_callbacks :soft_destroy
    define_model_callbacks :restore
  end

  module ClassMethods
    def default_scope(scope = nil)
      unless scope.nil? && !block_given?
        raise "Default scopes should not be used with soft destroyable - in class #{name}"
      end
    end

    def soft_destroy(timestamp = Time.zone.now)
      kept.each { |o| o.soft_destroy(timestamp) }
    end

    def restore(timestamp)
      only_deleted.each { |o| o.restore(timestamp) }
    end

    def cascade_soft_destroy(associations)
      Array.wrap(associations).each do |association_name|
        define_method("soft_destroy_#{association_name}") do
          send(association_name).soft_destroy(deleted_at)
        end
        after_soft_destroy("soft_destroy_#{association_name}".to_sym)
        define_method("restore_#{association_name}") do
          send(association_name).restore(deleted_at)
        end
        before_restore("restore_#{association_name}".to_sym)
      end
    end
  end

  def soft_destroyed?
    deleted_at.present?
  end

  def soft_destroy(timestamp = Time.zone.now)
    return if soft_destroyed?

    run_callbacks(:soft_destroy) do
      update(deleted_at: timestamp)
    end
  end

  def soft_destroy!
    soft_destroy || raise_validation_errors
  end

  def restore(timestamp = deleted_at)
    return unless deleted_at == timestamp

    run_callbacks(:restore) do
      update(deleted_at: nil)
    end
  end

  # This may have unintended consequences or issues with restoring records with associations in varying states
  # This will only raise an exception at the top level but does not guarantee nested objects were restored
  # and will not guarantee errors restoring nested objects are surfaced
  def restore!
    restore(deleted_at) || raise_validation_errors
  end

  private

  def raise_validation_errors
    raise ActiveModel::ValidationError, self
  end
end
